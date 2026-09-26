import 'dart:ui';

// The colouring book's paints.
//
// **These are fixed colours, not theme slots, and that is deliberate.** A
// picture is the reader's own work. If the theme could repaint it, the same
// picture would look different after a theme change -- the same call the
// exercise colours and the tighten orb made, for the same kind of reason.
// The chrome around the page still follows the theme.
//
// **A set spans the wheel; the sets differ by mood.** Every set holds the
// same twelve families in the same order -- red, orange, yellow, two greens,
// two blues, purple, pink, brown, grey and a light -- so any scene can be
// coloured from any set, and a swatch keeps its place when the set changes.
// What changes between sets is how bright, how soft and how warm they are:
//
// | Set | Mood |
// | --- | --- |
// | Pastel | Light and soft |
// | Cheerful | Clear and bright |
// | Nostalgic | Dusty and warm, like an old photograph |
// | Moody | Deep and dark |
// | Natural | The colours things really are |
//
// Until 26 September 2026 the sets were Home's four skies and a garden. Each
// was one family of hues, so a set could not colour a whole scene -- a
// morning set with no green and no blue -- and the user asked for sets that
// were told apart by mood instead.
//
// **Still twelve that go together, never a colour wheel.** A set that agrees
// with itself always makes a nice picture, and a wheel is a hundred
// decisions in front of somebody who came here to stop making them.
//
// **No paint is as dark as the lines.** The lines are near-black, and the
// first Moody set put Navy at 1.02:1 against them -- a sky filled with it
// swallowed the outline of everything in front of it. Every paint now clears
// 2:1 against the line colour, which keeps Moody deep and keeps the drawing
// readable on top of it. `colouring_scenes_test.dart` holds the floor.
//
// Every colour has a name, and the name is what a screen reader says. A
// swatch is never only its colour.
class NamedColour {
  final String name;
  final Color color;

  const NamedColour(this.name, this.color);
}

class ColouringPalette {
  final String id;
  final String name;
  final List<NamedColour> colours;

  const ColouringPalette(this.id, this.name, this.colours);
}

abstract final class ColouringPalettes {
  static const List<ColouringPalette> all = <ColouringPalette>[
    ColouringPalette('pastel', 'Pastel', <NamedColour>[
      NamedColour('Rose', Color(0xFFF4A6A6)),
      NamedColour('Apricot', Color(0xFFF9C49A)),
      NamedColour('Butter', Color(0xFFFBE7A1)),
      NamedColour('Mint', Color(0xFFBDE5C8)),
      NamedColour('Sage', Color(0xFF9FC5A4)),
      NamedColour('Powder blue', Color(0xFFB8D8F0)),
      NamedColour('Periwinkle', Color(0xFFA9B4E8)),
      NamedColour('Lilac', Color(0xFFCDB6EA)),
      NamedColour('Blossom', Color(0xFFF7C6DA)),
      NamedColour('Oat', Color(0xFFD9C2A7)),
      NamedColour('Cloud grey', Color(0xFFD5D8DE)),
      NamedColour('Cream', Color(0xFFFFF8EC)),
    ]),
    ColouringPalette('cheerful', 'Cheerful', <NamedColour>[
      NamedColour('Cherry', Color(0xFFE63946)),
      NamedColour('Tangerine', Color(0xFFF77F00)),
      NamedColour('Sunflower', Color(0xFFFFC300)),
      NamedColour('Lime', Color(0xFF8BC34A)),
      NamedColour('Leaf green', Color(0xFF2E9E4F)),
      NamedColour('Sky', Color(0xFF29A8E0)),
      NamedColour('Cobalt', Color(0xFF2F5BD3)),
      NamedColour('Grape', Color(0xFF8E44AD)),
      NamedColour('Bubblegum', Color(0xFFFF6FA8)),
      NamedColour('Cocoa', Color(0xFF8B5A2B)),
      NamedColour('Slate', Color(0xFF7D8597)),
      NamedColour('White', Color(0xFFFFFFFF)),
    ]),
    ColouringPalette('nostalgic', 'Nostalgic', <NamedColour>[
      NamedColour('Brick', Color(0xFFB5584C)),
      NamedColour('Rust', Color(0xFFC97B4A)),
      NamedColour('Mustard', Color(0xFFD9B45A)),
      NamedColour('Olive', Color(0xFFA3A86B)),
      NamedColour('Moss', Color(0xFF6F7F55)),
      NamedColour('Faded teal', Color(0xFF6E9E9A)),
      NamedColour('Denim', Color(0xFF5C7599)),
      NamedColour('Plum', Color(0xFF86607F)),
      NamedColour('Dusty rose', Color(0xFFC98F95)),
      NamedColour('Tan', Color(0xFFA68A6A)),
      NamedColour('Pewter', Color(0xFF9A958C)),
      NamedColour('Parchment', Color(0xFFEFE3C8)),
    ]),
    ColouringPalette('moody', 'Moody', <NamedColour>[
      NamedColour('Wine', Color(0xFF9E3440)),
      NamedColour('Burnt orange', Color(0xFFA8491E)),
      NamedColour('Amber', Color(0xFFC28A12)),
      NamedColour('Pine', Color(0xFF5B8A4F)),
      NamedColour('Forest', Color(0xFF3A6B4A)),
      NamedColour('Deep teal', Color(0xFF24696F)),
      NamedColour('Navy', Color(0xFF3A5A9A)),
      NamedColour('Aubergine', Color(0xFF7A4A74)),
      NamedColour('Mauve', Color(0xFFA85A7E)),
      NamedColour('Umber', Color(0xFF75543A)),
      NamedColour('Charcoal', Color(0xFF5A5A62)),
      NamedColour('Fog', Color(0xFFB9B6B0)),
    ]),
    ColouringPalette('natural', 'Natural', <NamedColour>[
      NamedColour('Poppy', Color(0xFFD8483B)),
      NamedColour('Marigold', Color(0xFFE8912D)),
      NamedColour('Lemon', Color(0xFFF2D24B)),
      NamedColour('Grass', Color(0xFF6DB36B)),
      NamedColour('Fern', Color(0xFF3F7D4A)),
      NamedColour('Water', Color(0xFF5DA9C9)),
      NamedColour('Lake', Color(0xFF3B6E9E)),
      NamedColour('Lavender', Color(0xFF9C84C9)),
      NamedColour('Petal pink', Color(0xFFEBA1B8)),
      NamedColour('Bark', Color(0xFF7A5236)),
      NamedColour('Stone', Color(0xFF9EA3A0)),
      NamedColour('Chalk', Color(0xFFF4F1E8)),
    ]),
  ];

  static ColouringPalette byId(String? id) {
    for (final ColouringPalette palette in all) {
      if (palette.id == id) return palette;
    }
    return all.first;
  }
}

// The page itself: the paper and the lines drawn on it.
//
// **The paper is dimmed in dark mode, and the colours are not.** A white page
// in a dark room is a lamp -- what the exercise pages learned on 22 September
// 2026. The paints stay exactly as picked, because they are the reader's.
//
// The lines are the same near-black on both papers: they sit at 13:1 on the
// light paper and 8:1 on the dim one.
class ColouringPaper {
  final Color paper;
  final Color line;

  const ColouringPaper({required this.paper, required this.line});

  static const ColouringPaper light = ColouringPaper(
    paper: Color(0xFFFBF8F1),
    line: Color(0xFF2E2A26),
  );

  static const ColouringPaper dark = ColouringPaper(
    paper: Color(0xFFC9C3B5),
    line: Color(0xFF2E2A26),
  );

  static ColouringPaper of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
