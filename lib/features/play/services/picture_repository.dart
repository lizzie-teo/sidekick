import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/services/picture_stores.dart';

// Where colouring pictures are kept, and the one place that decides.
//
// **The first repository in the app.** `CLAUDE.md` said one would arrive
// when a backend and a local copy both existed, and this is that: the phone
// holds every picture, and for somebody with an account the server holds
// them too.
//
// | Who | Kept |
// | --- | --- |
// | No email on the account | On the phone only |
// | An email on the account | On the phone, and in the `colourings` table |
//
// **The phone copy is always the working copy.** Every change is written to
// the phone first, so colouring works with no signal. With an account the
// server copy follows, and a failed upload stays marked and is tried again at
// the next save or the next visit.
//
// **Why anonymous pictures stay off the server**, when good things go up
// from the first open: an anonymous user who deletes the app loses their
// session, and their rows stay on the server for ever with nobody able to
// reach them. A good-things line is a few bytes; a picture is tens of
// kilobytes. `_docs/briefs/colouring-book.md` holds the argument.
//
// Three moments move pictures, and each is below:
//
// | Moment | What happens |
// | --- | --- |
// | An email is attached, or an account signs in on this phone | Every phone picture not on the server is sent up |
// | The Colouring tab opens with an account | Pending ones go up, newer server ones come down |
// | The session ends | Pictures safely on the server leave the phone. Ones that never reached it stay |
//
// A picture deleted on another phone is **not** removed from this one when
// the lists are compared. An empty list from the server is indistinguishable
// from a misread one, and deleting somebody's work on that evidence is the
// wrong way to be wrong.
class PictureRepository {
  PictureRepository({
    required LoggerService loggerService,
    required PictureStore local,
    required PictureStore remote,
    required ValueListenable<bool> hasAccount,
  })  : _loggerService = loggerService,
        _local = local,
        _remote = remote,
        _hasAccount = hasAccount;

  final LoggerService _loggerService;
  final PictureStore _local;
  final PictureStore _remote;
  final ValueListenable<bool> _hasAccount;

  final Map<String, ColouringPicture> _byId = <String, ColouringPicture>{};
  final ValueNotifier<List<ColouringPicture>> _pictures =
      ValueNotifier<List<ColouringPicture>>(const <ColouringPicture>[]);

  // Newest first, which is the order the Colouring tab shows them in.
  ValueListenable<List<ColouringPicture>> get pictures => _pictures;

  Future<void>? _started;
  bool _hadAccount = false;

  // Phone writes run one after another, so two quick saves of the same
  // picture cannot land in the wrong order.
  Future<void> _localWrites = Future<void>.value();

  Future<void>? _pushing;
  bool _pushAgain = false;

  // Reads the phone's pictures once, and starts following the account.
  // Safe to call more than once: every later call waits on the first.
  Future<void> start() => _started ??= _start();

  Future<void> _start() async {
    _hadAccount = _hasAccount.value;
    _hasAccount.addListener(_onAccountChanged);

    try {
      for (final ColouringPicture picture in await _local.list()) {
        _byId[picture.id] = picture;
      }
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
    _publish();

    if (_hasAccount.value) {
      unawaited(sync());
    }
  }

  ColouringPicture? byId(String id) => _byId[id];

  // Keeps a new version of a picture. Returns once the phone has it; the
  // server copy, when there is one, follows on its own.
  Future<void> save(ColouringPicture picture) async {
    await start();

    final bool account = _hasAccount.value;
    final ColouringPicture kept = picture.copyWith(
      needsUpload: account,
      onServer: _byId[picture.id]?.onServer ?? picture.onServer,
    );

    _byId[kept.id] = kept;
    _publish();
    await _writeLocal(kept);

    if (account) {
      unawaited(_pushPending());
    }
  }

  // Deletes a picture everywhere it is kept. With an account the server goes
  // first and a failure is rethrown, so the screen can say it did not work
  // instead of the picture coming back at the next visit.
  Future<void> delete(String id) async {
    await start();

    if (_hasAccount.value) {
      // An upload in flight could put the row back after it is deleted.
      await _pushing;
      await _remote.delete(id);
    }

    _byId.remove(id);
    _publish();
    await (_localWrites = _localWrites.then((_) => _local.delete(id)));
  }

  // Sends what is pending and brings down anything newer. Does nothing for
  // somebody with no account.
  Future<void> sync() async {
    await start();
    if (!_hasAccount.value) return;

    await _pushPending();

    final List<ColouringPicture> remote;
    try {
      remote = await _remote.list();
    } catch (_) {
      // Logged by the store. Offline is ordinary; the phone copy stands.
      return;
    }

    for (final ColouringPicture theirs in remote) {
      final ColouringPicture? ours = _byId[theirs.id];

      // Newest wins, and a version on this phone that has not gone up yet is
      // never overwritten -- it is the newer one by definition.
      final bool take = ours == null ||
          (!ours.needsUpload && theirs.updatedAt.isAfter(ours.updatedAt));

      if (take) {
        _byId[theirs.id] = theirs;
        await _writeLocal(theirs);
      } else if (!ours.onServer) {
        final ColouringPicture marked = ours.copyWith(onServer: true);
        _byId[ours.id] = marked;
        await _writeLocal(marked);
      }
    }
    _publish();
  }

  // The session is gone -- a sign-out, an expired token, a sign-out on
  // another phone. Pictures the server has leave the phone with the account,
  // so the next person on it does not see them. Pictures it does not have
  // stay, because this phone is the only place they exist.
  Future<void> onSessionEnded() async {
    await start();

    final List<String> leaving = <String>[
      for (final ColouringPicture picture in _byId.values)
        if (picture.onServer && !picture.needsUpload) picture.id,
    ];

    for (final String id in leaving) {
      _byId.remove(id);
    }
    _publish();

    await (_localWrites = _localWrites.then((_) async {
      for (final String id in leaving) {
        await _local.delete(id);
      }
    }));
  }

  // Waits for the phone writes and any upload in flight. For tests, and for
  // anything that must not race them.
  Future<void> settle() async {
    await _localWrites;
    await _pushing;
  }

  void _onAccountChanged() {
    final bool now = _hasAccount.value;
    final bool attached = now && !_hadAccount;
    _hadAccount = now;

    if (attached) {
      unawaited(_adoptPhonePictures());
    }
  }

  // An email has just landed -- attached to this account, or this phone has
  // just signed in to one. Every picture the server does not have yet is
  // marked for sending. Each picture is its own row, so nothing can clash.
  Future<void> _adoptPhonePictures() async {
    await start();

    for (final ColouringPicture picture in _byId.values.toList()) {
      if (picture.onServer || picture.needsUpload) continue;

      final ColouringPicture marked = picture.copyWith(needsUpload: true);
      _byId[picture.id] = marked;
      await _writeLocal(marked);
    }
    _publish();

    await sync();
  }

  // One upload loop at a time. A save that lands while it runs asks for one
  // more pass rather than starting a second loop.
  Future<void> _pushPending() {
    if (_pushing != null) {
      _pushAgain = true;
      return _pushing!;
    }

    return _pushing = _push().whenComplete(() => _pushing = null);
  }

  Future<void> _push() async {
    do {
      _pushAgain = false;

      final List<ColouringPicture> pending = <ColouringPicture>[
        for (final ColouringPicture picture in _byId.values)
          if (picture.needsUpload) picture,
      ];

      for (final ColouringPicture picture in pending) {
        if (!_hasAccount.value) return;

        try {
          await _remote.save(picture);
        } catch (_) {
          // Logged by the store. Stop here: if one did not go, the rest will
          // not either, and they stay marked for next time.
          return;
        }

        // Only mark it sent if nobody changed it while it was in flight. If
        // they did, the newer version is still pending and goes next pass.
        final ColouringPicture? now = _byId[picture.id];
        if (now != null && now.updatedAt == picture.updatedAt) {
          final ColouringPicture sent =
              now.copyWith(needsUpload: false, onServer: true);
          _byId[sent.id] = sent;
          await _writeLocal(sent);
        } else if (now != null) {
          _byId[now.id] = now.copyWith(onServer: true);
          _pushAgain = true;
        }
      }
      _publish();
    } while (_pushAgain);
  }

  Future<void> _writeLocal(ColouringPicture picture) {
    return _localWrites = _localWrites.then((_) async {
      try {
        await _local.save(picture);
      } catch (e, s) {
        _loggerService.errorShort(e, s);
      }
    });
  }

  void _publish() {
    final List<ColouringPicture> ordered = _byId.values.toList()
      ..sort((ColouringPicture a, ColouringPicture b) =>
          b.updatedAt.compareTo(a.updatedAt));
    _pictures.value = List<ColouringPicture>.unmodifiable(ordered);
  }
}
