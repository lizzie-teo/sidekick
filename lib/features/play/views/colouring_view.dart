import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/viewmodels/colouring_viewmodel.dart';
import 'package:sidekick/features/play/widgets/colouring_canvas.dart';
import 'package:sidekick/features/play/widgets/colouring_tray.dart';

// One colouring picture, full screen.
//
// **The tabs are not on this page.** Every point of height goes to the
// picture; the X goes back to the list.
//
// | Width | Tools |
// | --- | --- |
// | Under 600 | Along the bottom, in thumb reach |
// | 600 and over | Down one side, right by default, and a button moves them |
//
// The switch is the width band, not the device: an iPad in split view is a
// phone-width window and gets the phone layout.
//
// **A tablet may turn sideways here, and only here.** The app is held
// upright everywhere else, and colouring on an iPad is often done with it
// flat or propped on its side. The lock goes back on when the page closes.
class ColouringView extends StatefulWidget {
  const ColouringView({super.key, this.pictureId, this.sceneId});

  final String? pictureId;
  final String? sceneId;

  @override
  State<ColouringView> createState() => _ColouringViewState();
}

class _ColouringViewState extends State<ColouringView> {
  late final ColouringViewModel _viewModel = ColouringViewModel(
    repository: getIt<PictureRepository>(),
    sceneLibrary: getIt<SceneLibrary>(),
    deviceSettingsService: getIt<DeviceSettingsService>(),
    pictureId: widget.pictureId,
    sceneId: widget.sceneId,
  );

  bool _unlockedRotation = false;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_unlockedRotation && MediaQuery.sizeOf(context).shortestSide >= 600) {
      _unlockedRotation = true;
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }
  }

  @override
  void dispose() {
    if (_unlockedRotation) {
      SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    _viewModel.dispose();
    super.dispose();
  }

  void _leave(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(
        Uri(
          path: Routes.goodThings,
          queryParameters: <String, String>{
            Routes.goodThingsSectionQuery: GoodThingsSections.colouring,
          },
        ).toString(),
      );
    }
  }

  Future<void> _pickPalette(ColouringState state) async {
    final ColouringPalette? picked =
        await PalettePickerSheet.show(context, state.palette);
    if (picked != null) _viewModel.setPalette(picked);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      // Not the bottom: the tools run down into the home-indicator strip, so
      // their surface reaches the foot of the screen with no band of page
      // colour under it. The tools pad themselves above the indicator.
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<ColouringState>(
          valueListenable: _viewModel.state,
          builder: (BuildContext context, ColouringState state, Widget? _) {
            final bool wide =
                SkLayout.bandOf(context).index >= SkWidthBand.expanded.index;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    SkLayout.gutter(context),
                    SkLayout.sm,
                    SkLayout.gutter(context),
                    SkLayout.sm,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            state.scene?.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: SkText.h1.copyWith(color: sk.ink),
                          ),
                        ),
                      ),
                      const SizedBox(width: SkLayout.md),
                      SkCircleIconButton(
                        icon: Icons.close,
                        label: 'Close',
                        onPressed: () => _leave(context),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _body(context, state, wide)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ColouringState state, bool wide) {
    final String? error = state.errors['general'];
    if (error != null) {
      return Padding(
        padding: EdgeInsets.all(SkLayout.gutter(context)),
        child: Align(
          alignment: Alignment.topCenter,
          child: SkStatusBlock(tone: SkTone.info, label: error),
        ),
      );
    }

    if (state.isLoading || state.art == null || state.picture == null) {
      return const SizedBox.shrink();
    }

    final SkColors sk = context.sk;

    final Widget canvas = ColouringCanvas(
      art: state.art!,
      picture: state.picture!,
      paper: ColouringPaper.of(Theme.of(context).brightness),
      lineWidth: state.scene!.lineWidth,
      tool: state.tool,
      colour: state.colour.color,
      brushSize: state.brushSize,
      onFill: _viewModel.fill,
      onClear: _viewModel.clearFill,
      onStroke: _viewModel.addStroke,
    );

    final Widget tray = ColouringTray(
      vertical: wide,
      tool: state.tool,
      onTool: _viewModel.setTool,
      sizeIndex: state.sizeIndex,
      onSize: _viewModel.setSize,
      palette: state.palette,
      colourIndex: state.colourIndex,
      onColour: _viewModel.setColour,
      onPickPalette: () => _pickPalette(state),
      canUndo: state.canUndo,
      onUndo: _viewModel.undo,
      onSwapSide: wide ? _viewModel.swapRailSide : null,
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(child: canvas),
          DecoratedBox(
            decoration: BoxDecoration(
              color: sk.surface,
              border: Border(top: BorderSide(color: sk.hairline)),
            ),
            child: SafeArea(top: false, child: tray),
          ),
        ],
      );
    }

    final Widget rail = DecoratedBox(
      decoration: BoxDecoration(
        color: sk.surface,
        border: Border(
          left: state.railOnLeft
              ? BorderSide.none
              : BorderSide(color: sk.hairline),
          right: state.railOnLeft
              ? BorderSide(color: sk.hairline)
              : BorderSide.none,
        ),
      ),
      child: SafeArea(top: false, child: tray),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: state.railOnLeft
          ? <Widget>[rail, Expanded(child: SafeArea(top: false, child: canvas))]
          : <Widget>[Expanded(child: SafeArea(top: false, child: canvas)), rail],
    );
  }
}
