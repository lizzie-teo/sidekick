import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/tab_page.dart';
import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/data/services/colouring_archive.dart';
import 'package:sidekick/data/services/good_things_service.dart';
import 'package:sidekick/features/me/services/data_export_service.dart';
import 'package:sidekick/features/me/views/me_view.dart';

// The Me tab: the sidekick's profile, the panic and daily settings, and the
// account actions -- including sign-out, which is why the route is guarded.
class MeModule extends FeatureModule {
  const MeModule();

  @override
  String get name => 'me';

  // Feature-local, and staying that way. The export reads the good_things
  // table but nothing outside this tab asks for a copy of everything, so it
  // is registered here rather than in service_locator.dart -- deleting this
  // feature should take the export with it and break nothing else.
  @override
  void registerServices(GetIt locator) {
    locator.registerLazySingleton<DataExportService>(
      () => DataExportService(
        loggerService: locator<LoggerService>(),
        goodThingsService: locator<GoodThingsService>(),
        deviceSettingsService: locator<DeviceSettingsService>(),
        authService: locator<AuthService>(),
        // Asked for, not assumed: the pictures belong to the play feature,
        // and a build without it still makes a copy.
        colouringArchive: locator.isRegistered<ColouringArchive>()
            ? locator<ColouringArchive>()
            : null,
      ),
    );
  }

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.me,
          name: 'me',
          pageBuilder: (context, state) =>
              TabPage.forState(state, const MeView()),
        ),
      ];
}
