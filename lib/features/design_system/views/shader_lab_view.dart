import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_breath_halo.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// A workbench for the breathing halo. **Debug builds only** -- the route is
// registered behind kDebugMode in DesignSystemModule, so it cannot ship.
//
// It exists because the alternative is judging a halo inside the breathing
// screen, which costs a lead-in and two counted breaths per look, on the one
// screen in the app that must not be broken while it is being fiddled with.
//
// The preview is the real pieces: the real scene gradient, the real
// SkBreathHalo, the real SkCharacter in whichever skin the Me tab is set to.
// Nothing here is a mock-up, so a setting that looks right here looks right
// on the screen it is going to.
//
// Two ways to drive the halo:
//
// - **Hold** -- the phase slider sets it by hand, so a single moment can be
//   looked at for as long as it takes.
// - **Breathe** -- the phase runs the pacer's own cycle: 3.9s in, 6.1s out,
//   the numbers keyed into the Breathe timeline. This is the honest test.
//   Timing is the thing a still frame cannot show.
//
// The read-out at the bottom prints the current numbers in the shape the
// widget takes them, so a setting found here can be typed straight into the
// call on the breathing screen.
class ShaderLabView extends StatefulWidget {
  const ShaderLabView({super.key});

  @override
  State<ShaderLabView> createState() => _ShaderLabViewState();
}

class _ShaderLabViewState extends State<ShaderLabView>
    with SingleTickerProviderStateMixin {
  // The pacer, copied from the Breathe timeline: 480 frames at 48fps, with
  // the exhale event at frame 186. If the Rive file's pace ever changes,
  // these are stale and the lab is lying about timing.
  static const double _inhaleSeconds = 3.875;
  static const double _exhaleSeconds = 6.125;

  final ValueNotifier<double> _phase = ValueNotifier<double>(0.0);

  SkHaloStyle _style = SkHaloStyle.soft;

  double _minRadius = SkBreathHalo.defaultMinRadius;
  double _maxRadius = SkBreathHalo.defaultMaxRadius;
  double _softness = SkBreathHalo.defaultSoftness;
  double _wobble = SkBreathHalo.defaultWobble;

  // Alpha only. The hue comes from the palette, so a halo tuned on one theme
  // is not retuned on the next -- see _innerColour.
  double _innerAlpha = 0.28;

  int _tint = 0;

  bool _isBreathing = false;

  late final Ticker _ticker = createTicker(_onTick);
  double _cycleStart = 0;

  @override
  void dispose() {
    _ticker.dispose();
    _phase.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final double now =
        elapsed.inMicroseconds / Duration.microsecondsPerSecond - _cycleStart;

    const double cycle = _inhaleSeconds + _exhaleSeconds;
    final double t = now % cycle;

    // Straight ramps, no easing. This is what the real halo gets: the shape
    // of the breath belongs to the Rive timeline, not to the halo.
    _phase.value = t < _inhaleSeconds
        ? t / _inhaleSeconds
        : 1.0 - (t - _inhaleSeconds) / _exhaleSeconds;
  }

  void _toggleBreathing(bool on) {
    setState(() => _isBreathing = on);

    if (on) {
      _cycleStart = 0;
      _ticker.start();
    } else {
      _ticker.stop();
    }
  }

  void _reset() {
    setState(() {
      _minRadius = SkBreathHalo.defaultMinRadius;
      _maxRadius = SkBreathHalo.defaultMaxRadius;
      _softness = SkBreathHalo.defaultSoftness;
      _wobble = SkBreathHalo.defaultWobble;
      _innerAlpha = 0.28;
      _tint = 0;
    });
  }

  // The tints worth trying, all taken from the palette rather than typed in
  // as hex. A halo with its own colour would break on five of the six themes.
  ({String label, Color color}) _tintOption(SkColors sk) {
    return <({String label, Color color})>[
      (label: 'Scene top', color: sk.scene.first),
      (label: 'On scene', color: sk.onScene),
      (label: 'Action', color: sk.action),
      (label: 'Canvas', color: sk.canvas),
    ][_tint];
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final ({String label, Color color}) tint = _tintOption(sk);

    final Color inner = tint.color.withValues(alpha: _innerAlpha);

    // The colour the halo fades *to*: the same hue at zero alpha, never a
    // different one. Fading towards another colour leaves a visible rim
    // where the two meet.
    final Color outer = tint.color.withValues(alpha: 0.0);

    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Scaffold(
      backgroundColor: sk.canvas,
      appBar: AppBar(
        backgroundColor: sk.canvas,
        foregroundColor: sk.ink,
        elevation: 0,
        title: Text('Shader lab', style: SkText.cardTitle),
        actions: <Widget>[
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Back to defaults',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _preview(sk, inner, outer),
          if (reduceMotion)
            Container(
              width: double.infinity,
              color: sk.surfaceMuted,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Reduce motion is on in system settings, so the halo is held '
                'at phase ${SkBreathHalo.reducedMotionPhase}. Turn it off to '
                'use these controls.',
                style: SkText.caption.copyWith(color: sk.ink),
              ),
            ),
          Expanded(child: _controls(sk, tint.label)),
        ],
      ),
    );
  }

  // The preview box. Fixed height, and the halo fills it behind her exactly
  // as it will on the breathing screen -- a Stack, so she is laid out as if
  // the halo were not there and cannot be moved by it.
  Widget _preview(SkColors sk, Color inner, Color outer) {
    return Container(
      height: 300,
      decoration: BoxDecoration(gradient: sk.sceneGradient),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SkBreathHalo(
            phase: _phase,
            style: _style,
            inner: inner,
            outer: outer,
            minRadius: _minRadius,
            maxRadius: _maxRadius,
            softness: _softness,
            wobble: _wobble,
          ),
          IgnorePointer(
            child: SkCharacter(
              skin: getIt<ThemeService>().character.value.skin,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controls(SkColors sk, String tintLabel) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: <Widget>[
        _label(sk, 'Shader'),
        SkSegmented(
          labels: const <String>['Soft', 'Warm', 'Mist'],
          selected: _style.index,
          onChanged: (int i) => setState(() => _style = SkHaloStyle.values[i]),
        ),

        const SizedBox(height: 20),

        _label(sk, 'Tint — $tintLabel'),
        SkSegmented(
          labels: const <String>['Scene', 'On scene', 'Action', 'Canvas'],
          selected: _tint,
          onChanged: (int i) => setState(() => _tint = i),
        ),

        const SizedBox(height: 20),

        // The honest test. A halo judged on a still frame is judged on the
        // one thing a breathing cue is not.
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _isBreathing,
          onChanged: _toggleBreathing,
          activeThumbColor: sk.action,
          title: Text('Run the pacer',
              style: SkText.rowLabel.copyWith(color: sk.ink)),
          subtitle: Text(
            '3.9s in, 6.1s out — the real Breathe timeline',
            style:
                SkText.caption.copyWith(color: SkContrast.captionOn(sk.canvas)),
          ),
        ),

        const SizedBox(height: 8),

        // Hand control. Disabled while the pacer runs, because a slider that
        // the pacer keeps overwriting reads as broken.
        ValueListenableBuilder<double>(
          valueListenable: _phase,
          builder: (BuildContext context, double value, _) {
            return _slider(
              sk,
              label: 'Breath phase',
              hint: '0 is fully out, 1 is fully in',
              value: value,
              min: 0,
              max: 1,
              enabled: !_isBreathing,
              onChanged: (double v) => _phase.value = v,
            );
          },
        ),

        _slider(
          sk,
          label: 'Smallest size',
          hint: 'At the bottom of an out-breath. Never zero — she keeps a halo',
          value: _minRadius,
          min: 0.05,
          max: 0.45,
          onChanged: (double v) => setState(() {
            _minRadius = v;
            if (_maxRadius < _minRadius) _maxRadius = _minRadius;
          }),
        ),

        _slider(
          sk,
          label: 'Largest size',
          hint: 'At the top of an in-breath. Above 0.46 the edge is cut off',
          value: _maxRadius,
          min: 0.05,
          max: 0.50,
          onChanged: (double v) => setState(() {
            _maxRadius = v;
            if (_minRadius > _maxRadius) _minRadius = _maxRadius;
          }),
        ),

        _slider(
          sk,
          label: 'Softness',
          hint: 'How much of the halo is spent fading. High is blurrier',
          value: _softness,
          min: 0.05,
          max: 1.0,
          onChanged: (double v) => setState(() => _softness = v),
        ),

        _slider(
          sk,
          label: 'Brightness',
          hint: 'Alpha at the centre. Start low',
          value: _innerAlpha,
          min: 0.0,
          max: 0.8,
          onChanged: (double v) => setState(() => _innerAlpha = v),
        ),

        _slider(
          sk,
          label: 'Wobble',
          hint: 'Edge ripple, so it is less geometric. 0 is a true circle',
          value: _wobble,
          min: 0.0,
          max: 0.20,
          onChanged: (double v) => setState(() => _wobble = v),
        ),

        const SizedBox(height: 24),
        _readout(sk),
        const SizedBox(height: 16),

        // maybePop rather than context.pop: the lab is reachable from the
        // router in a debug build AND from lib/preview.dart, which has no
        // GoRouter at all. This is the one call that works in both.
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _label(SkColors sk, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: SkText.sectionHeader
            .copyWith(color: SkContrast.captionOn(sk.canvas)),
      ),
    );
  }

  Widget _slider(
    SkColors sk, {
    required String label,
    required String hint,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                label,
                style: SkText.rowLabel.copyWith(
                  color: enabled ? sk.ink : sk.chevron,
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: SkText.rowLabel.copyWith(
                  color: enabled ? sk.action : sk.chevron,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
          Text(hint,
              style: SkText.tabLabel
                  .copyWith(color: SkContrast.captionOn(sk.canvas))),
          Slider.adaptive(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: sk.action,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }

  // The current setting, in the shape SkBreathHalo takes it. Read it out to
  // whoever is wiring the breathing screen, or type it in yourself.
  Widget _readout(SkColors sk) {
    final String text = 'style: SkHaloStyle.${_style.name}\n'
        'minRadius: ${_minRadius.toStringAsFixed(2)}\n'
        'maxRadius: ${_maxRadius.toStringAsFixed(2)}\n'
        'softness: ${_softness.toStringAsFixed(2)}\n'
        'wobble: ${_wobble.toStringAsFixed(2)}\n'
        'tint: ${_tintOption(sk).label} at ${_innerAlpha.toStringAsFixed(2)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: sk.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'THESE NUMBERS',
            style: SkText.sectionHeader
                .copyWith(color: SkContrast.captionOn(sk.canvas)),
          ),
          const SizedBox(height: 8),
          SelectableText(
            text,
            style: SkText.caption.copyWith(
              color: sk.ink,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
