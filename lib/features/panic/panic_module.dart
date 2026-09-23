import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/views/breathing_view.dart';
import 'package:sidekick/features/panic/views/feeling_picker_view.dart';

// The centre slot of the tab bar, and the start of the panic path.
//
// **Two routes, not three.** `/panic/body` asked "What's happening in your
// body?" on a screen of its own until 23 September 2026. The four tiles are
// on the picker now, under the four faces, so the feeling and the sensation
// are answered in the same tap.
//
// Two ways into the breathing, and they are still different flows. Everything
// the picker opens starts on an introduction page with a Begin button; the
// tab-bar panic button goes straight to the pacer and is asked nothing,
// because it is pressed instead of waiting.
//
// The recap lands behind the breathing in phase 4; the three Play faces land
// beside the picker in phase 5.
class PanicModule extends FeatureModule {
  const PanicModule();

  @override
  String get name => 'panic';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.panic,
          name: 'panic',
          builder: (context, state) => const FeelingPickerView(),
        ),
        GoRoute(
          path: Routes.breathe,
          name: 'breathe',
          builder: (context, state) => BreathingView(
            // A name that matches nothing -- or no parameter at all -- is the
            // general script, so a restored route or a deep link can never
            // arrive holding words that belong to a tile nobody tapped.
            sensation: Sensation.values
                .asNameMap()[state.uri.queryParameters[Routes.sensationQuery]],

            // Present at all is enough. The picker writes `intro=1`, and
            // anything else arriving here -- a restored route, a deep link, a
            // hand-typed URL -- opens on the pacer, which is the safer thing
            // to land on by accident.
            showsIntro:
                state.uri.queryParameters.containsKey(Routes.introQuery),
          ),
        ),
      ];
}
