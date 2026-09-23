import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/features/me/services/data_export_service.dart';

import 'support/fakes.dart';

// What goes into "Send me a copy of everything".
//
// The gathering is tested, not the drawing. A PDF's bytes say nothing useful
// in an assertion, and the thing that can actually go wrong is the document
// quietly leaving something out.
void main() {
  late FakeGoodThingsService goodThings;
  late FakeDeviceSettingsService settings;
  late FakeAuthService auth;
  late DataExportService service;

  setUp(() {
    goodThings = FakeGoodThingsService();
    settings = FakeDeviceSettingsService();
    auth = FakeAuthService();
    service = DataExportService(
      loggerService: SilentLoggerService(),
      goodThingsService: goodThings,
      deviceSettingsService: settings,
      authService: auth,
    );
  });

  // The whole point of the feature. A copy that stopped at a page, or at a
  // month, would be a copy of some of it.
  test('gathers every entry, however old', () async {
    goodThings.saveAt = DateTime(2024, 1, 2, 9);
    await goodThings.save(<String>['The oldest one']);
    goodThings.saveAt = DateTime(2026, 9, 19, 21);
    await goodThings.save(<String>['Last night']);

    final ExportData data = await service.gather();

    expect(data.goodThings.length, 2);
    expect(data.goodThings.first.entry, 'Last night');
  });

  test('an account with no email leaves the name off rather than inventing one',
      () async {
    auth.userEmail = null;

    final ExportData data = await service.gather();

    expect(data.email, isNull);
  });

  // A setting nobody has touched still has a value the app is using. Leaving
  // it out would make the document claim less than the truth.
  test('an untouched setting is written out as the default in force',
      () async {
    final ExportData data = await service.gather();

    final ExportSetting voice = data.settings.firstWhere(
        (ExportSetting s) => s.label == 'Voice on the breathing screen');

    expect(voice.value, 'On');
  });

  test('a setting the user changed is written out as they left it', () async {
    settings.values[SettingsKeys.panicVoiceEnabled] = false;
    settings.values[SettingsKeys.checkInEnabled] = true;
    settings.values[SettingsKeys.checkInMinutes] = 7 * 60 + 5;

    final ExportData data = await service.gather();

    String valueOf(String label) =>
        data.settings.firstWhere((ExportSetting s) => s.label == label).value;

    expect(valueOf('Voice on the breathing screen'), 'Off');
    expect(valueOf('Daily check-in'), 'On');
    expect(valueOf('Check-in time'), '7:05 am');
  });

  // The table holds an instant, not a day. Two entries either side of midnight
  // UTC belong to the same evening for the person who wrote them, so the
  // grouping is done in local time on the way out.
  group('grouping into days', () {
    test('newest day first, and a day holds everything written on it', () {
      final ExportData data = ExportData(
        madeAt: DateTime(2026, 9, 20, 10),
        email: null,
        goodThings: <GoodThingModel>[
          _entry('Tuesday evening', DateTime(2026, 9, 15, 22, 30)),
          _entry('Monday, later', DateTime(2026, 9, 14, 23, 50)),
          _entry('Monday, earlier', DateTime(2026, 9, 14, 8, 10)),
        ],
        settings: const <ExportSetting>[],
      );

      final List<MapEntry<DateTime, List<GoodThingModel>>> days = data.byDay;

      expect(days.length, 2);
      expect(days.first.key, DateTime(2026, 9, 15));
      expect(days.first.value.length, 1);
      expect(days.last.value.length, 2);
    });

    test('no entries is no days, not an empty one', () {
      final ExportData data = ExportData(
        madeAt: DateTime(2026, 9, 20),
        email: null,
        goodThings: const <GoodThingModel>[],
        settings: const <ExportSetting>[],
      );

      expect(data.byDay, isEmpty);
    });
  });

  // A folder holding several copies should put them in the order they were
  // made, which a sortable date does and "20 September" does not.
  test('the file name sorts by date', () {
    expect(DataExportService.fileNameFor(DateTime(2026, 9, 5)),
        'sidekick-2026-09-05.pdf');
    expect(DataExportService.fileNameFor(DateTime(2026, 12, 31)),
        'sidekick-2026-12-31.pdf');
  });

  // Midnight and noon are where a 12-hour clock goes wrong.
  test('times read the way the Me tab writes them', () {
    expect(DataExportService.clockLabel(0), '12:00 am');
    expect(DataExportService.clockLabel(12 * 60), '12:00 pm');
    expect(DataExportService.clockLabel(20 * 60 + 30), '8:30 pm');
    expect(DataExportService.clockLabel(9 * 60 + 5), '9:05 am');
  });
}

GoodThingModel _entry(String text, DateTime at) => GoodThingModel(
      id: text,
      userId: 'user-1',
      entry: text,
      createdAt: at,
    );
