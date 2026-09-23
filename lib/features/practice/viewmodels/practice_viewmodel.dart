import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/practice/models/practice_item.dart';

// Which half of the Practice tab is showing. That is the whole of it.
//
// **The choice is remembered on the phone.** Somebody who only ever meditates
// should not tap the toggle every single time. It lives in
// `DeviceSettingsService` rather than a Supabase table because losing it on a
// new phone costs the user one tap, which is the test that decides between the
// two.
//
// **The list itself is not state.** It is a constant in
// `PracticeCatalogue`, so there is nothing to load, nothing to fail and no
// spinner. `isLoading` therefore never goes true: the page has something to
// show on its first frame.
//
// **Nothing about what the reader has opened is recorded.** No last-opened
// row, no tally, no tick. Rule 15 -- a count turns a quiet week into a failed
// test.
class PracticeViewModel extends ViewModel<PracticeState> {
  final DeviceSettingsService _deviceSettingsService;

  PracticeViewModel({required DeviceSettingsService deviceSettingsService})
      : _deviceSettingsService = deviceSettingsService,
        super(const PracticeState());

  // Reads back the side that was showing last.
  //
  // The page is already on screen with lessons under it when this returns, so
  // a slow or failed read costs nothing -- it swaps the list a moment later or
  // leaves the default where it is. Waiting for it would hold a blank tab on
  // a storage call that nearly always answers instantly.
  Future<void> init() async {
    final String? stored =
        await _deviceSettingsService.getString(SettingsKeys.practiceSection);

    final PracticeSection section = PracticeSection.byName(stored);
    if (section == current.section) return;

    emit(current.copyWith(section: section));
  }

  // Switches side, and remembers it.
  //
  // The write is not awaited before the screen changes. The list is already in
  // memory, so making the reader wait on storage to see a tap land would be a
  // delay bought for nothing.
  void show(PracticeSection section) {
    if (section == current.section) return;

    emit(current.copyWith(section: section));
    _deviceSettingsService.setString(
      SettingsKeys.practiceSection,
      section.name,
    );
  }
}

class PracticeState {
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  // Which half of the toggle is showing.
  final PracticeSection section;

  const PracticeState({
    this.isLoading = false,
    this.errors = const {},
    this.messages = const {},
    this.section = PracticeSection.fallback,
  });

  List<PracticeItem> get items => PracticeCatalogue.of(section);

  PracticeState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
    PracticeSection? section,
  }) {
    return PracticeState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      section: section ?? this.section,
    );
  }
}
