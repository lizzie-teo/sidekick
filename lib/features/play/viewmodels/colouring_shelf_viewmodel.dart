import 'dart:async';

import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';

class ColouringShelfState {
  // Never true: the shelf has its scene titles to show on its first frame,
  // and a picture still being read arrives a moment later.
  final bool isLoading;
  final Map<String, String> errors;
  final List<String> messages;

  // Newest first. Folded in from the repository with watch(), never written
  // here.
  final List<ColouringPicture> pictures;

  // The scenes read so far, for drawing the thumbnails. A scene still being
  // read shows as a blank tile for a moment.
  final Map<String, SceneArt> art;

  const ColouringShelfState({
    this.isLoading = false,
    this.errors = const <String, String>{},
    this.messages = const <String>[],
    this.pictures = const <ColouringPicture>[],
    this.art = const <String, SceneArt>{},
  });

  ColouringShelfState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    List<String>? messages,
    List<ColouringPicture>? pictures,
    Map<String, SceneArt>? art,
  }) {
    return ColouringShelfState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      pictures: pictures ?? this.pictures,
      art: art ?? this.art,
    );
  }
}

// The Colouring part of the Good things tab: the pictures already started,
// and the scenes to start one from.
//
// **There is no count anywhere on it.** Not of pictures, not of finished
// ones, not of how much of one is coloured. "Nothing counts" is written
// about exactly this: a tally of the reader over time.
class ColouringShelfViewModel extends ViewModel<ColouringShelfState> {
  ColouringShelfViewModel({
    required PictureRepository repository,
    required SceneLibrary sceneLibrary,
  })  : _repository = repository,
        _sceneLibrary = sceneLibrary,
        super(const ColouringShelfState());

  final PictureRepository _repository;
  final SceneLibrary _sceneLibrary;

  static const String deleteError =
      'That picture could not be deleted. Try again when you have a connection.';

  Future<void> init() async {
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

  Future<void> deletePicture(String id) async {
    try {
      await _repository.delete(id);
      emit(current.copyWith(errors: const <String, String>{}));
    } catch (_) {
      emit(current.copyWith(errors: <String, String>{'delete': deleteError}));
    }
  }
}
