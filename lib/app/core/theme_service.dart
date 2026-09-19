import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';

// How the app looks, shaped like a viewmodel one level up: three private
// notifiers, read-only outside, mutated only through the setters here.
//
// Three separate values because they are three separate choices -- light or
// dark, which colour palette, which character -- and no screen needs two of
// them to change atomically. MainApp listens to `changes` and rebuilds its
// themes; viewmodels fold the value they care about into their own state
// with watch().
//
// These live on the phone, not the server: losing them on a new phone costs
// two taps to set again, which is DeviceSettingsService's bar.
class ThemeService {
  final DeviceSettingsService _deviceSettingsService;

  ThemeService({required DeviceSettingsService deviceSettingsService})
      : _deviceSettingsService = deviceSettingsService;

  final ValueNotifier<ThemeMode> _mode =
      ValueNotifier<ThemeMode>(ThemeMode.system);
  final ValueNotifier<String> _paletteId =
      ValueNotifier<String>(SkPalettes.all.first.id);
  final ValueNotifier<SidekickCharacter> _character =
      ValueNotifier<SidekickCharacter>(SidekickCharacter.girl);

  ValueListenable<ThemeMode> get mode => _mode;
  ValueListenable<String> get paletteId => _paletteId;
  ValueListenable<SidekickCharacter> get character => _character;

  // What MainApp listens to: any of the three changing re-derives the themes.
  late final Listenable changes =
      Listenable.merge(<Listenable>[_mode, _paletteId, _character]);

  // Reads the stored choices back. Awaited before the first frame, so the app
  // never paints in the defaults and then visibly swaps -- the reads are
  // local platform calls, not network ones, so the wait is a few ms.
  //
  // Every stored value is parsed defensively: an unknown mode name, a removed
  // palette id or a renamed character falls back to the default rather than
  // throwing, the same rule DeviceSettingsService itself follows.
  Future<void> initialize() async {
    final String? mode =
        await _deviceSettingsService.getString(SettingsKeys.appearanceMode);
    final String? palette =
        await _deviceSettingsService.getString(SettingsKeys.themePalette);
    final String? character =
        await _deviceSettingsService.getString(SettingsKeys.sidekickCharacter);

    _mode.value = ThemeMode.values.asNameMap()[mode] ?? ThemeMode.system;
    _paletteId.value = SkPalettes.byId(palette).id;
    _character.value = SidekickCharacter.fromName(character);
  }

  // The setters update the notifier first, so the screen answers the tap
  // immediately, and write through after. A failed write is swallowed by
  // DeviceSettingsService -- the choice then simply does not survive a
  // restart, which is not worth an error in front of the user.

  Future<void> setMode(ThemeMode mode) async {
    _mode.value = mode;
    await _deviceSettingsService.setString(
        SettingsKeys.appearanceMode, mode.name);
  }

  Future<void> setPalette(String id) async {
    // Normalised on the way in, so an id from a stale caller can never park
    // the stored value on a palette that no longer exists.
    _paletteId.value = SkPalettes.byId(id).id;
    await _deviceSettingsService.setString(
        SettingsKeys.themePalette, _paletteId.value);
  }

  Future<void> setCharacter(SidekickCharacter character) async {
    _character.value = character;
    await _deviceSettingsService.setString(
        SettingsKeys.sidekickCharacter, character.name);
  }
}
