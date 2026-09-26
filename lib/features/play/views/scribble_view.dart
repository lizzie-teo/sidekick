import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/utilities/date_format_utils.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/services/scene_library.dart';
import 'package:sidekick/features/play/viewmodels/scribble_viewmodel.dart';
import 'package:sidekick/features/play/widgets/colouring_painting.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

// The Scribble button on Home. Two tabs since 26 September 2026: Colouring
// and Scribble. `_docs/briefs/colouring-book.md` is the plan.
//
// | Tab | What it is | Kept? |
// | --- | --- | --- |
// | Colouring | Pick a scene and colour it in | Yes, saved as you go |
// | Scribble | One ink, no choices, every mark fades | No. Nothing is saved, which is the point |
//
// **The tabs change by a tap, never a swipe.** A sideways swipe is also a
// line being drawn, and a page that changed tab in the middle of a stroke
// would be a screen fighting the reader's finger.
//
// **The scribble pad keeps its old rule, and colouring does not inherit it.**
// The pad has no undo, no picker and no save, because it was built as a place
// with no decisions in it. That rule protected the pad's use as a discharge,
// and it still holds on that tab. Colouring is slow and calm, and with no
// colours and no undo it would not work at all -- so the rule does not reach
// it.
//
// **It used to be the picker's Wound up face, and that was wrong.** Kjærvik &
// Bushman's 2024 meta-analysis of anger management -- roughly 154 studies,
// around 10,000 people -- splits the field cleanly: things that raise arousal
// (hitting, venting, jogging) do not reduce anger and sometimes increase it,
// while things that lower it (muscle relax-and-release, slow breathing,
// timeout) do. "Scribble as hard as you like" was on the wrong side of that
// line. That face now leads to `TightenView`. Colouring a set pattern sits
// on the calming side: it lowered anxiety more than free drawing in two small
// studies (Curry & Kasser 2005; van der Vennet & Serice 2012).
//
// The sidekick is deliberately absent from both tabs. Being watched while you
// make something is wrong even when the watching is kind.
class ScribbleView extends StatefulWidget {
  const ScribbleView({super.key});

  static const String colouringTab = 'Colouring';
  static const String scribbleTab = 'Scribble';

  static const String promise = 'Draw whatever you like. It fades away.';

  static const String yourPictures = 'Your pictures';
  static const String newPicture = 'Start a new picture';

  @override
  State<ScribbleView> createState() => _ScribbleViewState();
}

class _ScribbleViewState extends State<ScribbleView> {
  late final ScribbleViewModel _viewModel = ScribbleViewModel(
    repository: getIt<PictureRepository>(),
    sceneLibrary: getIt<SceneLibrary>(),
    deviceSettingsService: getIt<DeviceSettingsService>(),
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

  // Same exit shape as the picker: pop back to wherever the user was, or go
  // home when the screen was opened cold with nothing underneath.
  //
  // Both doors -- the X and "I'm done" -- lead here. Leaving is the only
  // thing to do when the scribbling is done, and neither door is the wrong
  // kind of leaving.
  void _leave(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = SkLayout.gutter(context);

    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<ScribbleState>(
          valueListenable: _viewModel.state,
          builder: (BuildContext context, ScribbleState state, Widget? _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(gutter, SkLayout.sm, gutter, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: SkSegmented(
                          labels: const <String>[
                            ScribbleView.colouringTab,
                            ScribbleView.scribbleTab,
                          ],
                          selected: state.tab.index,
                          onChanged: (int i) =>
                              _viewModel.setTab(ScribbleTab.values[i]),
                        ),
                      ),
                      const SizedBox(width: SkLayout.md),
                      SkCircleIconButton(
                        icon: Icons.close,
                        label: 'Close',
                        onPressed: () => _leave(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const SizedBox.shrink()
                      : state.tab == ScribbleTab.scribble
                          ? _scribble(context)
                          : _ColouringList(viewModel: _viewModel, state: state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _scribble(BuildContext context) {
    final SkColors sk = context.sk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: SkLayout.sm),

        // Full-bleed: the pad runs edge to edge, with no frame around it. A
        // box to stay inside is one more rule, and this tab is for having
        // none.
        Expanded(child: ScribblePad(color: sk.ink)),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Text(
            ScribbleView.promise,
            textAlign: TextAlign.center,
            style: SkText.caption.copyWith(
              color: SkContrast.captionOn(sk.canvas),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: SkOutlineButton(
            label: "I'm done",
            onPressed: () => _leave(context),
          ),
        ),
      ],
    );
  }
}

// The Colouring tab: the pictures already started, then the scenes.
class _ColouringList extends StatelessWidget {
  const _ColouringList({required this.viewModel, required this.state});

  final ScribbleViewModel viewModel;
  final ScribbleState state;

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
          padding: EdgeInsets.fromLTRB(gutter, SkLayout.xl, gutter, SkLayout.huge),
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
                heading(ScribbleView.yourPictures),
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
              heading(ScribbleView.newPicture),
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
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: context.sk.canvas,
      barrierLabel: 'Keep the picture',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
              const SizedBox(height: SkLayout.sm),
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
