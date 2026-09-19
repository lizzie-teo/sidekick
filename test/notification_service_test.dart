import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';

import 'support/fakes.dart';

void main() {
  late FakeDeviceSettingsService settings;
  late FakeNotificationService service;

  setUp(() {
    settings = FakeDeviceSettingsService();
    service = FakeNotificationService(deviceSettingsService: settings);
  });

  group('the toggles', () {
    test('both start off, so the app never rings uninvited', () {
      expect(service.checkInEnabled.value, isFalse);
      expect(service.goodThingsEnabled.value, isFalse);
    });

    test('turning one on stores it and re-books the alerts', () async {
      await service.setCheckInEnabled(true);

      expect(service.checkInEnabled.value, isTrue);
      expect(settings.values[SettingsKeys.checkInEnabled], isTrue);
      // The write-through alone is not enough: an alert has to be laid down
      // for the choice to mean anything.
      expect(service.refreshCount, 1);
    });

    test('the two reminders are stored separately', () async {
      await service.setCheckInEnabled(true);

      expect(settings.values[SettingsKeys.goodThingsNudgeEnabled], isNull);
    });
  });

  group('the times', () {
    test('default to 8:30 pm and 9:30 pm, far enough apart to not nag', () {
      expect(service.checkInMinutes.value, 20 * 60 + 30);
      expect(service.goodThingsMinutes.value, 21 * 60 + 30);
      expect(
        service.goodThingsMinutes.value - service.checkInMinutes.value,
        greaterThanOrEqualTo(60),
      );
    });

    test('each reminder keeps its own time', () async {
      await service.setCheckInMinutes(9 * 60);
      await service.setGoodThingsMinutes(22 * 60);

      expect(settings.values[SettingsKeys.checkInMinutes], 9 * 60);
      expect(settings.values[SettingsKeys.goodThingsNudgeMinutes], 22 * 60);
    });

    test('changing a time re-books rather than only storing it', () async {
      await service.setCheckInMinutes(9 * 60);

      expect(service.refreshCount, 1);
    });
  });

  group('the lines a run of alerts carries', () {
    // The rule the fortnight-ahead booking exists for. A notification's words
    // are fixed when it is booked, so one repeating alert would read the same
    // sentence every evening.
    test('a fortnight of alerts is fourteen different lines', () {
      int cursor = -1;
      final Set<String> seen = <String>{};

      for (int day = 0; day < NotificationService.daysBooked; day++) {
        cursor = AffirmationLines.nextIndex(cursor);
        seen.add(AffirmationLines.at(cursor));
      }

      expect(seen.length, NotificationService.daysBooked);
    });

    test('the set is long enough that a fortnight never repeats', () {
      expect(
        AffirmationLines.all.length,
        greaterThan(NotificationService.daysBooked),
      );
    });

    test('every line is unique, so no evening is ever a duplicate', () {
      expect(AffirmationLines.all.toSet().length, AffirmationLines.all.length);
    });
  });

  group('the lines themselves', () {
    // The three rules from _docs/briefs/affirmation-lines.md that a new line
    // can silently break. Each one has cost a draft.

    test('no line instructs a breath', () {
      // The one ban in this app with a randomised trial behind it: stretching
      // the in-breath is what hyperventilation looks like, and a panic reader
      // may open the app straight after reading one of these.
      for (final String line in AffirmationLines.all) {
        expect(
          line.toLowerCase(),
          isNot(contains('breath')),
          reason: 'breath instruction in: $line',
        );
        expect(line.toLowerCase(), isNot(contains('breathe')));
      }
    });

    test('no line promises anything about tomorrow', () {
      const List<String> promises = <String>[
        'this will pass',
        'it gets better',
        'tomorrow is a new day',
        'everything will be',
      ];

      for (final String line in AffirmationLines.all) {
        for (final String promise in promises) {
          expect(line.toLowerCase(), isNot(contains(promise)));
        }
      }
    });

    test('every line fits one glance', () {
      // Read on a lock screen, so a line that wraps three times is not read.
      for (final String line in AffirmationLines.all) {
        expect(
          line.split(' ').length,
          lessThanOrEqualTo(12),
          reason: 'too long to take in at a glance: $line',
        );
      }
    });
  });
}
