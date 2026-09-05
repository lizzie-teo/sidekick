import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';

// Reads and writes the good_things table.
//
// A data service rather than a feature service. Good things is its own tab,
// but it is not the only screen that writes here: the panic recap, the
// journal's second layer and "I want to share my happiness" all lead into it,
// and Home reads from it. Owning it from a feature would mean deleting that
// feature breaks three others.
//
// Row-level security is what keeps one account out of another's entries. This
// class never filters by user on a read for that reason -- the filter is in
// the database, where it cannot be forgotten. user_id is still written on
// insert, because a row has to say whose it is before the policy can check it.
class GoodThingsService {
  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;
  final AuthService _authService;

  GoodThingsService({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
    required AuthService authService,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient,
        _authService = authService;

  static const int maxEntryLength = 500;

  // Saves one day's entries, one row each. Blank lines are dropped rather
  // than stored: the form has three boxes and most days will not fill them,
  // so an empty box is a box left alone, not an entry.
  //
  // Returns the rows that were written, so a caller knows what actually
  // landed. An empty list in means an empty list out and no round trip.
  Future<List<GoodThingModel>> save(List<String> entries) async {
    final List<String> kept = entries
        .map((String entry) => entry.trim())
        .where((String entry) => entry.isNotEmpty)
        .toList();

    if (kept.isEmpty) {
      return const <GoodThingModel>[];
    }

    try {
      // The very first save can land before the anonymous sign-in that
      // started at launch has come back -- it is deliberately not awaited
      // there so the app draws immediately. This is the point where a session
      // is genuinely required, and ensureSession() is a no-op once there is
      // one.
      await _authService.ensureSession();

      final String userId = _authService.requireUserId();

      final List<Map<String, dynamic>> rows = await _supabaseClient
          .from('good_things')
          .insert(kept
              .map((String entry) => <String, dynamic>{
                    'user_id': userId,
                    'entry': entry,
                  })
              .toList())
          .select();

      _loggerService.debug('GoodThingsService: saved ${rows.length} entry(s)');

      return rows.map(GoodThingModel.fromJson).toList();
    } catch (e, s) {
      // Rethrown, unlike a missing setting. There is no sensible way to
      // degrade a failed save: the screen has to say it did not work, or the
      // user walks away believing something was kept.
      _loggerService.errorShort(e, s);
      rethrow;
    }
  }

  // Entries written between two local times, newest first. `from` is
  // inclusive, `to` is exclusive, so a caller passes the start of one day and
  // the start of the next without worrying about the last second of the day.
  //
  // Local DateTimes in, local DateTimes out. The conversion to UTC for the
  // query happens here so no screen has to think about it.
  Future<List<GoodThingModel>> getEntriesBetween({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final List<Map<String, dynamic>> rows = await _supabaseClient
          .from('good_things')
          .select()
          .gte('created_at', from.toUtc().toIso8601String())
          .lt('created_at', to.toUtc().toIso8601String())
          .order('created_at', ascending: false);

      return rows.map(GoodThingModel.fromJson).toList();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      rethrow;
    }
  }
}
