import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';

import 'support/fakes.dart';

// Where a colouring picture is kept.
//
// | Who | Kept |
// | --- | --- |
// | No email on the account | On the phone only |
// | An email on the account | On the phone, and on the server |
//
// The rules that lose somebody's work if they are wrong are the ones pinned
// hardest: a picture never reaches the server without an account, a failed
// upload is kept and retried, and signing out never takes away a picture
// nothing else has a copy of.
void main() {
  late FakePictureStore phone;
  late FakePictureStore server;
  late ValueNotifier<bool> hasAccount;
  late PictureRepository repository;

  int tick = 0;
  ColouringPicture picture({String scene = 'japanese_garden'}) {
    tick++;
    final DateTime at = DateTime(2026, 9, 26, 12, 0, tick);
    return ColouringPicture.blank(scene, now: at).copyWith(
      fills: <String, int>{'centre': 0xFFFFCF5C},
      updatedAt: at,
    );
  }

  PictureRepository build() => PictureRepository(
        loggerService: SilentLoggerService(),
        local: phone,
        remote: server,
        hasAccount: hasAccount,
      );

  setUp(() {
    phone = FakePictureStore();
    server = FakePictureStore();
    hasAccount = ValueNotifier<bool>(false);
    repository = build();
  });

  group('with no email on the account', () {
    test('a picture is kept on the phone and never sent', () async {
      final ColouringPicture p = picture();
      await repository.save(p);
      await repository.settle();

      expect(phone.pictures.keys, <String>[p.id]);
      expect(server.pictures, isEmpty);
      expect(repository.pictures.value.single.id, p.id);
    });

    test('opening the tab does not reach for the server', () async {
      server.failing = true;
      await repository.sync();
      expect(server.saves, 0);
    });
  });

  group('with an email on the account', () {
    setUp(() => hasAccount.value = true);

    test('a picture goes to the phone and then the server', () async {
      final ColouringPicture p = picture();
      await repository.save(p);
      await repository.settle();

      expect(phone.pictures[p.id]!.onServer, isTrue);
      expect(phone.pictures[p.id]!.needsUpload, isFalse);
      expect(server.pictures.keys, <String>[p.id]);
    });

    test('offline, the picture is kept and sent later', () async {
      server.failing = true;
      final ColouringPicture p = picture();
      await repository.save(p);
      await repository.settle();

      expect(phone.pictures[p.id]!.needsUpload, isTrue);
      expect(server.pictures, isEmpty);

      server.failing = false;
      await repository.sync();
      await repository.settle();

      expect(server.pictures.keys, <String>[p.id]);
      expect(phone.pictures[p.id]!.needsUpload, isFalse);
    });

    test('a new phone brings the pictures down', () async {
      final ColouringPicture p = picture().copyWith(onServer: true);
      server.pictures[p.id] = p;

      await repository.sync();
      await repository.settle();

      expect(phone.pictures.keys, <String>[p.id]);
      expect(repository.pictures.value.single.id, p.id);
    });

    test('a newer copy on the phone is never overwritten', () async {
      final ColouringPicture older = picture();
      final ColouringPicture newer = older.copyWith(
        fills: <String, int>{'centre': 0xFF000000},
        updatedAt: older.updatedAt.add(const Duration(minutes: 1)),
      );
      server.pictures[older.id] = older;
      server.failing = true;
      await repository.save(newer);
      await repository.settle();

      server.failing = false;
      await repository.sync();
      await repository.settle();

      expect(server.pictures[older.id]!.fills['centre'], 0xFF000000);
      expect(phone.pictures[older.id]!.fills['centre'], 0xFF000000);
    });

    test('a failed delete is reported and the picture stays', () async {
      final ColouringPicture p = picture();
      await repository.save(p);
      await repository.settle();

      server.failing = true;
      await expectLater(repository.delete(p.id), throwsException);
      expect(repository.pictures.value.single.id, p.id);
      expect(phone.pictures.keys, <String>[p.id]);
    });

    test('a delete goes from both places', () async {
      final ColouringPicture p = picture();
      await repository.save(p);
      await repository.settle();

      await repository.delete(p.id);
      expect(phone.pictures, isEmpty);
      expect(server.pictures, isEmpty);
    });
  });

  // The moment the product decision turns on: pictures made before the email
  // are not left behind on the phone.
  test('attaching an email sends up the pictures made before it', () async {
    final ColouringPicture before = picture();
    await repository.save(before);
    await repository.settle();
    expect(server.pictures, isEmpty);

    hasAccount.value = true;
    // The listener starts the upload on its own; give it a moment to run.
    await pumpEventQueue();
    await repository.settle();

    expect(server.pictures.keys, <String>[before.id]);
    expect(phone.pictures[before.id]!.onServer, isTrue);
  });

  group('when the session ends', () {
    test('pictures the server has leave the phone', () async {
      hasAccount.value = true;
      final ColouringPicture p = picture();
      await repository.save(p);
      await repository.settle();

      hasAccount.value = false;
      await repository.onSessionEnded();

      expect(phone.pictures, isEmpty);
      expect(repository.pictures.value, isEmpty);
      expect(server.pictures.keys, <String>[p.id]);
    });

    test('a picture nothing else has a copy of stays', () async {
      // One that never made it up before the session went.
      hasAccount.value = true;
      server.failing = true;
      final ColouringPicture stuck = picture();
      await repository.save(stuck);
      await repository.settle();

      hasAccount.value = false;
      await repository.onSessionEnded();

      expect(phone.pictures.keys, containsAll(<String>[stuck.id]));
      expect(repository.pictures.value.map((ColouringPicture p) => p.id),
          contains(stuck.id));
    });

    test('an anonymous session ending takes nothing', () async {
      final ColouringPicture mine = picture();
      await repository.save(mine);
      await repository.settle();

      await repository.onSessionEnded();

      expect(phone.pictures.keys, <String>[mine.id]);
    });
  });

  test('the phone copy survives a restart', () async {
    final ColouringPicture p = picture();
    await repository.save(p);
    await repository.settle();

    final PictureRepository again = build();
    await again.start();
    expect(again.pictures.value.single.id, p.id);
  });

  test('pictures are listed newest first', () async {
    final ColouringPicture first = picture();
    final ColouringPicture second = picture();
    await repository.save(first);
    await repository.save(second);

    expect(
      repository.pictures.value.map((ColouringPicture p) => p.id).toList(),
      <String>[second.id, first.id],
    );
  });

  test('a picture reads back exactly as it was written', () {
    final ColouringPicture p = picture().copyWith(
      strokes: const <PictureStroke>[
        PictureStroke(
          regionId: 'centre',
          colour: 0xFF6DB36B,
          size: 18,
          erase: false,
          pen: true,
          points: <double>[10.04, 20.06, 0.5, 30, 40, 0.8],
        ),
      ],
      needsUpload: true,
    );

    final ColouringPicture back = ColouringPicture.fromJson(p.toJson());
    expect(back.id, p.id);
    expect(back.fills, p.fills);
    expect(back.needsUpload, isTrue);
    expect(back.strokes.single.pen, isTrue);
    expect(back.strokes.single.points, <double>[10, 20.1, 0.5, 30, 40, 0.8]);

    // The server row carries neither phone-only flag.
    final Map<String, dynamic> row = p.toRow('user-1');
    expect(row.containsKey('needs_upload'), isFalse);
    expect(row.containsKey('on_server'), isFalse);
    expect(row['user_id'], 'user-1');
  });
}
