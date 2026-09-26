import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/utilities/date_format_utils.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/app/widgets/sk_sheet_frame.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/viewmodels/colouring_shelf_viewmodel.dart';
import 'package:sidekick/features/play/widgets/colouring_painting.dart';

// The Colouring part of the Good things tab, since 26 September 2026: the
// pictures already started, then the scenes to start one from. Tapping one
// pushes `Routes.colouring`, full screen. `_docs/briefs/colouring-book.md` is
// the plan.
//
// It was one of two tabs on its own Scribble screen, pushed from Home, until
// the same day. Colouring and Scribble moved onto the Good things tab beside
// What went well, at the user's request, so the three quiet things to do are
// one tab-bar tap away. The play feature hands both over through
// `PlayModule.tabSections`, so the good_things feature never imports this.
//
// **Colouring does not inherit the scribble pad's rule.** The pad has no
// undo, no picker and no save, because it was built as a place with no
// decisions in it. Colouring is slow and calm, and with no colours and no
// undo it would not work at all -- so the rule does not reach it. Colouring a
// set pattern lowered anxiety more than free drawing in two small studies
// (Curry & Kasser 2005; van der Vennet & Serice 2012).
//
// **There is no count anywhere on it.** Not of pictures, not of finished
// ones. "Nothing counts" is written about exactly this: a tally of the reader
// over time.
class ColouringShelf extends StatefulWidget {
  const ColouringShelf({super.key});

  static const String label = 'Colouring';

  static const String yourPictures = 'Your pictures';
  static const String newPicture = 'Start a new picture';

  @override
  State<ColouringShelf> createState() => _ColouringShelfState();
}

class _ColouringShelfState extends State<ColouringShelf> {
  late final ColouringShelfViewModel _viewModel = ColouringShelfViewModel(
    repository: getIt<PictureRepository>(),
    sceneLibrary: getIt<SceneLibrary>(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ColouringShelfState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, ColouringShelfState state, Widget? _) {
        return _ColouringList(viewModel: _viewModel, state: state);
      },
    );
  }
}

class _ColouringList extends StatelessWidget {
  const _ColouringList({required this.viewModel, required this.state});

  final ColouringShelfViewModel viewModel;
  final ColouringShelfState state;

  // Two tiles abreast on a phone, more as the screen widens. A tile is a
  // picture to recognise, so it is never shrunk below a size a thumb can
  // tell apart from its neighbour.
  static int _columns(SkWidthBand band) => switch (band) {
        SkWidthBand.compact || SkWidthBand.medium => 2,
        SkWidthBand.expanded => 3,
        SkWidthBand.wide => 4,
      };

  Future<void> _open(BuildContext context, String query, String id) async {
    await context.push(
      Uri(path: Routes.colouring, queryParameters: <String, String>{query: id})
          .toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double gutter = SkLayout.gutter(context);
    final int columns = _columns(SkLayout.bandOf(context));
    final ColouringPaper paper = ColouringPaper.of(Theme.of(context).brightness);

    // Rows of tiles rather than a fixed grid: a row is as tall as its
    // tallest tile, so the words under a picture can grow at 200% text
    // without being cut off by a height the grid picked in advance.
    Widget grid(List<Widget> tiles) => SliverList.list(
          children: <Widget>[
            for (int i = 0; i < tiles.length; i += columns)
              Padding(
                padding: const EdgeInsets.only(bottom: SkLayout.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (int j = i; j < i + columns; j++) ...<Widget>[
                      if (j > i) const SizedBox(width: SkLayout.md),
                      Expanded(
                        child: j < tiles.length ? tiles[j] : const SizedBox(),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );

    Widget heading(String text) => SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: SkLayout.md),
            child: Semantics(
              header: true,
              child: Text(text, style: SkText.cardTitle.copyWith(color: sk.ink)),
            ),
          ),
        );

    return CustomScrollView(
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            SkLayout.xl,
            gutter,
            SkLayout.huge + SkMainTabBar.clearanceOf(context),
          ),
          sliver: SliverMainAxisGroup(
            slivers: <Widget>[
              if (state.errors['delete'] != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: SkLayout.lg),
                    child: SkStatusBlock(
                      tone: SkTone.destructive,
                      label: 'Not deleted',
                      body: state.errors['delete'],
                    ),
                  ),
                ),
              if (state.pictures.isNotEmpty) ...<Widget>[
                heading(ColouringShelf.yourPictures),
                grid(<Widget>[
                  for (final ColouringPicture picture in state.pictures)
                    if (ColouringScenes.byId(picture.sceneId)
                        case final ColouringScene scene)
                      _Tile(
                        title: scene.title,
                        caption: DateFormatUtils.dayLabel(picture.updatedAt),
                        art: state.art[scene.id],
                        picture: picture,
                        paper: paper,
                        lineWidth: scene.lineWidth,
                        onOpen: () => _open(
                          context,
                          Routes.colouringPictureQuery,
                          picture.id,
                        ),
                        onDelete: () => _confirmDelete(context, picture),
                      ),
                ]),
                const SliverToBoxAdapter(child: SizedBox(height: SkLayout.xxl)),
              ],
              heading(ColouringShelf.newPicture),
              grid(<Widget>[
                for (final ColouringScene scene in ColouringScenes.all)
                  _Tile(
                    title: scene.title,
                    art: state.art[scene.id],
                    picture: ColouringPicture.blank(scene.id),
                    paper: paper,
                    lineWidth: scene.lineWidth,
                    onOpen: () =>
                        _open(context, Routes.colouringSceneQuery, scene.id),
                  ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ColouringPicture picture,
  ) async {
    final bool? delete = await DeletePictureSheet.show(context);
    if (delete == true) {
      await viewModel.deletePicture(picture.id);
    }
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    this.caption,
    required this.art,
    required this.picture,
    required this.paper,
    required this.lineWidth,
    required this.onOpen,
    this.onDelete,
  });

  final String title;
  // The day a started picture was last coloured. A new page has none.
  final String? caption;
  final SceneArt? art;
  final ColouringPicture picture;
  final ColouringPaper paper;
  final double lineWidth;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final SceneArt? art = this.art;

    final Widget thumbnail = AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: paper.paper,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sk.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: art == null
            ? null
            : RepaintBoundary(
                child: CustomPaint(
                  painter: ColouringPreviewPainter(
                    art: art,
                    picture: picture,
                    paper: paper,
                    lineWidth: lineWidth,
                  ),
                ),
              ),
      ),
    );

    return Stack(
      children: <Widget>[
        SkPressable(
          onPressed: onOpen,
          wash: sk.ink,
          borderRadius: BorderRadius.circular(16),
          semanticLabel: caption == null ? title : '$title. $caption',
          child: ExcludeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                thumbnail,
                const SizedBox(height: SkLayout.sm),
                Text(
                  title,
                  style: SkText.rowLabel.copyWith(
                    color: sk.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (caption case final String caption)
                  Text(
                    caption,
                    style: SkText.caption.copyWith(
                      color: SkContrast.captionOn(sk.canvas),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: 0,
            right: 0,
            child: SkPressable(
              onPressed: onDelete,
              wash: sk.ink,
              shape: BoxShape.circle,
              semanticLabel: 'Delete $title',
              child: SizedBox(
                width: SkLayout.tapTarget,
                height: SkLayout.tapTarget,
                child: Center(
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: sk.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: sk.border),
                    ),
                    child: ExcludeSemantics(
                      child: Icon(Icons.more_horiz_rounded,
                          size: 20, color: sk.ink),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// "Delete this picture?" The one thing on the Colouring tab that cannot be
// undone, so it is the one thing that asks first.
class DeletePictureSheet extends StatelessWidget {
  const DeletePictureSheet({super.key});

  static const String heading = 'Delete this picture?';
  static const String body = 'It cannot be brought back.';
  static const String deleteLabel = 'Delete picture';
  static const String keepLabel = 'Keep it';

  static Future<bool?> show(BuildContext context) {
    return SkSheetFrame.show<bool>(
      context,
      barrierLabel: 'Keep the picture',
      builder: (BuildContext _) => const DeletePictureSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color red = SkStatusStyle.of(context, SkTone.destructive, sk.canvas).text;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SkLayout.gutter(context),
          SkLayout.xxl,
          SkLayout.gutter(context),
          SkLayout.lg,
        ),
        child: SkLayout.readable(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  heading,
                  textAlign: TextAlign.center,
                  style: SkText.sheetHeading.copyWith(color: sk.ink),
                ),
              ),
              const SizedBox(height: SkLayout.headingGap),
              Text(
                body,
                textAlign: TextAlign.center,
                style: SkText.rowLabel.copyWith(color: sk.ink),
              ),
              const SizedBox(height: SkLayout.xl),
              SkOutlineButton(
                label: deleteLabel,
                color: red,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: SkLayout.sm),
              SkTextButton(
                label: keepLabel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
