import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';

// The two places a picture can be kept. `PictureRepository` decides which.
abstract class PictureStore {
  Future<List<ColouringPicture>> list();

  Future<void> save(ColouringPicture picture);

  Future<void> delete(String id);
}

// The phone's copy: one JSON file per picture, in the app's documents folder.
//
// **A file per picture, not a database.** "No SQLite, no Drift" still holds:
// there is nothing to query, only a handful of pictures to list and open. A
// file per picture also means one damaged file costs one picture.
//
// Documents, not the temporary folder. The export writes to temporary because
// that file exists to be handed on; this one is the reader's work.
class LocalPictureStore implements PictureStore {
  LocalPictureStore({
    required LoggerService loggerService,
    Future<Directory> Function()? root,
  })  : _loggerService = loggerService,
        _root = root ?? getApplicationDocumentsDirectory;

  final LoggerService _loggerService;
  final Future<Directory> Function() _root;

  Future<Directory> _folder() async {
    final Directory folder = Directory('${(await _root()).path}/colouring');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return folder;
  }

  Future<File> _file(String id) async => File('${(await _folder()).path}/$id.json');

  @override
  Future<List<ColouringPicture>> list() async {
    final Directory folder = await _folder();
    final List<ColouringPicture> pictures = <ColouringPicture>[];

    await for (final FileSystemEntity entity in folder.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;

      try {
        pictures.add(ColouringPicture.fromJson(
          (jsonDecode(await entity.readAsString()) as Map)
              .cast<String, dynamic>(),
        ));
      } catch (e, s) {
        // One unreadable file is skipped, not fatal. The rest of the
        // reader's pictures still open.
        _loggerService.errorShort(e, s);
      }
    }

    return pictures;
  }

  @override
  Future<void> save(ColouringPicture picture) async {
    final File file = await _file(picture.id);

    // Written beside the real file and then moved over it, so a phone that
    // dies mid-write leaves the last good copy rather than half of a new one.
    final File scratch = File('${file.path}.tmp');
    await scratch.writeAsString(jsonEncode(picture.toJson()), flush: true);
    await scratch.rename(file.path);
  }

  @override
  Future<void> delete(String id) async {
    final File file = await _file(id);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

// The server's copy, in the `colourings` table. Only used for somebody with
// an email on their account -- see `PictureRepository` for why.
//
// Like `GoodThingsService`, it never filters by user on a read. Row-level
// security decides whose rows come back, and a filter in two places is one
// that can be forgotten.
class RemotePictureStore implements PictureStore {
  RemotePictureStore({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
    required AuthService authService,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient,
        _authService = authService;

  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;
  final AuthService _authService;

  static const String table = 'colourings';

  @override
  Future<List<ColouringPicture>> list() async {
    try {
      final List<Map<String, dynamic>> rows =
          await _supabaseClient.from(table).select();
      return rows
          .map((Map<String, dynamic> row) =>
              ColouringPicture.fromJson(row).copyWith(onServer: true))
          .toList();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      rethrow;
    }
  }

  @override
  Future<void> save(ColouringPicture picture) async {
    try {
      await _supabaseClient
          .from(table)
          .upsert(picture.toRow(_authService.requireUserId()));
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _supabaseClient.from(table).delete().eq('id', id);
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      rethrow;
    }
  }
}
