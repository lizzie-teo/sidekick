import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/data/services/good_things_service.dart';

// Three good things -- the entry form.
//
// The screen is usable from its first frame, so there is no isLoading here.
// The two facts it reads at startup -- whether there is an email on the
// account, and whether the account offer has been made -- only matter after a
// save, which is minutes away and several taps behind a network round trip.
// Holding the form back for them would be waiting on nothing.
class GoodThingsViewModel extends ViewModel<GoodThingsViewModelState> {
  final LoggerService _loggerService;
  final GoodThingsService _goodThingsService;
  final DeviceSettingsService _deviceSettingsService;
  final AuthStateService _authStateService;

  GoodThingsViewModel({
    required LoggerService loggerService,
    required GoodThingsService goodThingsService,
    required DeviceSettingsService deviceSettingsService,
    required AuthStateService authStateService,
  })  : _loggerService = loggerService,
        _goodThingsService = goodThingsService,
        _deviceSettingsService = deviceSettingsService,
        _authStateService = authStateService,
        super(GoodThingsViewModelState());

  // How many boxes the form offers. Three is the practice, not a target --
  // one is a complete entry and the copy says so.
  static const int fieldCount = 3;

  bool _offerAnswered = false;

  Future<void> init() async {
    // Whether the account offer has already been made and answered. A No is
    // final, so this is read once and never asked about again.
    _offerAnswered =
        await _deviceSettingsService.getBool(SettingsKeys.accountOfferAnswered) ??
            false;

    // The offer is only ever for someone with no email on their account, and
    // that can change while this screen is open -- a code verified on the
    // connect screen lands here as a notification.
    watch(_authStateService.hasAccount, (bool hasAccount) {
      emit(current.copyWith(hasAccount: hasAccount));
    });
  }

  // Saves whatever was typed. Returns true when something was written, so the
  // view knows whether to clear the boxes.
  //
  // Blank boxes are dropped by the service, not counted as entries. All three
  // blank is not an error and not a round trip: the user pressed Save with
  // nothing in mind, and telling them off for it is the opposite of the point.
  Future<bool> save(List<String> lines) async {
    emit(current.copyWith(errors: const <String, String>{}));

    final bool anything = lines.any((String line) => line.trim().isNotEmpty);

    if (!anything) {
      emit(current.copyWith(
        errors: const <String, String>{
          'entries': 'Write at least one thing, however small.',
        },
      ));
      return false;
    }

    try {
      final int saved = (await _goodThingsService.save(lines)).length;

      _loggerService.debug('GoodThingsViewModel: saved $saved');

      emit(current.copyWith(
        savedCount: saved,
        messages: const <String, String>{'general': 'Saved.'},
        // The offer, once, at the first save and only to someone who has
        // nowhere to get this back from. Everything else about it is
        // deliberately quiet: no timer, no second ask, no wall.
        showAccountOffer: !current.hasAccount && !_offerAnswered,
      ));

      return true;
    } catch (e, s) {
      // Rethrowing would leave the boxes cleared over a save that did not
      // happen. The message stays on screen with the text still in it, so the
      // user can press Save again.
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        errors: const <String, String>{
          'general': 'Could not save that. Please try again.',
        },
      ));
      return false;
    }
  }

  // Both answers to the offer end here: a Yes on the way to the connect
  // screen, and a No on its own. It records that the question was asked, not
  // what was said, because the app never asks again either way.
  //
  // The standing door is the Me tab, which offers an account for as long as
  // there is no email on the account and is not gated on this flag.
  Future<void> answerAccountOffer() async {
    _offerAnswered = true;

    emit(current.copyWith(showAccountOffer: false));

    await _deviceSettingsService.setBool(
      SettingsKeys.accountOfferAnswered,
      true,
    );
  }

  // Clears the one-off confirmation so it does not sit under a second entry.
  void clearMessages() {
    emit(current.copyWith(messages: const <String, String>{}));
  }
}

class GoodThingsViewModelState {
  // How many entries the last save wrote. Zero until one lands. Drives the
  // confirmation line, which says one thing or three rather than guessing.
  final int savedCount;
  // Whether the offer of an account is on screen right now.
  final bool showAccountOffer;
  // Whether there is an email on the account. False until init() runs, and it
  // can flip while the screen is open.
  final bool hasAccount;
  final Map<String, String> errors;
  final Map<String, String> messages;

  GoodThingsViewModelState({
    this.savedCount = 0,
    this.showAccountOffer = false,
    this.hasAccount = false,
    this.errors = const <String, String>{},
    this.messages = const <String, String>{},
  });

  GoodThingsViewModelState copyWith({
    int? savedCount,
    bool? showAccountOffer,
    bool? hasAccount,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return GoodThingsViewModelState(
      savedCount: savedCount ?? this.savedCount,
      showAccountOffer: showAccountOffer ?? this.showAccountOffer,
      hasAccount: hasAccount ?? this.hasAccount,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
