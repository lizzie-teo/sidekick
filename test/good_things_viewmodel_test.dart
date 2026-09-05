import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/good_things/viewmodels/good_things_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late SilentLoggerService logger;
  late FakeGoodThingsService goodThings;
  late FakeDeviceSettingsService settings;
  late FakeAuthStateService authState;

  setUp(() {
    logger = SilentLoggerService();
    goodThings = FakeGoodThingsService();
    settings = FakeDeviceSettingsService();
    authState = FakeAuthStateService();
  });

  GoodThingsViewModel build() => GoodThingsViewModel(
        loggerService: logger,
        goodThingsService: goodThings,
        deviceSettingsService: settings,
        authStateService: authState,
      );

  group('save', () {
    test('writes one row per non-empty box', () async {
      final viewModel = build();
      await viewModel.init();

      final saved = await viewModel.save(<String>['Tea', '', 'A walk']);

      expect(saved, isTrue);
      expect(goodThings.entries.map((e) => e.entry), <String>['Tea', 'A walk']);
      expect(viewModel.state.value.savedCount, 2);

      viewModel.dispose();
    });

    // Pressing Save with nothing typed is not a round trip and not a telling
    // off -- but the boxes must not clear as though something was kept.
    test('all-blank is refused without touching the service', () async {
      final viewModel = build();
      await viewModel.init();

      final saved = await viewModel.save(<String>['', '   ', '']);

      expect(saved, isFalse);
      expect(goodThings.entries, isEmpty);
      expect(viewModel.state.value.errors['entries'], isNotNull);

      viewModel.dispose();
    });

    test('a failed save reports an error rather than throwing', () async {
      goodThings.saveError = Exception('offline');

      final viewModel = build();
      await viewModel.init();

      final saved = await viewModel.save(<String>['Tea']);

      expect(saved, isFalse);
      expect(viewModel.state.value.errors['general'], isNotNull);
      expect(viewModel.state.value.savedCount, 0);

      viewModel.dispose();
    });
  });

  group('the account offer', () {
    test('is made on a first save with no email on the account', () async {
      final viewModel = build();
      await viewModel.init();

      await viewModel.save(<String>['Tea']);

      expect(viewModel.state.value.showAccountOffer, isTrue);

      viewModel.dispose();
    });

    test('is never made to someone who already has an email', () async {
      authState.setHasAccount(true);

      final viewModel = build();
      await viewModel.init();

      await viewModel.save(<String>['Tea']);

      expect(viewModel.state.value.showAccountOffer, isFalse);

      viewModel.dispose();
    });

    // A No is final, and so is a Yes: the flag records that it was asked, not
    // what was said.
    test('is not made again once it has been answered', () async {
      final first = build();
      await first.init();
      await first.save(<String>['Tea']);
      await first.answerAccountOffer();

      expect(first.state.value.showAccountOffer, isFalse);
      first.dispose();

      final second = build();
      await second.init();
      await second.save(<String>['A walk']);

      expect(second.state.value.showAccountOffer, isFalse);
      second.dispose();
    });

    test('answering it is remembered on the device', () async {
      final viewModel = build();
      await viewModel.init();
      await viewModel.answerAccountOffer();

      expect(settings.values[SettingsKeys.accountOfferAnswered], isTrue);

      viewModel.dispose();
    });
  });

  // The offer follows hasAccount, which can flip while the screen is open --
  // someone leaves for the connect screen and comes back with an email.
  test('an email attached while the form is open cancels the offer', () async {
    final viewModel = build();
    await viewModel.init();

    expect(viewModel.state.value.hasAccount, isFalse);

    authState.setHasAccount(true);
    await viewModel.save(<String>['Tea']);

    expect(viewModel.state.value.showAccountOffer, isFalse);

    viewModel.dispose();
  });
}
