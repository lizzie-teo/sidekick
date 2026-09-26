import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/services/picture_repository.dart';
import 'package:sidekick/features/play/viewmodels/colouring_viewmodel.dart';
import 'package:sidekick/features/play/widgets/colouring_shelf.dart';
import 'package:sidekick/features/play/widgets/colouring_canvas.dart';
import 'package:sidekick/features/play/widgets/colouring_tray.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

// The colouring page, driven the way a finger and a pen drive it.
//
// The pen rules are the ones worth a widget test: nothing in a screenshot
// shows that a resting palm draws, or that a pinch leaves a line where it
// started, and both are what make a colouring app feel broken.
void main() {
  const Size smallPhone = Size(375, 667);
  const Size tablet = Size(1024, 768);

  late FakePictureStore phone;

  Future<void> useSurface(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  // The scenes are read from the asset bundle, which is real I/O and does not
  // finish inside a fake-clock pump. Give it real time, then let the page
  // build.
  Future<void> letScenesLoad(WidgetTester tester) async {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
  }

  Future<PictureRepository> openScene(
    WidgetTester tester, {
    String scene = 'japanese_garden',
    TextScaler textScaler = TextScaler.noScaling,
    Size? screenSize,
  }) async {
    phone = FakePictureStore();
    await pumpApp(
      tester,
      isAuthenticated: true,
      textScaler: textScaler,
      screenSize: screenSize,
      location: '${Routes.colouring}?${Routes.colouringSceneQuery}=$scene',
      pictureRepository: PictureRepository(
        loggerService: SilentLoggerService(),
        local: phone,
        remote: FakePictureStore(),
        hasAccount: FakeAuthStateService().hasAccount,
      ),
    );
    await letScenesLoad(tester);
    return getIt<PictureRepository>();
  }

  // The Japanese garden's page in scene units: the viewBox of its SVG.
  const Size page = Size(900, 1153.1);

  // Where a point on the page is on the screen, at the canvas's fitted zoom.
  Offset onPage(WidgetTester tester, Offset scene) {
    final Rect box = tester.getRect(find.byType(ColouringCanvas));
    final double scale = (box.width / page.width) < (box.height / page.height)
        ? box.width / page.width
        : box.height / page.height;
    final Offset origin = box.topLeft +
        Offset((box.width - page.width * scale) / 2,
            (box.height - page.height * scale) / 2);
    return origin + scene * scale;
  }

  ColouringPicture current(WidgetTester tester) {
    return tester
        .widget<ColouringCanvas>(find.byType(ColouringCanvas))
        .picture;
  }

  // A point in the garden's sky, with sky for a long way to its right so a
  // brush drag stays in it, and a point near the top-left corner.
  const Offset centre = Offset(140, 290);
  const String centreId = 'space-2';
  const Offset background = Offset(60, 60);

  testWidgets('a tap fills the space under it, and the picture is kept',
      (tester) async {
    await useSurface(tester, smallPhone);
    final PictureRepository repository = await openScene(tester);

    await tester.tapAt(onPage(tester, centre));
    await tester.pump();

    expect(current(tester).fills.keys, <String>[centreId]);

    await tester.pump(ColouringViewModel.saveDelay);
    await repository.settle();
    expect(phone.pictures.values.single.fills.keys, <String>[centreId]);
  });

  testWidgets('a finger draws with the brush, inside the space it started in',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    await tester.tap(find.bySemanticsLabel('Brush'));
    await tester.pump();

    await tester.dragFrom(onPage(tester, centre), const Offset(120, 0));
    await tester.pump();

    final PictureStroke stroke = current(tester).strokes.single;
    expect(stroke.regionId, centreId);
    expect(stroke.pen, isFalse);
  });

  testWidgets('once a pen has touched the page, a finger only moves it',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    await tester.tap(find.bySemanticsLabel('Brush'));
    await tester.pump();

    final TestGesture pen = await tester.startGesture(
      onPage(tester, centre),
      kind: PointerDeviceKind.stylus,
    );
    await pen.moveBy(const Offset(40, 0));
    await pen.moveBy(const Offset(40, 0));
    await pen.up();
    await tester.pump();

    expect(current(tester).strokes.single.pen, isTrue);
    expect(
      tester.state<ColouringCanvasState>(find.byType(ColouringCanvas)).penSeen,
      isTrue,
    );

    // The resting palm.
    await tester.dragFrom(onPage(tester, background), const Offset(60, 60));
    await tester.pump();

    expect(current(tester).strokes, hasLength(1));
  });

  testWidgets('a pinch zooms, and leaves no line where it started',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    await tester.tap(find.bySemanticsLabel('Brush'));
    await tester.pump();

    final Offset middle = onPage(tester, centre);
    final TestGesture one = await tester.startGesture(middle - const Offset(30, 0));
    await one.moveBy(const Offset(-6, 0));
    final TestGesture two =
        await tester.startGesture(middle + const Offset(30, 0), pointer: 7);
    await one.moveBy(const Offset(-40, 0));
    await two.moveBy(const Offset(40, 0));
    await one.up();
    await two.up();
    await tester.pump();

    expect(current(tester).strokes, isEmpty);
    expect(
      tester.state<ColouringCanvasState>(find.byType(ColouringCanvas)).zoom,
      greaterThan(1),
    );
  });

  // At its fitted size the page cannot be pushed off centre. A little slack
  // once let a stray drag park it high on the screen.
  testWidgets('a drag does not move a page that is not zoomed in',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    await tester.dragFrom(onPage(tester, background), const Offset(0, -80));
    await tester.pump();

    expect(
      tester.state<ColouringCanvasState>(find.byType(ColouringCanvas)).pan,
      Offset.zero,
    );
  });

  // Pinching back out is easy to miss after zooming a long way in, so a
  // button brings the whole page back -- and it is there only when needed.
  testWidgets('Whole page appears when zoomed in and brings the page back',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    expect(find.bySemanticsLabel('Show the whole page'), findsNothing);

    final Offset middle = onPage(tester, centre);
    final TestGesture one =
        await tester.startGesture(middle - const Offset(30, 0));
    final TestGesture two =
        await tester.startGesture(middle + const Offset(30, 0), pointer: 7);
    await one.moveBy(const Offset(-60, 0));
    await two.moveBy(const Offset(60, 0));
    await one.up();
    await two.up();
    await tester.pump();

    final ColouringCanvasState canvas =
        tester.state<ColouringCanvasState>(find.byType(ColouringCanvas));
    expect(canvas.zoom, greaterThan(1));

    await tester.tap(find.bySemanticsLabel('Show the whole page'));
    await tester.pumpAndSettle();

    expect(canvas.zoom, 1);
    expect(canvas.pan, Offset.zero);
    expect(find.bySemanticsLabel('Show the whole page'), findsNothing);
    // The tap on the button did not fill the space under it.
    expect(current(tester).fills, isEmpty);
  });

  testWidgets('undo is off until there is something to undo',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Undo')),
      matchesSemantics(
          isButton: true, hasEnabledState: true, isEnabled: false, label: 'Undo'),
    );

    await tester.tapAt(onPage(tester, centre));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Undo'));
    await tester.pump();

    expect(current(tester).fills, isEmpty);
  });

  // Every paint in view at once: a row that scrolled hid half the set.
  testWidgets('all twelve paints are on screen on an iPhone SE',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester);

    expect(find.byType(Swatch), findsNWidgets(12));
    for (final Element swatch in find.byType(Swatch).evaluate()) {
      final Rect box = tester.getRect(find.byWidget(swatch.widget));
      expect(Offset.zero & smallPhone, predicate<Rect>((Rect r) =>
          r.contains(box.topLeft) && r.contains(box.bottomRight - const Offset(1, 1))));
    }
  });

  testWidgets('the page and every tool fit an iPhone SE at 200% text',
      (tester) async {
    await useSurface(tester, smallPhone);
    await openScene(tester, textScaler: const TextScaler.linear(2));

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Undo'), findsOneWidget);
    // The page keeps most of the height: the tools do not grow with text.
    expect(tester.getSize(find.byType(ColouringCanvas)).height,
        greaterThan(smallPhone.height * 0.55));
  });

  testWidgets('on a tablet the tools run down the side, and can swap sides',
      (tester) async {
    await useSurface(tester, tablet);
    await openScene(tester, screenSize: tablet);

    final Rect canvas = tester.getRect(find.byType(ColouringCanvas));
    final Rect tray = tester.getRect(find.byType(ColouringTray));
    expect(tray.left, greaterThanOrEqualTo(canvas.right));

    await tester.tap(find.bySemanticsLabel('Move the tools to the other side'));
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.byType(ColouringTray)).right,
      lessThanOrEqualTo(tester.getRect(find.byType(ColouringCanvas)).left),
    );
  });

  testWidgets('the list shows started pictures and never counts them',
      (tester) async {
    await useSurface(tester, smallPhone);
    final FakePictureStore store = FakePictureStore();
    final ColouringPicture started = ColouringPicture.blank('japanese_garden')
        .copyWith(fills: <String, int>{centreId: 0xFFFFCF5C});
    store.pictures[started.id] = started;

    await pumpApp(
      tester,
      isAuthenticated: true,
      location: Uri(
        path: Routes.goodThings,
        queryParameters: <String, String>{
          Routes.goodThingsSectionQuery: GoodThingsSections.colouring,
        },
      ).toString(),
      pictureRepository: PictureRepository(
        loggerService: SilentLoggerService(),
        local: store,
        remote: FakePictureStore(),
        hasAccount: FakeAuthStateService().hasAccount,
      ),
    );
    await letScenesLoad(tester);

    expect(find.text(ColouringShelf.yourPictures), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Japanese garden. Today')),
        findsOneWidget);
    // No tally, in any wording.
    expect(find.textContaining(RegExp(r'\d+ pictures?')), findsNothing);
  });

  testWidgets('deleting a picture asks first', (tester) async {
    await useSurface(tester, smallPhone);
    final FakePictureStore store = FakePictureStore();
    final ColouringPicture started = ColouringPicture.blank('japanese_garden')
        .copyWith(fills: <String, int>{centreId: 0xFFFFCF5C});
    store.pictures[started.id] = started;

    await pumpApp(
      tester,
      isAuthenticated: true,
      location: Uri(
        path: Routes.goodThings,
        queryParameters: <String, String>{
          Routes.goodThingsSectionQuery: GoodThingsSections.colouring,
        },
      ).toString(),
      pictureRepository: PictureRepository(
        loggerService: SilentLoggerService(),
        local: store,
        remote: FakePictureStore(),
        hasAccount: FakeAuthStateService().hasAccount,
      ),
    );
    await letScenesLoad(tester);

    await tester.tap(find.bySemanticsLabel('Delete Japanese garden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(DeletePictureSheet.keepLabel));
    await tester.pumpAndSettle();
    expect(store.pictures, hasLength(1));

    await tester.tap(find.bySemanticsLabel('Delete Japanese garden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(DeletePictureSheet.deleteLabel));
    await tester.pumpAndSettle();
    expect(store.pictures, isEmpty);
    expect(find.text(ColouringShelf.yourPictures), findsNothing);
  });
}
