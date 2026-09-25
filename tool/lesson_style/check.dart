import 'dart:io';

import 'checks.dart';
import 'copy.dart';
import 'jev.dart';

// Checks the lesson copy against `.claude/skills/practice-writer/SKILL.md`.
//
//   dart run tool/lesson_style/check.dart            code checks, plus Jev if a key is set
//   dart run tool/lesson_style/check.dart --no-jev   code checks only, free and offline
//   dart run tool/lesson_style/check.dart --strict   exit 1 on anything that breaks a rule
//
// The key is read from TYPESAFE_API_KEY and never from a file in this repo.
// This is a developer tool: it is not bundled into the app, and it sends only
// the app's own lesson copy, never anything a user wrote.
//
// **It is a mirror before it is a gate.** While the rules are still being
// settled, the most useful part of the report is the "not sure" band: a line
// Jev cannot call is usually a rule worded loosely, and the fix is to the
// rule. `--strict` is for later, once the report is quiet.
//
// The full report is also written to build/lesson_style_report.md.

Future<void> main(List<String> args) async {
  final bool useJev = !args.contains('--no-jev');
  final bool strict = args.contains('--strict');
  final String? key = Platform.environment['TYPESAFE_API_KEY'];

  final List<CopyItem> items = swapDrillCopy();
  final StringBuffer out = StringBuffer()
    ..writeln('# Lesson style report')
    ..writeln()
    ..writeln('Swap drill: ${items.length} pieces of copy, '
        '${items.where((CopyItem i) => i.kind == CopyKind.prose).length} '
        'of them explaining text.')
    ..writeln();

  // ---- Code checks ----
  int codeBreaks = 0;
  out
    ..writeln('## Code checks')
    ..writeln();
  for (final CopyItem item in items) {
    final List<CodeFinding> found = <CodeFinding>[
      ...checkMarks(item.text),
      ...checkWords(item.text),
      if (item.kind == CopyKind.prose) ...checkSentences(item.text),
    ];
    for (final CodeFinding f in found) {
      codeBreaks++;
      out.writeln('- **${f.rule}** at `${item.where}`: ${f.detail}');
    }
  }
  if (codeBreaks == 0) out.writeln('Nothing found.');
  out.writeln();

  // ---- Jev checks ----
  int jevBreaks = 0;
  out
    ..writeln('## Jev checks')
    ..writeln();
  if (!useJev) {
    out.writeln('Skipped (--no-jev).');
  } else if (key == null || key.isEmpty) {
    out.writeln('Skipped: TYPESAFE_API_KEY is not set in this shell.');
  } else {
    final List<CopyItem> prose =
        items.where((CopyItem i) => i.kind == CopyKind.prose).toList();
    final JevClient jev = JevClient(key);
    final List<_Judged> judged = <_Judged>[];
    try {
      // Four at a time: fast, and gentle on the rate limit.
      for (int i = 0; i < prose.length; i += 4) {
        final List<CopyItem> batch = prose.skip(i).take(4).toList();
        judged.addAll(await Future.wait(batch.map((CopyItem item) async {
          final Map<String, double> scores = await jev.judge(
            about: swapDrillAbout,
            where: item.where,
            line: item.text,
          );
          return _Judged(item, scores);
        })));
        stderr.write('\rJev: ${judged.length}/${prose.length}');
      }
      stderr.writeln();
    } finally {
      jev.close();
    }

    final List<String> breaking = <String>[];
    final List<String> unsure = <String>[];
    for (final _Judged j in judged) {
      for (final JevRule r in jevRules) {
        final double p = j.scores[r.id]!;
        final String row = '- **${r.rule}** (${p.toStringAsFixed(2)}) at '
            '`${j.item.where}`: "${j.item.text}"';
        if (p > breaksAbove) {
          breaking.add(row);
        } else if (p > unsureAbove) {
          unsure.add(row);
        }
      }
    }
    jevBreaks = breaking.length;

    out
      ..writeln('A number is how likely Jev thinks the line breaks the rule.')
      ..writeln()
      ..writeln('### Breaks a rule (over $breaksAbove)')
      ..writeln()
      ..writeln(breaking.isEmpty ? 'Nothing found.' : breaking.join('\n'))
      ..writeln()
      ..writeln('### Not sure ($unsureAbove to $breaksAbove)')
      ..writeln()
      ..writeln('Usually the rule is worded loosely. Read the line, decide, '
          'and sharpen the rule or the question in `tool/lesson_style/jev.dart`.')
      ..writeln()
      ..writeln(unsure.isEmpty ? 'Nothing found.' : unsure.join('\n'));
  }

  final String report = out.toString();
  stdout.write(report);
  final File file = File('build/lesson_style_report.md');
  await file.parent.create(recursive: true);
  await file.writeAsString(report);
  stderr.writeln('\nReport written to ${file.path}');

  if (strict && (codeBreaks + jevBreaks) > 0) exit(1);
}

class _Judged {
  final CopyItem item;
  final Map<String, double> scores;

  const _Judged(this.item, this.scores);
}
