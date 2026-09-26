import 'dart:math';

// One colouring picture: which scene, what colour each space holds, and every
// brush and rubber stroke.
//
// **A picture is data, not an image.** It is redrawn from this every time,
// so it stays sharp at any zoom and stays editable, and a busy one is tens of
// kilobytes. The phone keeps it as a JSON file and, for somebody with an
// account, Supabase keeps the same fields in the `colourings` table.
//
// Immutable, like every state object here: undo is a list of earlier
// pictures, and that only works if nothing edits one in place.
class ColouringPicture {
  final String id;
  final String sceneId;

  // Space id -> colour, as an ARGB integer. A space with no entry is paper.
  final Map<String, int> fills;

  // In the order they were drawn, which is the order they are painted.
  final List<PictureStroke> strokes;

  final DateTime createdAt;
  final DateTime updatedAt;

  // True while the server has not got this version yet. Only ever true for
  // somebody with an account; it lives in the phone's copy and is never sent.
  final bool needsUpload;

  // True once the server holds some version of this picture. Also phone-only.
  //
  // It is what signing out reads. A picture on the server leaves the phone
  // with the account; one that never reached the server -- made before an
  // email was attached, and not sent yet -- stays, because nothing else has
  // a copy of it.
  final bool onServer;

  const ColouringPicture({
    required this.id,
    required this.sceneId,
    required this.fills,
    required this.strokes,
    required this.createdAt,
    required this.updatedAt,
    this.needsUpload = false,
    this.onServer = false,
  });

  // A fresh page. Not saved until the first mark, so opening a scene and
  // backing out leaves nothing behind.
  factory ColouringPicture.blank(String sceneId, {DateTime? now}) {
    final DateTime at = now ?? DateTime.now();

    return ColouringPicture(
      id: newPictureId(),
      sceneId: sceneId,
      fills: const <String, int>{},
      strokes: const <PictureStroke>[],
      createdAt: at,
      updatedAt: at,
    );
  }

  bool get isEmpty => fills.isEmpty && strokes.isEmpty;

  ColouringPicture copyWith({
    Map<String, int>? fills,
    List<PictureStroke>? strokes,
    DateTime? updatedAt,
    bool? needsUpload,
    bool? onServer,
  }) {
    return ColouringPicture(
      id: id,
      sceneId: sceneId,
      fills: fills ?? this.fills,
      strokes: strokes ?? this.strokes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsUpload: needsUpload ?? this.needsUpload,
      onServer: onServer ?? this.onServer,
    );
  }

  // The phone's copy.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'scene_id': sceneId,
        'fills': fills,
        'strokes': strokes.map((PictureStroke s) => s.toJson()).toList(),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'needs_upload': needsUpload,
        'on_server': onServer,
      };

  // The server's copy: the same fields, less the phone's own flag, plus whose
  // it is -- a row has to say whose it is before the policy can check it.
  Map<String, dynamic> toRow(String userId) {
    final Map<String, dynamic> row = toJson()
      ..remove('needs_upload')
      ..remove('on_server');
    row['user_id'] = userId;
    return row;
  }

  // Reads either copy. A row has neither phone flag; the server store marks
  // what it reads as `onServer` itself.
  factory ColouringPicture.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> fills =
        (json['fills'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final List<dynamic> strokes = json['strokes'] as List? ?? const <dynamic>[];

    return ColouringPicture(
      id: json['id'] as String,
      sceneId: json['scene_id'] as String,
      fills: <String, int>{
        for (final MapEntry<String, dynamic> e in fills.entries)
          e.key: (e.value as num).toInt(),
      },
      strokes: strokes
          .map((dynamic s) =>
              PictureStroke.fromJson((s as Map).cast<String, dynamic>()))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      needsUpload: json['needs_upload'] as bool? ?? false,
      onServer: json['on_server'] as bool? ?? false,
    );
  }
}

// One stroke of the brush or the rubber, in scene units.
//
// It belongs to the one space it started in, and it is clipped to that space
// when it is painted. That is "stay in the lines": a finger that runs over
// the edge does not colour the next space.
class PictureStroke {
  final String regionId;
  final int colour;
  final double size;

  // The rubber. It takes brush marks off its space and shows the fill under
  // them again.
  final bool erase;

  // Drawn with a pen, so the pressures are real. A finger's are not, and
  // the stroke works its width out from speed instead.
  final bool pen;

  // Flat x, y, pressure triplets. Flat rather than a list of objects because
  // it is the shape that goes into a JSON column, and a picture can hold
  // thousands of them.
  final List<double> points;

  const PictureStroke({
    required this.regionId,
    required this.colour,
    required this.size,
    required this.erase,
    required this.pen,
    required this.points,
  });

  int get pointCount => points.length ~/ 3;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'r': regionId,
        'c': colour,
        's': size,
        if (erase) 'e': true,
        if (pen) 'k': true,
        // One decimal place is a tenth of a scene unit -- far finer than a
        // finger -- and it roughly halves the size of the copy.
        'p': points.map(_round).toList(),
      };

  factory PictureStroke.fromJson(Map<String, dynamic> json) {
    return PictureStroke(
      regionId: json['r'] as String,
      colour: (json['c'] as num).toInt(),
      size: (json['s'] as num).toDouble(),
      erase: json['e'] as bool? ?? false,
      pen: json['k'] as bool? ?? false,
      points: (json['p'] as List)
          .map((dynamic v) => (v as num).toDouble())
          .toList(),
    );
  }

  static double _round(double v) => (v * 10).roundToDouble() / 10;
}

final Random _random = Random.secure();

// A version 4 UUID, made on the phone. The phone copy exists before the
// server copy, so the phone names it, and every upload is an upsert on it.
String newPictureId() {
  final List<int> bytes =
      List<int>.generate(16, (int _) => _random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final String hex =
      bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();

  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
