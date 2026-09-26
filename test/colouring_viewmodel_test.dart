import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/viewmodels/colouring_viewmodel.dart';
import 'package:sidekick/features/play/widgets/colouring_canvas.dart';

import 'support/fakes.dart';

// One colouring picture, open. Constructed with fakes and asserted on its
// state, like every viewmodel here -- no service locator, no widget tree.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePictureStore phone;
  late PictureRepository repository;
  late FakeDeviceSettingsService settings;

  setUp(() {
    phone = FakePictureStore();
    repository = PictureRepository(
      loggerService: SilentLoggerService(),
      local: phone,
      remote: FakePictureStore(),
      hasAccount: ValueNotifier<bool>(false),
    );
    settings = FakeDeviceSettingsService();
  });

  Future<ColouringViewModel> open({String? sceneId, String? pictureId}) async {
    final ColouringViewModel viewModel = ColouringViewModel(
      repository: repository,
      sceneLibrary: SceneLibrary(),
      deviceSettingsService: settings,
      sceneId: sceneId,
      pictureId: pictureId,
    );
    addTearDown(viewModel.dispose);
    await viewModel.init();
    return viewModel;
  }

  PictureStroke stroke({bool erase = false}) => PictureStroke(
        regionId: 'centre',
        colour: 0xFF6DB36B,
        size: 18,
        erase: erase,
        pen: false,
        points: const <double>[400, 380, 0.5, 410, 390, 0.5],
      );

  test('a new picture opens blank, on the fill tool', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');
    final ColouringState state = viewModel.state.value;

    expect(state.isLoading, isFalse);
    expect(state.art, isNotNull);
    expect(state.picture!.isEmpty, isTrue);
    expect(state.tool, ColouringTool.fill);
    expect(state.canUndo, isFalse);
  });

  test('an unknown scene says so instead of opening', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'no_such_scene');

    expect(viewModel.state.value.errors['general'],
        ColouringViewModel.loadError);
  });

  test('a fill colours the space, and undo takes it back', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');
    final int colour = viewModel.state.value.colour.color.toARGB32();

    viewModel.fill('centre');
    expect(viewModel.state.value.picture!.fills['centre'], colour);
    expect(viewModel.state.value.canUndo, isTrue);

    viewModel.undo();
    expect(viewModel.state.value.picture!.fills, isEmpty);
    expect(viewModel.state.value.canUndo, isFalse);
  });

  test('undo walks back exactly one thing at a time', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');

    viewModel.fill('centre');
    viewModel.addStroke(stroke());
    viewModel.setColour(3);
    viewModel.fill('petal-1');

    viewModel.undo();
    expect(viewModel.state.value.picture!.fills.keys, <String>['centre']);
    expect(viewModel.state.value.picture!.strokes, hasLength(1));

    viewModel.undo();
    expect(viewModel.state.value.picture!.strokes, isEmpty);
    expect(viewModel.state.value.picture!.fills.keys, <String>['centre']);
  });

  test('filling a space with the colour it already has changes nothing',
      () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');

    viewModel.fill('centre');
    viewModel.fill('centre');
    viewModel.undo();

    expect(viewModel.state.value.picture!.fills, isEmpty);
  });

  test('the rubber, tapped, takes a fill back to paper', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');

    viewModel.fill('centre');
    viewModel.clearFill('centre');
    expect(viewModel.state.value.picture!.fills, isEmpty);
  });

  test('picking a paint with the rubber in hand hands back the brush',
      () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');

    viewModel.setTool(ColouringTool.rubber);
    viewModel.setColour(2);

    expect(viewModel.state.value.tool, ColouringTool.brush);
    expect(viewModel.state.value.colourIndex, 2);
  });

  test('a picture is saved as it is coloured', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');

    viewModel.fill('centre');
    await viewModel.saveNow();
    await repository.settle();

    final ColouringPicture saved = phone.pictures.values.single;
    expect(saved.sceneId, 'japanese_garden');
    expect(saved.fills.containsKey('centre'), isTrue);
  });

  test('opening a scene and leaving without a mark saves nothing', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');
    viewModel.dispose();
    await repository.settle();

    expect(phone.pictures, isEmpty);
  });

  test('a picture already started opens as it was left', () async {
    final ColouringViewModel first = await open(sceneId: 'japanese_garden');
    first.fill('centre');
    await first.saveNow();
    final String id = first.state.value.picture!.id;

    final ColouringViewModel again = await open(pictureId: id);
    expect(again.state.value.picture!.fills.containsKey('centre'), isTrue);
    // A fresh history: yesterday's fills are not today's to undo.
    expect(again.state.value.canUndo, isFalse);
  });

  test('the paints and the side of the rail are remembered', () async {
    final ColouringViewModel viewModel = await open(sceneId: 'japanese_garden');

    viewModel.setPalette(ColouringPalettes.byId('moody'));
    viewModel.swapRailSide();
    await pumpEventQueue();

    expect(settings.values[SettingsKeys.colouringPalette], 'moody');
    expect(settings.values[SettingsKeys.colouringRailSide], 'left');

    final ColouringViewModel again = await open(sceneId: 'japanese_garden');
    expect(again.state.value.palette.id, 'moody');
    expect(again.state.value.railOnLeft, isTrue);
  });
}
