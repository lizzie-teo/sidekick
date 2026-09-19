import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/views/body_view.dart';
import 'package:sidekick/features/panic/views/breathing_view.dart';
import 'package:sidekick/features/panic/views/feeling_picker_view.dart';

// The centre slot of the tab bar, and the start of the panic path.
//
// Two ways into the breathing, and they are different flows.
//
// The picker's "Can't cope right now" goes to the body screen first -- one
// question, then the pacer, which reads the picked sensation's own words
// once the counted breaths are done. The tab-bar panic button goes straight
// to the pacer and is asked nothing, because it is pressed instead of
// waiting.
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
          path: Routes.body,
          name: 'body',
          builder: (context, state) => const BodyView(),
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
          ),
        ),
      ];
}
