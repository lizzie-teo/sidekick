import 'dart:typed_data';

// The colouring pictures, as the Me tab's "Send me a copy of everything"
// needs them: drawn, and ready to print.
//
// An interface here, with the implementation in the play feature, because
// the pictures belong to play and the copy belongs to Me. This is the rule
// for a service one feature owns and another reads: deleting play must not
// break Me, so Me only ever sees this shape -- and asks whether it is
// registered at all.
abstract class ColouringArchive {
  // Every picture kept on this phone, newest first.
  Future<List<ArchivedPicture>> exportAll();
}

class ArchivedPicture {
  final String title;
  final DateTime updatedAt;
  // A PNG on the light paper. A printed page has no dark mode.
  final Uint8List png;

  const ArchivedPicture({
    required this.title,
    required this.updatedAt,
    required this.png,
  });
}
