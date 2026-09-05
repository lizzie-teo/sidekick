import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

// A Rive animation, loaded from an asset and disposed with the widget.
//
// The file loader owns native memory, so it is created once per State and
// released in dispose(). That is why this is a StatefulWidget rather than the
// one-liner it looks like it should be.
//
// While the file loads, and if it fails to load, nothing is drawn. A Rive here
// is decoration; a spinner or a red error box would be louder than the thing
// it replaces. Failures go to the console instead.
class SkRive extends StatefulWidget {
  final String asset;
  final Fit fit;
  final String? artboard;
  final String? stateMachine;

  // Handed the file's bound view model once it has loaded. That instance is
  // how the outside world drives the animation: fire a trigger on it, or set a
  // boolean, and the state machine reacts.
  final void Function(ViewModelInstance instance)? onReady;

  const SkRive({
    super.key,
    required this.asset,
    this.fit = Fit.contain,
    this.artboard,
    this.stateMachine,
    this.onReady,
  });

  @override
  State<SkRive> createState() => _SkRiveState();
}

class _SkRiveState extends State<SkRive> {
  // Factory.flutter renders through Flutter's own painter rather than Rive's
  // render context. Right for a small graphic sitting inside a normal page,
  // and the only one that works under flutter_test, which has no context.
  late final FileLoader _fileLoader = FileLoader.fromAsset(
    widget.asset,
    riveFactory: Factory.flutter,
  );

  @override
  void dispose() {
    _fileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: _fileLoader,
      // Bind the file's own view model, so its triggers and booleans are
      // reachable. Without this the animation plays but nothing can talk to it.
      dataBind: DataBind.auto(),
      artboardSelector: widget.artboard == null
          ? const ArtboardDefault()
          : ArtboardSelector.byName(widget.artboard!),
      stateMachineSelector: widget.stateMachine == null
          ? const StateMachineDefault()
          : StateMachineSelector.byName(widget.stateMachine!),
      // Honour the platform "reduce motion" setting by holding the first frame
      // instead of playing. It is also what lets a widget test settle, since a
      // looping animation never stops scheduling frames.
      onLoaded: (loaded) {
        if (MediaQuery.disableAnimationsOf(context)) {
          loaded.controller.active = false;
        }
        final ViewModelInstance? instance = loaded.viewModelInstance;
        if (instance != null) {
          widget.onReady?.call(instance);
        }
      },
      onFailed: (error, stack) {
        debugPrint('Rive failed to load ${widget.asset}: $error');
        debugPrint('Stack trace: $stack');
      },
      builder: (context, state) => switch (state) {
        RiveLoading() => const SizedBox.shrink(),
        RiveFailed() => const SizedBox.shrink(),
        RiveLoaded() =>
          RiveWidget(controller: state.controller, fit: widget.fit),
      },
    );
  }
}
