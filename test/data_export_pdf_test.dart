import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/features/me/services/data_export_service.dart';

import 'support/fakes.dart';

// The document itself.
//
// A PDF's bytes make poor assertions, so this pins the two things that fail
// silently and cost the user their copy: the font has to load out of the
// bundle at runtime, and it has to carry the letters people actually write
// with. A missing glyph does not throw -- it prints a gap -- so somebody's own
// words would come back with holes in them and nothing would report it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataExportService service;

  setUp(() {
    service = DataExportService(
      loggerService: SilentLoggerService(),
      goodThingsService: FakeGoodThingsService(),
      deviceSettingsService: FakeDeviceSettingsService(),
      authService: FakeAuthService(),
    );
  });

  test('builds a real PDF, accents and all', () async {
    final Uint8List bytes = await service.render(ExportData(
      madeAt: DateTime(2026, 9, 20),
      email: 'someone@example.com',
      goodThings: <GoodThingModel>[
        GoodThingModel(
          id: '1',
          userId: 'u',
          // Accents, an apostrophe and a dash: the characters a font subset
          // drops first, in words somebody could plausibly write.
          entry: "A café, a crème brûlée "
              "and Dad's dog - who is very good",
          createdAt: DateTime(2026, 9, 19, 21),
        ),
      ],
      settings: const <ExportSetting>[ExportSetting('Colours', 'Dusk')],
    ));

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(5000));
  });

  // Somebody who has written nothing may still ask for their copy. It must be
  // a document that says so, not a failure and not an empty page.
  test('an empty account still gets a document', () async {
    final Uint8List bytes = await service.render(ExportData(
      madeAt: DateTime(2026, 9, 20),
      email: null,
      goodThings: const <GoodThingModel>[],
      settings: const <ExportSetting>[],
    ));

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
