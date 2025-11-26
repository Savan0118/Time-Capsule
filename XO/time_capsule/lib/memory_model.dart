import 'dart:convert';

class Memory {
  int? id;
  String? title;
  String? note;
  String? mood;
  /// Stored in DB column 'photoPath' as either:
  /// - an empty string
  /// - a single file path string (legacy)
  /// - a JSON array string like '["path1","path2"]' (new)
  List<String>? photoPaths;
  String? createdAt;

  Memory({
    this.id,
    this.title,
    this.note,
    this.mood,
    this.photoPaths,
    this.createdAt,
  });

  /// Backwards-compatible getter for single-photo code.
  String? get photoPath => (photoPaths == null || photoPaths!.isEmpty) ? null : photoPaths!.first;

  Map<String, dynamic> toMap() {
    final photoField = (photoPaths == null || photoPaths!.isEmpty) ? '' : jsonEncode(photoPaths);
    return {
      if (id != null) 'id': id,
      'title': title ?? '',
      'note': note ?? '',
      'mood': mood ?? '',
      'photoPath': photoField,
      'createdAt': createdAt ?? '',
    };
  }

  factory Memory.fromMap(Map<String, dynamic> map) {
    final rawPhoto = map['photoPath'] as String?;
    List<String>? parsed;
    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPhoto);
        if (decoded is List) {
          parsed = decoded.map((e) => e.toString()).toList();
        } else {
          // legacy single-path string
          parsed = [rawPhoto];
        }
      } catch (_) {
        // not JSON — treat as single path
        parsed = [rawPhoto];
      }
    } else {
      parsed = <String>[];
    }

    return Memory(
      id: map['id'] as int?,
      title: map['title'] as String?,
      note: map['note'] as String?,
      mood: map['mood'] as String?,
      photoPaths: parsed,
      createdAt: map['createdAt'] as String?,
    );
  }
}
