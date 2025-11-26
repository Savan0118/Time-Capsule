// lib/memory_model.dart
import 'dart:convert';

class Memory {
  int? id;
  String? ownerEmail; // identifier: owner email
  String? title;
  String? note;
  String? mood;

  /// Preferred in-memory representation: list of file paths.
  /// DB storage may contain:
  ///  - '' (empty)
  ///  - single path string (legacy)
  ///  - JSON array string like '["path1","path2"]'
  List<String>? photoPaths;
  String? createdAt; // ISO string, e.g. "2025-11-26T09:00:00"

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

  /// Convert this Memory into a Map suitable for DB insertion.
  /// Note: we include 'photoPaths' (List) so DB helper can detect it and encode,
  /// and also include 'photoPath' (JSON string) for compatibility with older code.
  Map<String, dynamic> toMap() {
    final photoField = (photoPaths == null || photoPaths!.isEmpty) ? '' : jsonEncode(photoPaths);
    return {
      if (id != null) 'id': id,
      // use snake_case for DB columns where appropriate
      if (ownerEmail != null) 'owner_email': ownerEmail,
      'title': title ?? '',
      'note': note ?? '',
      'mood': mood ?? '',
      // Provide both forms: a raw list under photoPaths (DB helper will handle)
      // and a JSON string under photoPath for legacy compatibility.
      'photoPaths': photoPaths ?? <String>[],
      'photoPath': photoField,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  /// Create a Memory from a DB map. This is defensive and accepts multiple
  /// possible key names and formats for photo path(s) and owner.
  factory Memory.fromMap(Map<String, dynamic> map) {
    // Helper to safely read a string field
    String? _safeString(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      if (v is int || v is double) return v.toString();
      return null;
    }

    // Normalize ownerEmail
    String? owner;
    if (map.containsKey('owner_email')) {
      owner = _safeString(map['owner_email']);
    } else if (map.containsKey('ownerEmail')) {
      owner = _safeString(map['ownerEmail']);
    } else if (map.containsKey('owner')) {
      owner = _safeString(map['owner']);
    }

    // Normalize createdAt
    String? created;
    if (map.containsKey('createdAt')) {
      created = _safeString(map['createdAt']);
    } else if (map.containsKey('created_at')) {
      created = _safeString(map['created_at']);
    }

    // Parse id defensively (could be int or string)
    int? parsedId;
    final dynamic rawId = map['id'] ?? map['Id'] ?? map['_id'];
    if (rawId != null) {
      if (rawId is int) parsedId = rawId;
      else {
        final s = _safeString(rawId);
        if (s != null) parsedId = int.tryParse(s);
      }
    }

    // Parse photo paths from several possible shapes:
    // - a JSON string stored in 'photoPath' (preferred)
    // - a List stored under 'photoPaths'
    // - a comma-separated string
    List<String> parsedPhotoPaths = <String>[];
    dynamic pp;
    if (map.containsKey('photoPath')) {
      pp = map['photoPath'];
    } else if (map.containsKey('photo_path')) {
      pp = map['photo_path'];
    } else if (map.containsKey('photoPaths')) {
      pp = map['photoPaths'];
    } else if (map.containsKey('photo_paths')) {
      pp = map['photo_paths'];
    }

    if (pp == null) {
      parsedPhotoPaths = <String>[];
    } else if (pp is String) {
      final s = pp.trim();
      if (s.isEmpty) {
        parsedPhotoPaths = <String>[];
      } else {
        // Try JSON decode first
        try {
          final decoded = jsonDecode(s);
          if (decoded is List) {
            parsedPhotoPaths = decoded.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
          } else if (decoded is String) {
            parsedPhotoPaths = [decoded];
          } else {
            // fallback: treat original string as single path or comma-separated
            if (s.contains(',')) {
              parsedPhotoPaths = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            } else {
              parsedPhotoPaths = [s];
            }
          }
        } catch (_) {
          // not JSON — treat as comma-separated or single path
          if (s.contains(',')) {
            parsedPhotoPaths = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          } else {
            parsedPhotoPaths = [s];
          }
        }
      }
    } else if (pp is List) {
      parsedPhotoPaths = pp.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
    } else {
      // Unknown type — coerce to string and attempt to split
      final s = _safeString(pp) ?? '';
      if (s.contains(',')) {
        parsedPhotoPaths = s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      } else if (s.isNotEmpty) {
        parsedPhotoPaths = [s];
      } else {
        parsedPhotoPaths = <String>[];
      }
    }

    return Memory(
      id: parsedId,
      ownerEmail: owner,
      title: _safeString(map['title']) ?? '',
      note: _safeString(map['note']) ?? '',
      mood: _safeString(map['mood']) ?? '',
      photoPaths: parsedPhotoPaths,
      createdAt: created ?? DateTime.now().toIso8601String(),
    );
  }
}
