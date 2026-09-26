import 'dart:async';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/view_model.dart';

// Which part of the Good things tab is showing: What went well, Colouring or
// Scribble. That is the whole of it -- each part owns its own state.
//
// **Only a tab-bar tap opens on the part used last.** Every other way in
// names its part: Home's "What went well" tile, the picker's Good stops and
// "Actually okay" all mean the form, and Home's Scribble tile means the pad.
// Somebody who tapped "Good" on the dial and landed on a colouring page
// would have been taken somewhere they did not ask to go.
class GoodThingsTabViewModel extends ViewModel<GoodThingsTabState> {
  GoodThingsTabViewModel({
    required DeviceSettingsService deviceSettingsService,
    required List<String> sections,
    String? requested,
  })  : _settings = deviceSettingsService,
        _sections = sections,
        _requested = requested,
        super(GoodThingsTabState(
          // A named part is known at once, so there is nothing to wait for.
          isLoading: requested == null,
          section: _valid(requested, sections) ?? sections.first,
        ));

  final DeviceSettingsService _settings;
  final List<String> _sections;
  final String? _requested;

  static String? _valid(String? id, List<String> sections) =>
      id != null && sections.contains(id) ? id : null;

  // Reads back the part used last, when the way in did not name one.
  //
  // `isLoading` holds the parts off screen until it answers. The read is
  // nearly instant, and showing the form first would have it jump to a
  // colouring page under the reader's eyes.
  Future<void> init() async {
    if (_requested != null) return;

    final String? stored =
        await _settings.getString(SettingsKeys.goodThingsSection);
    emit(current.copyWith(
      isLoading: false,
      section: _valid(stored, _sections) ?? current.section,
    ));
  }

  // Switches part, and remembers it. The write is not awaited: the part is
  // already built, and waiting on storage would delay a tap for nothing.
  void show(String section) {
    if (section == current.section || !_sections.contains(section)) return;

    emit(current.copyWith(section: section));
    unawaited(_settings.setString(SettingsKeys.goodThingsSection, section));
  }
}

class GoodThingsTabState {
  // The page has nothing to show yet: which part was used last is still
  // being read.
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  final String section;

  const GoodThingsTabState({
    this.isLoading = false,
    this.errors = const <String, String>{},
    this.messages = const <String, String>{},
    this.section = GoodThingsSections.whatWentWell,
  });

  GoodThingsTabState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
    String? section,
  }) {
    return GoodThingsTabState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      section: section ?? this.section,
    );
  }
}
