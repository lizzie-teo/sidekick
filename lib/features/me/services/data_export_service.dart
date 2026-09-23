import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/utilities/date_format_utils.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/data/services/good_things_service.dart';

// "Send me a copy of everything" on the Me tab.
//
// The phone builds the document and hands it to the operating system's own
// share sheet. There is no server involved and no email address needed, which
// is the whole reason it is done this way: almost every user is anonymous, so
// a mailer on the server could only serve the few who have signed up, and the
// people most likely to want their words back are the ones who never gave an
// address.
//
// Mail is still the common answer -- the user taps Mail in the sheet and it is
// in their inbox -- but Files, Notes, AirDrop and a printer are all there too,
// and none of them cost us a service to run.
//
// A service rather than something on the viewmodel because it reaches three
// ways at once: the server for the entries, the phone for the settings, and
// the platform for the sheet. The viewmodel calls one method and reports what
// came back.
class DataExportService {
  final LoggerService _loggerService;
  final GoodThingsService _goodThingsService;
  final DeviceSettingsService _deviceSettingsService;
  final AuthService _authService;

  DataExportService({
    required LoggerService loggerService,
    required GoodThingsService goodThingsService,
    required DeviceSettingsService deviceSettingsService,
    required AuthService authService,
  })  : _loggerService = loggerService,
        _goodThingsService = goodThingsService,
        _deviceSettingsService = deviceSettingsService,
        _authService = authService;

  // Gathers, renders, writes and shares. The one call the viewmodel makes.
  //
  // `sharePositionOrigin` is the rect of the row that was tapped. iPads and
  // Macs anchor the popover to it; every other platform ignores it. Passing
  // nothing is not an error -- the sheet centres itself instead.
  Future<void> shareEverything({Rect? sharePositionOrigin}) async {
    final ExportData data = await gather();
    final Uint8List bytes = await render(data);

    // The temporary directory, not documents: this file exists to be handed
    // straight to another app. Keeping a copy in the app's own storage would
    // quietly create a second place the user's words live, which is the
    // opposite of what an export is for. The system clears it.
    final Directory directory = await getTemporaryDirectory();
    final File file = File('${directory.path}/${fileNameFor(data.madeAt)}');
    await file.writeAsBytes(bytes, flush: true);

    _loggerService.debug(
      'DataExportService: ${data.goodThings.length} entry(s), '
      '${bytes.length} bytes',
    );

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: 'application/pdf')],
        // The email subject when the user picks a mail app, and the sheet's
        // title elsewhere. It says what it is without saying what is in it:
        // a subject line is readable from a locked screen.
        subject: 'Your Sidekick copy',
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  // Everything the app holds, in one object.
  //
  // Separate from the rendering so it can be tested without a font, a
  // temporary directory or a share sheet.
  Future<ExportData> gather({DateTime? now}) async {
    final List<GoodThingModel> entries =
        await _goodThingsService.getAllEntries();

    return ExportData(
      madeAt: now ?? DateTime.now(),
      email: _authService.getUserEmail(),
      goodThings: entries,
      settings: await _gatherSettings(),
    );
  }

  // The choices on this phone, in the order the Me tab shows them, labelled
  // the way that page labels them. Raw keys would be a dump rather than a
  // copy.
  //
  // A setting that has never been touched reads back as null, and is written
  // out as the default the app is actually using -- saying nothing would make
  // the document claim less than the truth.
  Future<List<ExportSetting>> _gatherSettings() async {
    final List<ExportSetting> settings = <ExportSetting>[];

    Future<void> addString(String label, String key, String fallback) async {
      final String? value = await _deviceSettingsService.getString(key);
      settings.add(ExportSetting(label, value ?? fallback));
    }

    Future<void> addSwitch(String label, String key, bool fallback) async {
      final bool value =
          await _deviceSettingsService.getBool(key) ?? fallback;
      settings.add(ExportSetting(label, value ? 'On' : 'Off'));
    }

    Future<void> addTime(String label, String key, int fallback) async {
      final int minutes =
          await _deviceSettingsService.getInt(key) ?? fallback;
      settings.add(ExportSetting(label, clockLabel(minutes)));
    }

    await addString('Light or dark', SettingsKeys.appearanceMode, 'System');
    await addString('Colours', SettingsKeys.themePalette, 'The default one');
    await addString('Your sidekick', SettingsKeys.sidekickCharacter, 'Girl');
    await addSwitch('Daily check-in', SettingsKeys.checkInEnabled, false);
    await addTime('Check-in time', SettingsKeys.checkInMinutes,
        NotificationService.defaultCheckInMinutes);
    await addSwitch(
        'Good things nudge', SettingsKeys.goodThingsNudgeEnabled, false);
    await addTime('Nudge time', SettingsKeys.goodThingsNudgeMinutes,
        NotificationService.defaultGoodThingsMinutes);
    await addSwitch('Voice on the breathing screen',
        SettingsKeys.panicVoiceEnabled, true);

    final String? firstOpened =
        await _deviceSettingsService.getString(SettingsKeys.firstOpenedAt);
    final DateTime? opened =
        firstOpened == null ? null : DateTime.tryParse(firstOpened);
    if (opened != null) {
      settings.add(ExportSetting(
          'First opened', DateFormatUtils.fullDate(opened.toLocal())));
    }

    return settings;
  }

  // The document. A4 with generous margins, because a lot of this is read on
  // a phone screen rather than printed.
  Future<Uint8List> render(ExportData data) async {
    final pw.Font regular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
    final pw.Font bold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));

    final pw.Document document = pw.Document(
      title: 'Your Sidekick copy',
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(48, 54, 48, 54),
        build: (pw.Context context) => <pw.Widget>[
          _title(data),
          pw.SizedBox(height: 28),
          _goodThings(data),
          pw.SizedBox(height: 28),
          _settings(data),
          pw.SizedBox(height: 28),
          _whatIsNotHere(),
        ],
      ),
    );

    return Uint8List.fromList(await document.save());
  }

  pw.Widget _title(ExportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text('Your Sidekick copy',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(
          'Made ${DateFormatUtils.fullDate(data.madeAt)}'
          '${data.email == null ? '' : ' for ${data.email}'}.',
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
        ),
      ],
    );
  }

  pw.Widget _goodThings(ExportData data) {
    final List<MapEntry<DateTime, List<GoodThingModel>>> days = data.byDay;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _heading('Good things', '${data.goodThings.length} in total'),
        pw.SizedBox(height: 10),
        if (days.isEmpty)
          pw.Text('Nothing written down yet.',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700))
        else
          for (final MapEntry<DateTime, List<GoodThingModel>> day in days)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.SizedBox(height: 10),
                pw.Text(DateFormatUtils.fullDate(day.key),
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
                for (final GoodThingModel entry in day.value)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4, left: 10),
                    child: pw.Text('- ${entry.entry}',
                        style: const pw.TextStyle(fontSize: 12)),
                  ),
              ],
            ),
      ],
    );
  }

  pw.Widget _settings(ExportData data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _heading('Your settings', 'Kept on this phone only'),
        pw.SizedBox(height: 10),
        for (final ExportSetting setting in data.settings)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.SizedBox(
                  width: 190,
                  child: pw.Text(setting.label,
                      style: const pw.TextStyle(
                          fontSize: 12, color: PdfColors.grey700)),
                ),
                pw.Expanded(
                  child: pw.Text(setting.value,
                      style: const pw.TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // The closing note, and the reason this document is short.
  //
  // A copy of everything has to say what "everything" turned out to be, or a
  // thin document reads as a broken export rather than as an app that keeps
  // very little. This paragraph is the difference between the two.
  pw.Widget _whatIsNotHere() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        _heading('What is not here', 'Because it was never kept'),
        pw.SizedBox(height: 10),
        pw.Text(
          'Breathing, the panic screen, the feeling you picked, the play '
          'screens and the practice lessons record nothing at all. Nothing is '
          'timed, counted or compared between one day and the next, so there '
          'is nothing of that kind to send you. What you write down is the '
          'only thing kept, and it is all above.',
          style: const pw.TextStyle(fontSize: 12, lineSpacing: 3),
        ),
      ],
    );
  }

  pw.Widget _heading(String title, String caption) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Divider(color: PdfColors.grey300, height: 1),
        pw.SizedBox(height: 10),
        pw.Text(title,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
        pw.Text(caption,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      ],
    );
  }

  // sidekick-2026-09-20.pdf. Dashes and a sortable date, so a folder holding
  // several copies puts them in the order they were made.
  static String fileNameFor(DateTime madeAt) {
    final String month = madeAt.month.toString().padLeft(2, '0');
    final String day = madeAt.day.toString().padLeft(2, '0');

    return 'sidekick-${madeAt.year}-$month-$day.pdf';
  }

  // Minutes past midnight as "8:30 pm". The Me tab asks the platform for this
  // because it has a BuildContext; a service does not, so it is written out
  // here rather than dragged in.
  static String clockLabel(int minutes) {
    final int hour24 = minutes ~/ 60;
    final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final String minute = (minutes % 60).toString().padLeft(2, '0');

    return '$hour12:$minute ${hour24 < 12 ? 'am' : 'pm'}';
  }
}

// One labelled setting, ready to print. A label and a value rather than a key
// and a raw stored string, so the document reads like the screen it came from.
class ExportSetting {
  final String label;
  final String value;

  const ExportSetting(this.label, this.value);
}

// Everything the app holds about one person, gathered but not yet drawn.
class ExportData {
  final DateTime madeAt;
  // Null for an anonymous account, which is most of them. The document simply
  // leaves the name off rather than inventing one.
  final String? email;
  // Newest first, as the history screen shows them.
  final List<GoodThingModel> goodThings;
  final List<ExportSetting> settings;

  const ExportData({
    required this.madeAt,
    required this.email,
    required this.goodThings,
    required this.settings,
  });

  // Grouped into days, newest day first, each day's entries kept in the order
  // they arrived in.
  //
  // The grouping is done here rather than in the query because the day is a
  // local-time fact and the table only holds an instant -- two entries either
  // side of midnight UTC belong to the same evening for the person who wrote
  // them.
  List<MapEntry<DateTime, List<GoodThingModel>>> get byDay {
    final Map<DateTime, List<GoodThingModel>> days =
        <DateTime, List<GoodThingModel>>{};

    for (final GoodThingModel entry in goodThings) {
      days.putIfAbsent(entry.day, () => <GoodThingModel>[]).add(entry);
    }

    final List<DateTime> ordered = days.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    return <MapEntry<DateTime, List<GoodThingModel>>>[
      for (final DateTime day in ordered) MapEntry(day, days[day]!),
    ];
  }
}
