import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/utilities/time_format_utils.dart';

void main() {
  group('formatCountdown', () {
    test('pads the seconds to two digits', () {
      expect(TimeFormatUtils.formatCountdown(300), '5:00');
      expect(TimeFormatUtils.formatCountdown(287), '4:47');
      expect(TimeFormatUtils.formatCountdown(61), '1:01');
    });

    test('keeps the minutes place under one minute', () {
      expect(TimeFormatUtils.formatCountdown(47), '0:47');
      expect(TimeFormatUtils.formatCountdown(0), '0:00');
    });

    test('treats a negative count as finished', () {
      expect(TimeFormatUtils.formatCountdown(-1), '0:00');
    });
  });
}
