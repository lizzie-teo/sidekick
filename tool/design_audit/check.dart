import 'dart:io';

// Checks that screens take their styling from the design system, not from
// numbers and widgets typed at the use site. The skill that drives it is
// `.claude/skills/design-audit/SKILL.md`.
//
//   dart run tool/design_audit/check.dart                 the whole of lib/
//   dart run tool/design_audit/check.dart --changed       only files changed since HEAD
//   dart run tool/design_audit/check.dart lib/features/me one folder or file
//   dart run tool/design_audit/check.dart --strict        exit 1 on any "break"
//
// **It covers what `test/accessibility_source_test.dart` does not.** That test
// already gates hex colours, `Colors.*`, font sizes and typefaces, and it is
// the place those rules live. This tool adds the rest of the design system:
// spacing, corner radii, the Sk widgets, and `Theme.of` reached around them.
//
// **WCAG is split in two, and this tool is the second half.**
// `test/contrast_test.dart` proves the maths: every palette pair, every
// `captionOn` answer, every status tone clears 4.5:1. That proves nothing
// about a screen that never calls them. The `contrast` rule here checks the
// use site -- which colour a `Text` or an `Icon` actually picked -- because
// a caption set in `border` passes every test in the repo and still cannot
// be read.
//
// Two levels, because the app is half converted:
//
//   break  wrong on any screen, fix it
//   check  probably wrong, look at it. `SkLayout` is newer than most screens,
//          so a number on the grid is old, not careless. Convert the file
//          you are already in, not the whole app.

// Files that draw pictures rather than lay out a screen. A painted hill, a
// firefly or a colouring page is measured in its own coordinates, and a
// spacing step would be meaningless there.
const Map<String, String> drawingFiles = <String, String>{
  'home_sky.dart': "Home's painted scene",
  'card_scene.dart': "the Mindfulness card's landscapes",
  'feelings_moth.dart': 'a painted creature',
  'sk_blob_orb.dart': 'a shader and its ramp',
  'sk_breath_halo.dart': 'a painted halo',
  'breath_ring.dart': 'a painted ring',
  'breath_flower.dart': 'painted petals',
  'feeling_confetti.dart': 'painted sparkles',
  'feeling_dial.dart': 'a painted arc',
  'colouring_canvas.dart': 'a colouring page',
  'colouring_painting.dart': 'a colouring page',
  'colouring_tray.dart': 'painted paint pots',
  'scribble_pad.dart': 'a drawing surface',
  'data_export_service.dart': 'the PDF, which has no Flutter theme',
};

// Where the design system is defined. These files are the source of the
// names, so they are allowed the numbers.
const List<String> systemFiles = <String>[
  'sk_layout.dart',
  'sk_text.dart',
  'sk_colors.dart',
  'sk_palettes.dart',
  'sk_contrast.dart',
  'sk_exercise_colors.dart',
  'theme.dart',
];

// Material controls that have an Sk version. Inside `lib/app/widgets/` they
// are what the Sk version is built from; anywhere else they are a control
// that skipped the design system.
const Map<String, String> skFor = <String, String>{
  'ElevatedButton': 'SkPrimaryButton',
  'FilledButton': 'SkPrimaryButton',
  'OutlinedButton': 'SkOutlineButton',
  'TextButton': 'SkTextButton',
  'IconButton': 'SkCircleIconButton',
  'FloatingActionButton': 'SkPrimaryButton',
  'Switch': 'SkToggle',
  'CupertinoSwitch': 'SkToggle',
  'TextField': 'SkTextField',
  'TextFormField': 'SkTextField',
  'Card': 'SkListCard or SkRaisedTile',
  'ListTile': 'a row inside SkListGroup',
  'Chip': 'SkCategoryChip',
  'SegmentedButton': 'SkSegmented',
  'TabBar': 'SkTabBar',
  'LinearProgressIndicator': 'SkProgressBar',
};

const Map<int, String> stepName = <int, String>{
  4: 'xs',
  8: 'sm',
  12: 'md',
  16: 'lg',
  20: 'xl',
  24: 'xxl',
  32: 'xxxl',
  40: 'huge',
  48: 'tapTarget',
};

// Slots that are never a text colour. Each one measures under 4.5:1 on the
// page ground in at least one palette, which is why it is not for text.
const Map<String, String> notText = <String, String>{
  'muted': 'measures 2.79:1 to 3.23:1 on the canvas',
  'border': 'is the edge of a control',
  'hairline': 'is a divider, about 1.2:1',
  'chevron': 'is a disclosure arrow',
  'actionSoft': 'is a soft tint, for fills',
  'surfaceMuted': 'is a quiet block, for fills',
  'toggleOff': 'is a switch track',
  'canvas': 'is the page ground itself',
  'surface': 'is a card ground',
};

// Tones that are legible on the page ground by design but not on every
// ground. As text they belong behind `SkContrast.readable` or
// `SkStatusStyle`, which nudge them on the grounds where they fail.
const List<String> rawTones = <String>[
  'success',
  'destructive',
  'warning',
  'info',
  'action',
  'panic',
];

class Finding {
  Finding(this.level, this.rule, this.path, this.line, this.text, this.fix);
  final String level;
  final String rule;
  final String path;
  final int line;
  final String text;
  final String fix;
}

bool isComment(String line) {
  final String t = line.trim();
  return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
}

String base(String path) => path.split('/').last;

Future<List<String>> changedFiles() async {
  final ProcessResult diff = await Process.run(
      'git', <String>['diff', '--name-only', 'HEAD', '--', 'lib']);
  final ProcessResult untracked = await Process.run('git',
      <String>['ls-files', '--others', '--exclude-standard', '--', 'lib']);
  return <String>{
    ...(diff.stdout as String).split('\n'),
    ...(untracked.stdout as String).split('\n'),
  }
      .where((String p) => p.endsWith('.dart') && File(p).existsSync())
      .toList()
    ..sort();
}

List<String> dartFilesUnder(List<String> roots) {
  final List<String> out = <String>[];
  for (final String root in roots) {
    if (File(root).existsSync()) {
      out.add(root);
    } else if (Directory(root).existsSync()) {
      out.addAll(Directory(root)
          .listSync(recursive: true)
          .whereType<File>()
          .map((File f) => f.path)
          .where((String p) => p.endsWith('.dart')));
    }
  }
  return out..sort();
}

// The text between `(` at [open] and its matching `)`. Crude about strings,
// which is enough for finding a `style:` argument.
String callBody(String source, int open) {
  int depth = 0;
  for (int i = open; i < source.length; i++) {
    final String c = source[i];
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return source.substring(open, i + 1);
    }
  }
  return source.substring(open);
}

int lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

List<Finding> checkFile(String path) {
  final String name = base(path);
  if (systemFiles.contains(name)) return <Finding>[];

  final String source = File(path).readAsStringSync();
  final List<String> lines = source.split('\n');
  final bool drawing = drawingFiles.containsKey(name);
  final bool inSkWidgets = path.contains('lib/app/widgets/');
  final bool inLab = path.contains('lib/features/design_system/') ||
      path.endsWith('lib/preview.dart');
  final List<Finding> found = <Finding>[];

  final RegExp spacing = RegExp(
      r'(EdgeInsets\.(?:all|symmetric|only|fromLTRB)\(|SizedBox\((?:height|width):|SizedBox\.square\(dimension:|(?:padding|spacing|runSpacing|mainAxisSpacing|crossAxisSpacing):)');
  final RegExp number = RegExp(r'(?<![\w.])(\d+(?:\.\d+)?)(?![\w.])');
  final RegExp radius = RegExp(r'(?:BorderRadius|Radius)\.circular\((\d+(?:\.\d+)?)\)');
  final RegExp themeReach = RegExp(r'Theme\.of\(context\)\.(colorScheme|textTheme|primaryColor|canvasColor|cardColor|dividerColor|scaffoldBackgroundColor)');
  final RegExp control = RegExp(
      '(?<![\\w.])(${skFor.keys.join('|')})(?:\\.\\w+)?\\(');

  for (int i = 0; i < lines.length; i++) {
    final String raw = lines[i];
    if (isComment(raw)) continue;
    final String l = raw.split(' // ').first;

    // Spacing: a number where a named step belongs.
    if (!drawing && spacing.hasMatch(l)) {
      final String tail = l.substring(spacing.firstMatch(l)!.start);
      for (final RegExpMatch m in number.allMatches(tail)) {
        final double v = double.parse(m.group(1)!);
        if (v == 0) continue;
        final bool onGrid = v == v.roundToDouble() && v % 4 == 0;
        final String? named = stepName[v.toInt()];
        found.add(Finding(
          onGrid ? 'check' : 'break',
          'spacing',
          path,
          i + 1,
          raw.trim(),
          onGrid
              ? (named != null
                  ? 'use SkLayout.$named'
                  : 'on the 4-point grid but not a step; use the nearest SkLayout step or name it in SkLayout')
              : '${m.group(1)} is off the 4-point grid; use an SkLayout step',
        ));
      }
    }

    // Corner radius. There is no radius scale yet, so this is a look, not a
    // verdict. 999 is the pill, and a pill is a shape, not a size.
    if (!drawing) {
      for (final RegExpMatch m in radius.allMatches(l)) {
        final double v = double.parse(m.group(1)!);
        if (v == 0 || v >= 999) continue;
        found.add(Finding('check', 'radius', path, i + 1, raw.trim(),
            'a bare radius. Reuse the component that already has this shape, or a named constant beside its reason'));
      }
    }

    // Reaching around the Sk theme to Material's.
    final RegExpMatch? t = themeReach.firstMatch(l);
    if (t != null) {
      found.add(Finding('break', 'theme', path, i + 1, raw.trim(),
          t.group(1) == 'textTheme'
              ? 'use a named SkText style'
              : 'use a slot on context.sk (or context.exercise on a lesson page)'));
    }

    // A raw Material control where an Sk one exists.
    if (!inSkWidgets) {
      for (final RegExpMatch m in control.allMatches(l)) {
        found.add(Finding(inLab ? 'check' : 'break', 'component', path,
            i + 1, raw.trim(), 'use ${skFor[m.group(1)]!}'));
      }
    }
  }

  // A `Text` with no style inherits whatever is above it. Sometimes that is
  // the Sk button deciding for it, which is right; often it is Material's
  // default, which is nobody's decision.
  if (!drawing) {
    final RegExp text = RegExp(r'(?<![\w.])Text\(');
    for (final RegExpMatch m in text.allMatches(source)) {
      final int ln = lineOf(source, m.start);
      if (isComment(lines[ln - 1])) continue;
      final String body = callBody(source, m.end - 1);
      if (!body.contains('style:')) {
        found.add(Finding('check', 'text', path, ln, lines[ln - 1].trim(),
            'no style; give it an SkText style, unless an Sk widget above sets it on purpose'));
      }
    }
  }

  // Contrast at the use site. Only the colour a `Text` or an `Icon` is given
  // is read here; a fill is a ground, not text, and is not this rule's job.
  // Painted files are skipped: a firefly has no words on it.
  if (!drawing) {
    final RegExp call = RegExp(r'(?<![\w.])(Text|Icon|TextStyle)\(|\.copyWith\(');
    final RegExp slot = RegExp(r'color:\s*sk\.(\w+)\b(?!\s*\.with)');
    final RegExp translucent =
        RegExp(r'color:[^,)]*\.(withValues\(alpha|withOpacity|withAlpha)');
    final Set<int> seen = <int>{};
    for (final RegExpMatch m in call.allMatches(source)) {
      final int ln = lineOf(source, m.start);
      if (isComment(lines[ln - 1])) continue;
      final String body = callBody(source, m.end - 1);
      final int bodyStart = m.end - 1;

      for (final RegExpMatch c in slot.allMatches(body)) {
        final String name = c.group(1)!;
        final int at = lineOf(source, bodyStart + c.start);
        if (!seen.add(at)) continue;
        // A chevron icon in `chevron` is that slot doing its one job.
        if (name == 'chevron' && m.group(1) == 'Icon') continue;
        if (notText.containsKey(name)) {
          found.add(Finding('break', 'contrast', path, at,
              lines[at - 1].trim(),
              '`$name` ${notText[name]}; not a text colour. Use ink, or SkContrast.captionOn(the ground)'));
        } else if (rawTones.contains(name) && !inSkWidgets) {
          found.add(Finding('check', 'contrast', path, at,
              lines[at - 1].trim(),
              'raw `$name` as text is only safe on the canvas; use SkContrast.readable(sk.$name, ground) or SkStatusStyle'));
        }
      }

      for (final RegExpMatch c in translucent.allMatches(body)) {
        final int at = lineOf(source, bodyStart + c.start);
        if (!seen.add(at)) continue;
        found.add(Finding('check', 'contrast', path, at, lines[at - 1].trim(),
            'see-through text has no ratio of its own; flatten with SkContrast.over, then captionOn'));
      }
    }
  }

  return found;
}

Future<void> main(List<String> args) async {
  final bool strict = args.contains('--strict');
  final bool changed = args.contains('--changed');
  final List<String> roots =
      args.where((String a) => !a.startsWith('--')).toList();

  final List<String> files = changed
      ? await changedFiles()
      : dartFilesUnder(roots.isEmpty ? <String>['lib'] : roots);

  final List<Finding> all = <Finding>[
    for (final String f in files) ...checkFile(f),
  ];

  const List<String> order = <String>[
    'component',
    'contrast',
    'theme',
    'spacing',
    'radius',
    'text',
  ];
  const Map<String, String> title = <String, String>{
    'component': 'Raw Material controls where an Sk widget exists',
    'contrast': 'Text or icon in a colour that may not clear WCAG',
    'theme': 'Theme.of reached around the Sk theme',
    'spacing': 'Spacing typed as a number',
    'radius': 'Corner radius typed as a number',
    'text': 'Text with no style',
  };

  for (final String level in <String>['break', 'check']) {
    final List<Finding> ofLevel =
        all.where((Finding f) => f.level == level).toList();
    stdout.writeln(level == 'break'
        ? '\n=== BREAKS (${ofLevel.length}) - fix these ==='
        : '\n=== CHECKS (${ofLevel.length}) - look at these ===');
    for (final String rule in order) {
      final List<Finding> group =
          ofLevel.where((Finding f) => f.rule == rule).toList();
      if (group.isEmpty) continue;
      stdout.writeln('\n## ${title[rule]} (${group.length})');
      for (final Finding f in group) {
        stdout.writeln('${f.path}:${f.line}  ${f.fix}');
        stdout.writeln('    ${f.text}');
      }
    }
  }

  final int breaks = all.where((Finding f) => f.level == 'break').length;
  final int checks = all.length - breaks;
  stdout.writeln('\n${files.length} files. $breaks breaks, $checks checks.');
  stdout.writeln('Colour, font size and typeface are gated by '
      '`flutter test test/accessibility_source_test.dart` - run that too.');

  if (strict && breaks > 0) exit(1);
}
