// lib/memory_model.dart
import 'dart:convert';

class Memory {
  int? id;
  String? ownerEmail; // identifier: owner email
  String? title;
  String? note;
  String? mood;
  /// Stored in DB column 'photoPath' as:
  /// - '' for none
  /// - single path string (legacy)
  /// - JSON array string like '["path1","path2"]'
  List<String>? photoPaths;
  String? createdAt;

  Memory({
    this.id,
    this.ownerEmail,
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
      if (ownerEmail != null) 'owner_email': ownerEmail,
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
          parsed = [rawPhoto];
        }
      } catch (_) {
        parsed = [rawPhoto];
      }
    } else {
      parsed = <String>[];
    }

    return Memory(
      id: map['id'] as int?,
      ownerEmail: map.containsKey('owner_email') ? (map['owner_email'] as String?) : null,
      title: map['title'] as String?,
      note: map['note'] as String?,
      mood: map['mood'] as String?,
      photoPaths: parsed,
      createdAt: map['createdAt'] as String?,
    );
  }
}
