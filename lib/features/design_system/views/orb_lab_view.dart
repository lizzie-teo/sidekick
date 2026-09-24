import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;

import 'package:sidekick/app/widgets/sk_blob_orb.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// A workbench for the orb. **Debug builds only** -- the route is registered
// behind kDebugMode in DesignSystemModule, so it cannot ship.
//
// **It has as many controls as the orb has, and no more.** It had sliders for
// wobble, softness, crispness, swirl, rings, grain, radius and speed for one
// afternoon on 20 September 2026, and they went when those stopped being
// settings. A lab with knobs the widget does not have is a lab that finds
// settings nobody can use.
//
// Three ways to drive the level, because the orb has to hold up under all
// three and only one of them can be judged from a still frame:
//
// - **Idle** -- no level at all, the orb left to its own clocks. This is the
//   honest test of whether it looks alive with nothing happening, which is
//   most of a meditation.
// - **Hold** -- the slider sets the level by hand, so one moment can be
//   looked at for as long as it takes.
// - **Speaking** -- a fake voice envelope: syllable-rate bumps with pauses
//   between phrases, pushed through SkBlobOrbLevel exactly as a real audio
//   meter would be. This is the one that shows whether the smoothing is right.
//
// The read-out at the bottom prints the setting in the shape SkBlobOrb takes
// it, so a pairing found here can be typed straight into a screen.
class OrbLabView extends StatefulWidget {
  const OrbLabView({super.key});

  @override
  State<OrbLabView> createState() => _OrbLabViewState();
}

enum _Drive { idle, hold, speaking }

// Which of the orb's two ramp stops the swatch grid is setting. One grid and a
// target switch, rather than two grids: the slots are the same list either
// way, and eight rows of swatches would push everything else off the screen.
enum _Target { core, edge }

// The theme slots the orb may be painted from. **Hex literals are deliberately
// absent.** A colour found here has to survive all five palettes in light and
// dark, and a hex found against one of them cannot. Anything the orb needs
// that is not on this list is a missing slot in SkColors, not a reason to type
// a number into a screen.
enum _Slot {
  action('action'),
  actionSoft('actionSoft'),
  onAction('onAction'),
  panic('panic'),
  destructive('destructive'),
  ink('ink'),
  muted('muted'),
  chevron('chevron'),
  onScene('onScene'),
  canvas('canvas'),
  surface('surface'),
  surfaceMuted('surfaceMuted'),
  border('border'),
  hairline('hairline'),
  toggleOff('toggleOff'),
  sceneTop('scene[0]'),
  sceneMid('scene[1]'),
  sceneEnd('scene[2]');

  const _Slot(this.label);

  // What to type into a screen, minus the alpha. The read-out builds the rest.
  final String label;

  Color of(SkColors sk) => switch (this) {
        _Slot.action => sk.action,
        _Slot.actionSoft => sk.actionSoft,
        _Slot.onAction => sk.onAction,
        _Slot.panic => sk.panic,
        _Slot.destructive => sk.destructive,
        _Slot.ink => sk.ink,
        _Slot.muted => sk.muted,
        _Slot.chevron => sk.chevron,
        _Slot.onScene => sk.onScene,
        _Slot.canvas => sk.canvas,
        _Slot.surface => sk.surface,
        _Slot.surfaceMuted => sk.surfaceMuted,
        _Slot.border => sk.border,
        _Slot.hairline => sk.hairline,
        _Slot.toggleOff => sk.toggleOff,
        _Slot.sceneTop => sk.scene.first,
        _Slot.sceneMid => sk.scene[sk.scene.length ~/ 2],
        _Slot.sceneEnd => sk.scene.last,
      };
}

// What the orb is looked at against. Its ramp runs from black to white through
// the two stops, so the backdrop decides which end of it disappears. Judging a
// pairing on the wrong backdrop is the commonest way to pick one that vanishes
// on the screen it was meant for.
//
// Each backdrop also says whether the grey field should be flipped, because
// that is a property of the ground the orb sits on rather than a taste.
enum _Backdrop {
  canvas('Canvas', false),
  surface('Surface', false),
  scene('Scene', false),
  ink('Ink', true);

  const _Backdrop(this.label, this.inverted);

  final String label;
  final bool inverted;
}

class _OrbLabViewState extends State<OrbLabView>
    with SingleTickerProviderStateMixin {
  _Drive _drive = _Drive.idle;

  // The hand-set level, and the smoothed one the orb actually reads. Two
  // notifiers rather than one because Hold writes straight in and Speaking
  // goes through the smoother -- mixing them would hide which is which.
  final ValueNotifier<double> _held = ValueNotifier<double>(0.5);
  final SkBlobOrbLevel _spoken = SkBlobOrbLevel();

  // The defaults are the pairing the orb ships with, so the lab opens on what
  // the screens already show rather than on an arbitrary colour.
  _Target _target = _Target.core;
  _Slot _coreSlot = _Slot.action;
  _Slot _edgeSlot = _Slot.actionSoft;
  double _coreAlpha = 1.0;
  double _edgeAlpha = 1.0;
  _Backdrop _backdrop = _Backdrop.canvas;
  double _seed = SkBlobOrb.defaultSeed;

  Ticker? _ticker;

  @override
  void dispose() {
    _ticker?.dispose();
    _held.dispose();
    _spoken.dispose();
    super.dispose();
  }

  void _setDrive(_Drive next) {
    setState(() => _drive = next);

    if (next == _Drive.speaking) {
      _ticker ??= createTicker(_tick)..start();
      return;
    }

    _ticker?.dispose();
    _ticker = null;
  }

  // A stand-in for an audio meter. Syllables at about 4 a second inside a
  // phrase, then a gap. Not a sine: a voice is bursts and silence, and a
  // smoother tuned against a sine falls apart on the real thing.
  void _tick(Duration elapsed) {
    final double t = elapsed.inMicroseconds / Duration.microsecondsPerSecond;

    // 3.2s of phrase, 1.1s of pause.
    final double cycle = t % 4.3;
    if (cycle > 3.2) {
      _spoken.push(0.0);
      return;
    }

    final double syllable = math.sin(cycle * math.pi * 4.0).abs();
    final double shape = 0.55 + 0.45 * math.sin(cycle * 0.9);
    _spoken.push(syllable * shape);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The backdrop decides the flip, except that a dark theme already flips
    // every backdrop. Two flips are one flip too many, so they cancel.
    final bool darkTheme = Theme.of(context).brightness == Brightness.dark;
    final bool inverted = _backdrop.inverted ^ darkTheme;

    return Scaffold(
      backgroundColor: sk.canvas,
      appBar: AppBar(
        backgroundColor: sk.canvas,
        foregroundColor: sk.ink,
        elevation: 0,
        title: Text('Orb', style: SkText.rowLabel.copyWith(color: sk.ink)),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // A fixed square, not an Expanded. The orb's cost is per pixel,
            // and a box that changes with the panel below would change the
            // cost under you while you looked at it. The orb fills the box it
            // is given, so this square is also how big the orb is.
            Container(
              height: 320,
              width: double.infinity,
              decoration: _backdropDecoration(sk),
              child: Center(
                child: SizedBox.square(
                  dimension: 300,
                  child: SkBlobOrb(
                    core: _coreSlot.of(sk).withValues(alpha: _coreAlpha),
                    edge: _edgeSlot.of(sk).withValues(alpha: _edgeAlpha),
                    inverted: inverted,
                    seed: _seed,
                    level: switch (_drive) {
                      _Drive.idle => null,
                      _Drive.hold => _held,
                      _Drive.speaking => _spoken,
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label(sk, 'Driven by'),
                    SkSegmented(
                      labels: const <String>['Idle', 'Hold', 'Speaking'],
                      selected: _drive.index,
                      onChanged: (int i) => _setDrive(_Drive.values[i]),
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: _held,
                      builder: (BuildContext context, double value, _) {
                        return _slider(
                          sk,
                          label: 'Level',
                          hint: 'Hold mode only. It changes speed, not size.',
                          value: value,
                          min: 0.0,
                          max: 1.0,
                          enabled: _drive == _Drive.hold,
                          onChanged: (double next) => _held.value = next,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _label(sk, 'Backdrop'),
                    SkSegmented(
                      labels: _Backdrop.values
                          .map((_Backdrop b) => b.label)
                          .toList(),
                      selected: _backdrop.index,
                      onChanged: (int i) =>
                          setState(() => _backdrop = _Backdrop.values[i]),
                    ),
                    const SizedBox(height: 24),
                    _label(sk, 'Colour'),
                    Text(
                      'The ramp is black, Edge, Core, white. The two ends are '
                      'fixed: they are what let the orb reach real shadow and '
                      'real highlight. Edge is the darker of the two.',
                      style: SkText.tabLabel
                          .copyWith(color: SkContrast.captionOn(sk.canvas)),
                    ),
                    const SizedBox(height: 10),
                    SkSegmented(
                      labels: const <String>['Core', 'Edge'],
                      selected: _target.index,
                      onChanged: (int i) =>
                          setState(() => _target = _Target.values[i]),
                    ),
                    const SizedBox(height: 12),
                    _swatches(sk),
                    _slider(
                      sk,
                      label: 'Alpha',
                      hint: _target == _Target.core
                          ? 'The light stop, nearest white.'
                          : 'The dark stop, nearest black.',
                      value: _target == _Target.core ? _coreAlpha : _edgeAlpha,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (double v) => setState(() {
                        if (_target == _Target.core) {
                          _coreAlpha = v;
                        } else {
                          _edgeAlpha = v;
                        }
                      }),
                    ),
                    const SizedBox(height: 24),
                    _label(sk, 'Seed'),
                    _slider(
                      sk,
                      label: 'Seed',
                      hint: 'Where the petals start. Two orbs want two seeds.',
                      value: _seed,
                      min: 0.0,
                      max: 6.28,
                      onChanged: (double v) => setState(() => _seed = v),
                    ),
                    const SizedBox(height: 24),
                    _readout(sk),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _backdropDecoration(SkColors sk) {
    return switch (_backdrop) {
      _Backdrop.canvas => BoxDecoration(color: sk.canvas),
      _Backdrop.surface => BoxDecoration(color: sk.surface),
      _Backdrop.scene => BoxDecoration(gradient: sk.sceneGradient),
      _Backdrop.ink => BoxDecoration(color: sk.ink),
    };
  }

  // Every slot, as a circle with its name under it. The name is there because
  // two palettes' worth of slots look alike at 36pt, and a swatch picked by
  // eye has to be typed into a screen by name afterwards.
  Widget _swatches(SkColors sk) {
    final _Slot current = _target == _Target.core ? _coreSlot : _edgeSlot;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        for (final _Slot slot in _Slot.values)
          GestureDetector(
            onTap: () => setState(() {
              if (_target == _Target.core) {
                _coreSlot = slot;
              } else {
                _edgeSlot = slot;
              }
            }),
            child: SizedBox(
              width: 62,
              child: Column(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: slot.of(sk),
                      shape: BoxShape.circle,
                      // A hairline on every swatch, not only the pale ones: a
                      // ring that comes and goes reads as the selection.
                      border: Border.all(
                        color: slot == current ? sk.action : sk.border,
                        width: slot == current ? 3 : 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: SkText.tabLabel.copyWith(
                      fontSize: 9,
                      color: slot == current
                          ? sk.ink
                          : SkContrast.captionOn(sk.canvas),
                    ),
                  ),
                ],
              ),
            ),
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

  // A slot and its alpha as the line to paste. A full-strength colour prints
  // bare, so the read-out does not suggest a withValues call that does nothing.
  static String _colourCode(_Slot slot, double alpha) {
    final String base = 'sk.${slot.label}';
    if (alpha >= 0.995) return base;
    return '$base.withValues(alpha: ${alpha.toStringAsFixed(2)})';
  }

  // The current setting, in the shape SkBlobOrb takes it.
  Widget _readout(SkColors sk) {
    final String text = 'core: ${_colourCode(_coreSlot, _coreAlpha)}\n'
        'edge: ${_colourCode(_edgeSlot, _edgeAlpha)}\n'
        'seed: ${_seed.toStringAsFixed(2)}';

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
