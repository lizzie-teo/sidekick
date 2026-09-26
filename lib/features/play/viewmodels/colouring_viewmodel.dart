import 'dart:async';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/widgets/colouring_canvas.dart';

class ColouringState {
  // The page has nothing to show yet: the scene is still being read.
  final bool isLoading;
  final Map<String, String> errors;
  final List<String> messages;

  final ColouringScene? scene;
  final SceneArt? art;
  final ColouringPicture? picture;

  final ColouringTool tool;
  final int sizeIndex;
  final ColouringPalette palette;
  final int colourIndex;
  final bool canUndo;

  // Where the tools sit when they run down the side of a wide screen.
  final bool railOnLeft;

  const ColouringState({
    this.isLoading = true,
    this.errors = const <String, String>{},
    this.messages = const <String>[],
    this.scene,
    this.art,
    this.picture,
    this.tool = ColouringTool.fill,
    this.sizeIndex = 1,
    this.palette = const ColouringPalette('', '', <NamedColour>[]),
    this.colourIndex = 0,
    this.canUndo = false,
    this.railOnLeft = false,
  });

  NamedColour get colour => palette.colours[colourIndex];

  double get brushSize => ColouringViewModel.brushSizes[sizeIndex];

  ColouringState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    List<String>? messages,
    ColouringScene? scene,
    SceneArt? art,
    ColouringPicture? picture,
    ColouringTool? tool,
    int? sizeIndex,
    ColouringPalette? palette,
    int? colourIndex,
    bool? canUndo,
    bool? railOnLeft,
  }) {
    return ColouringState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      scene: scene ?? this.scene,
      art: art ?? this.art,
      picture: picture ?? this.picture,
      tool: tool ?? this.tool,
      sizeIndex: sizeIndex ?? this.sizeIndex,
      palette: palette ?? this.palette,
      colourIndex: colourIndex ?? this.colourIndex,
      canUndo: canUndo ?? this.canUndo,
      railOnLeft: railOnLeft ?? this.railOnLeft,
    );
  }
}

// One colouring picture, open.
//
// **Undo is a list of earlier pictures.** Every picture is immutable, so the
// state before a fill or a stroke is simply the picture from a moment ago,
// kept. It lasts while the page is open and is not saved: coming back to a
// picture starts a fresh history on it.
//
// **Saving is automatic and quiet.** A change is written a moment after the
// last one, and again on leaving. There is no Save button because there is
// nothing to decide -- a picture is always kept.
class ColouringViewModel extends ViewModel<ColouringState> {
  ColouringViewModel({
    required PictureRepository repository,
    required SceneLibrary sceneLibrary,
    required DeviceSettingsService deviceSettingsService,
    String? pictureId,
    String? sceneId,
    DateTime Function()? clock,
  })  : _repository = repository,
        _sceneLibrary = sceneLibrary,
        _settings = deviceSettingsService,
        _pictureId = pictureId,
        _sceneId = sceneId,
        _clock = clock ?? DateTime.now,
        super(ColouringState(palette: ColouringPalettes.all.first));

  final PictureRepository _repository;
  final SceneLibrary _sceneLibrary;
  final DeviceSettingsService _settings;
  final String? _pictureId;
  final String? _sceneId;
  final DateTime Function() _clock;

  // In page units: a page is 800 wide. Thin is a pen's line, thick is a
  // crayon on its side.
  static const List<double> brushSizes = <double>[8, 18, 36];

  // How much can be taken back. Far more than anybody undoes in one sitting,
  // and a cap so a long session cannot hold thousands of pictures.
  static const int maxUndo = 100;

  // A moment after the last change: long enough that a burst of fills is one
  // write, short enough that closing the app a second later loses nothing.
  static const Duration saveDelay = Duration(milliseconds: 800);

  static const String loadError = 'This picture did not open. Try another.';

  final List<ColouringPicture> _history = <ColouringPicture>[];
  Timer? _saveTimer;
  ColouringPicture? _unsaved;

  Future<void> init() async {
    addTeardown(() {
      _saveTimer?.cancel();
      _flush();
    });

    final String? paletteId =
        await _settings.getString(SettingsKeys.colouringPalette);
    final String? side =
        await _settings.getString(SettingsKeys.colouringRailSide);

    await _repository.start();

    ColouringPicture? picture =
        _pictureId == null ? null : _repository.byId(_pictureId);
    final ColouringScene? scene =
        ColouringScenes.byId(picture?.sceneId ?? _sceneId ?? '');

    if (scene == null) {
      emit(current.copyWith(
        isLoading: false,
        errors: <String, String>{'general': loadError},
      ));
      return;
    }
    picture ??= ColouringPicture.blank(scene.id, now: _clock());

    try {
      final SceneArt art = await _sceneLibrary.load(scene);
      emit(current.copyWith(
        isLoading: false,
        scene: scene,
        art: art,
        picture: picture,
        palette: ColouringPalettes.byId(paletteId),
        railOnLeft: side == 'left',
      ));
    } catch (_) {
      emit(current.copyWith(
        isLoading: false,
        errors: <String, String>{'general': loadError},
      ));
    }
  }

  void setTool(ColouringTool tool) => emit(current.copyWith(tool: tool));

  void setSize(int index) => emit(current.copyWith(sizeIndex: index));

  // Picking a paint while the rubber is in hand means "I want to colour
  // again", so it hands back the tool that uses paint.
  void setColour(int index) => emit(current.copyWith(
        colourIndex: index,
        tool: current.tool == ColouringTool.rubber
            ? ColouringTool.brush
            : current.tool,
      ));

  void setPalette(ColouringPalette palette) {
    emit(current.copyWith(palette: palette));
    unawaited(_settings.setString(SettingsKeys.colouringPalette, palette.id));
  }

  void swapRailSide() {
    final bool left = !current.railOnLeft;
    emit(current.copyWith(railOnLeft: left));
    unawaited(
      _settings.setString(SettingsKeys.colouringRailSide, left ? 'left' : 'right'),
    );
  }

  void fill(String regionId) {
    final ColouringPicture? picture = current.picture;
    if (picture == null) return;

    final int colour = current.colour.color.toARGB32();
    if (picture.fills[regionId] == colour) return;

    _change(picture.copyWith(
      fills: <String, int>{...picture.fills, regionId: colour},
    ));
  }

  // The rubber, tapped: the space goes back to paper.
  void clearFill(String regionId) {
    final ColouringPicture? picture = current.picture;
    if (picture == null || !picture.fills.containsKey(regionId)) return;

    _change(picture.copyWith(
      fills: <String, int>{...picture.fills}..remove(regionId),
    ));
  }

  void addStroke(PictureStroke stroke) {
    final ColouringPicture? picture = current.picture;
    if (picture == null) return;

    _change(picture.copyWith(
      strokes: <PictureStroke>[...picture.strokes, stroke],
    ));
  }

  void undo() {
    if (_history.isEmpty) return;

    final ColouringPicture previous = _history.removeLast();
    _commit(previous.copyWith(updatedAt: _clock()));
  }

  void _change(ColouringPicture next) {
    _history.add(current.picture!);
    if (_history.length > maxUndo) _history.removeAt(0);
    _commit(next.copyWith(updatedAt: _clock()));
  }

  void _commit(ColouringPicture next) {
    emit(current.copyWith(picture: next, canUndo: _history.isNotEmpty));

    _unsaved = next;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, _flush);
  }

  // Writes the latest version, if there is one waiting. A picture undone
  // all the way back to empty is still saved -- it was started, and the list
  // should still hold it -- but a page never touched at all is not.
  Future<void> _flush() async {
    final ColouringPicture? picture = _unsaved;
    _unsaved = null;
    if (picture == null) return;

    await _repository.save(picture);
  }

  // For tests: write now rather than after the delay.
  Future<void> saveNow() {
    _saveTimer?.cancel();
    return _flush();
  }
}
