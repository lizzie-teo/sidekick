// One row of the good_things table: a single thing that went well, and when
// it was written.
//
// Three things saved together are three of these, not one holding a list. The
// history list shows them as separate lines, and someone who writes only one
// should not leave two empty ones behind.
class GoodThingModel {
  final String id;
  final String userId;
  final String entry;
  // Always held in local time. Supabase stores timestamptz and returns UTC;
  // fromJson converts on the way in, so every screen groups and formats the
  // same day the user would call it.
  final DateTime createdAt;

  GoodThingModel({
    required this.id,
    required this.userId,
    required this.entry,
    required this.createdAt,
  });

  factory GoodThingModel.fromJson(Map<String, dynamic> json) {
    return GoodThingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      entry: json['entry'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // id and created_at are left to the database defaults on insert, so they are
  // not written here. Sending them back would be the client deciding the row's
  // identity and its clock, and the clock on a phone can be wrong.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'user_id': userId,
      'entry': entry,
    };
  }

  // The calendar day this was written, with the time removed, so entries can
  // be grouped by day with ordinary map keys.
  DateTime get day => DateTime(createdAt.year, createdAt.month, createdAt.day);
}
