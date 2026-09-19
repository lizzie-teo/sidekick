import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';

import 'support/fakes.dart';

void main() {
  late FakeDeviceSettingsService settings;
  late ThemeService service;

  setUp(() {
    settings = FakeDeviceSettingsService();
    service = ThemeService(deviceSettingsService: settings);
  });

  test('a first open lands on the defaults', () async {
    await service.initialize();

    expect(service.mode.value, ThemeMode.system);
    expect(service.paletteId.value, SkPalettes.all.first.id);
    expect(service.character.value, SidekickCharacter.girl);
  });

  test('initialize reads the stored choices back', () async {
    settings.values[SettingsKeys.appearanceMode] = 'dark';
    settings.values[SettingsKeys.themePalette] = 'moss';
    settings.values[SettingsKeys.sidekickCharacter] = 'cat';

    await service.initialize();

    expect(service.mode.value, ThemeMode.dark);
    expect(service.paletteId.value, 'moss');
    expect(service.character.value, SidekickCharacter.cat);
  });

  // A renamed enum value, a removed palette, a hand-edited preference. All
  // three degrade to the default rather than throwing -- appearance is never
  // worth breaking startup over.
  test('unreadable stored values fall back to the defaults', () async {
    settings.values[SettingsKeys.appearanceMode] = 'sepia';
    settings.values[SettingsKeys.themePalette] = 'no-such-palette';
    settings.values[SettingsKeys.sidekickCharacter] = 'dragon';

    await service.initialize();

    expect(service.mode.value, ThemeMode.system);
    expect(service.paletteId.value, SkPalettes.all.first.id);
    expect(service.character.value, SidekickCharacter.girl);
  });

  test('the setters notify and write through to the device', () async {
    int notified = 0;
    service.changes.addListener(() => notified++);

    await service.setMode(ThemeMode.light);
    await service.setCharacter(SidekickCharacter.cat);

    expect(notified, 2);
    expect(settings.values[SettingsKeys.appearanceMode], 'light');
    expect(settings.values[SettingsKeys.sidekickCharacter], 'cat');
  });

  // The id is what a phone stores; two palettes sharing one would make the
  // stored choice ambiguous forever.
  test('every palette has a unique id', () {
    final ids = SkPalettes.all.map((p) => p.id).toSet();

    expect(ids.length, SkPalettes.all.length);
  });

  test('an unknown palette id is normalised before it is stored', () async {
    await service.setPalette('no-such-palette');

    expect(service.paletteId.value, SkPalettes.all.first.id);
    expect(
      settings.values[SettingsKeys.themePalette],
      SkPalettes.all.first.id,
    );
  });
}
