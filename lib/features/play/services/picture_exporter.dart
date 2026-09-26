import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/data/services/colouring_archive.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/widgets/colouring_painting.dart';

// Draws every picture for the export, with the same painting rules as the
// canvas, so the copy is the picture the reader actually made.
class PictureExporter implements ColouringArchive {
  PictureExporter({
    required LoggerService loggerService,
    required PictureRepository repository,
    required SceneLibrary sceneLibrary,
  })  : _loggerService = loggerService,
        _repository = repository,
        _sceneLibrary = sceneLibrary;

  final LoggerService _loggerService;
  final PictureRepository _repository;
  final SceneLibrary _sceneLibrary;

  @override
  Future<List<ArchivedPicture>> exportAll() async {
    await _repository.start();

    final List<ArchivedPicture> out = <ArchivedPicture>[];
    for (final ColouringPicture picture in _repository.pictures.value) {
      final ColouringScene? scene = ColouringScenes.byId(picture.sceneId);
      if (scene == null) continue;

      try {
        final SceneArt art = await _sceneLibrary.load(scene);
        out.add(ArchivedPicture(
          title: scene.title,
          updatedAt: picture.updatedAt,
          png: await ColouringPainting.toPng(
            art,
            picture,
            lineWidth: scene.lineWidth,
          ),
        ));
      } catch (e, s) {
        // One picture that will not draw does not stop the copy. The rest
        // still go.
        _loggerService.errorShort(e, s);
      }
    }
    return out;
  }
}
