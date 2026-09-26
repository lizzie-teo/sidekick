import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/data/services/colouring_archive.dart';
import 'package:sidekick/features/play/services/picture_exporter.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/picture_stores.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/views/actually_okay_view.dart';
import 'package:sidekick/features/play/views/colouring_view.dart';
import 'package:sidekick/features/play/views/low_day_view.dart';
import 'package:sidekick/features/play/views/scribble_view.dart';
import 'package:sidekick/features/play/views/tighten_view.dart';

// The three faces that are not panic, phase 5 of the build plan. Each one is
// allowed to end in nothing.
//
// All three are built: Wound up (5.1), "Tighten, and stop"; Low (5.2),
// "Somebody else, and you too"; and Actually okay (5.3), one short screen
// whose only invitation is into Three good things.
//
// **"Play" means two things in this app and this module holds both.** The
// folder is named for the three non-panic faces on the picker. The soft
// button on Home also says "Play", and since 19 September 2026 it means the
// scribble pad. Two meanings, one word. Flagged rather than fixed -- a rename
// touches the registry, the routes and every test, and buys nothing a comment
// does not.
//
// The pad is not a feeling any more. Anger research puts a hard, fast scribble
// on the arousal-raising side of the line, so the Wound up face leads to the
// muscle script instead, and the pad is reached from Home by somebody who is
// not angry. See `_docs/briefs/wound-up-tighten-and-stop.md`.
//
// **The one thing here that is saved is a colouring picture**, since 26
// September 2026. Its services are the play feature's own and registered
// below. The Me tab's export reads them through `ColouringArchive`, an
// interface in `lib/data/services/`, so deleting this feature does not break
// that one.
class PlayModule extends FeatureModule {
  const PlayModule();

  @override
  String get name => 'play';

  @override
  void registerServices(GetIt locator) {
    locator.registerLazySingleton<SceneLibrary>(() => SceneLibrary());

    locator.registerLazySingleton<PictureRepository>(
      () => PictureRepository(
        loggerService: locator<LoggerService>(),
        local: LocalPictureStore(loggerService: locator<LoggerService>()),
        remote: RemotePictureStore(
          loggerService: locator<LoggerService>(),
          supabaseClient: locator<SupabaseClient>(),
          authService: locator<AuthService>(),
        ),
        hasAccount: locator<AuthStateService>().hasAccount,
      ),
    );

    locator.registerLazySingleton<ColouringArchive>(
      () => PictureExporter(
        loggerService: locator<LoggerService>(),
        repository: locator<PictureRepository>(),
        sceneLibrary: locator<SceneLibrary>(),
      ),
    );
  }

  // Started with the app rather than with the Colouring tab, because one of
  // the moments it watches for -- an email landing on the account -- can
  // happen without the tab ever being opened. Not awaited: it reads files,
  // and the first frame does not wait for files.
  @override
  Future<void> onAppStart() async {
    unawaited(getIt<PictureRepository>().start());
  }

  // Pictures safely on the server leave the phone with the account.
  @override
  Future<void> onSessionEnded() async {
    await getIt<PictureRepository>().onSessionEnded();
  }

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.tighten,
          name: 'tighten',
          builder: (context, state) => const TightenView(),
        ),
        GoRoute(
          path: Routes.lowDay,
          name: 'low-day',
          builder: (context, state) => const LowDayView(),
        ),
        GoRoute(
          path: Routes.actuallyOkay,
          name: 'actually-okay',
          builder: (context, state) => const ActuallyOkayView(),
        ),
        GoRoute(
          path: Routes.scribble,
          name: 'scribble',
          builder: (context, state) => const ScribbleView(),
        ),
        GoRoute(
          path: Routes.colouring,
          name: 'colouring',
          builder: (context, state) => ColouringView(
            pictureId:
                state.uri.queryParameters[Routes.colouringPictureQuery],
            sceneId: state.uri.queryParameters[Routes.colouringSceneQuery],
          ),
        ),
      ];
}
