import 'dart:async';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';

enum ScribbleTab { colouring, scribble }

class ScribbleState {
  // The page has nothing to show yet: which tab was last open is still
  // being read. Short, and it stops the page opening on one tab and
  // jumping to the other.
  final bool isLoading;
  final Map<String, String> errors;
  final List<String> messages;

  final ScribbleTab tab;

  // Newest first. Folded in from the repository with watch(), never written
  // here.
  final List<ColouringPicture> pictures;

  // The scenes read so far, for drawing the thumbnails. A scene still being
  // read shows as a blank tile for a moment.
  final Map<String, SceneArt> art;

  const ScribbleState({
    this.isLoading = true,
    this.errors = const <String, String>{},
    this.messages = const <String>[],
    this.tab = ScribbleTab.colouring,
    this.pictures = const <ColouringPicture>[],
    this.art = const <String, SceneArt>{},
  });

  ScribbleState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    List<String>? messages,
    ScribbleTab? tab,
    List<ColouringPicture>? pictures,
    Map<String, SceneArt>? art,
  }) {
    return ScribbleState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      tab: tab ?? this.tab,
      pictures: pictures ?? this.pictures,
      art: art ?? this.art,
    );
  }
}

// The Scribble screen: two tabs, and the list of pictures on the first.
//
// **There is no count anywhere on it.** Not of pictures, not of finished
// ones, not of how much of one is coloured. "Nothing counts" is written
// about exactly this: a tally of the reader over time.
class ScribbleViewModel extends ViewModel<ScribbleState> {
  ScribbleViewModel({
    required PictureRepository repository,
    required SceneLibrary sceneLibrary,
    required DeviceSettingsService deviceSettingsService,
  })  : _repository = repository,
        _sceneLibrary = sceneLibrary,
        _settings = deviceSettingsService,
        super(const ScribbleState());

  final PictureRepository _repository;
  final SceneLibrary _sceneLibrary;
  final DeviceSettingsService _settings;

  static const String deleteError =
      'That picture could not be deleted. Try again when you have a connection.';

  Future<void> init() async {
    final String? stored = await _settings.getString(SettingsKeys.scribbleTab);
    emit(current.copyWith(
      isLoading: false,
      tab: stored == ScribbleTab.scribble.name
          ? ScribbleTab.scribble
          : ScribbleTab.colouring,
    ));

    watch(_repository.pictures, (List<ColouringPicture> pictures) {
      emit(current.copyWith(pictures: pictures));
    });

    unawaited(_repository.sync());

    for (final ColouringScene scene in ColouringScenes.all) {
      try {
        final SceneArt art = await _sceneLibrary.load(scene);
        emit(current.copyWith(
          art: <String, SceneArt>{...current.art, scene.id: art},
        ));
      } catch (_) {
        // A scene that will not read shows as a blank tile, and opening it
        // says so on its own page.
      }
    }
  }

  void setTab(ScribbleTab tab) {
    if (tab == current.tab) return;
    emit(current.copyWith(tab: tab));
    unawaited(_settings.setString(SettingsKeys.scribbleTab, tab.name));
  }

  Future<void> deletePicture(String id) async {
    try {
      await _repository.delete(id);
      emit(current.copyWith(errors: const <String, String>{}));
    } catch (_) {
      emit(current.copyWith(errors: <String, String>{'delete': deleteError}));
    }
  }
}
