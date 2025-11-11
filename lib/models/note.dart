// Copyright (c) 2024-2025 2024mt12104@wilp.bits-pilani.ac.in
// All rights reserved.

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

/// Note model class for Back4App cloud database
class Note {
  String? objectId; // Back4App object ID (replaces local id)
  String text;
  DateTime createdAt;

  Note(this.text, {this.objectId, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  /// Create Note from Parse object (from Back4App)
  factory Note.fromParse(ParseObject parseObject) {
    return Note(
      parseObject.get<String>('text') ?? '',
      objectId: parseObject.objectId,
      createdAt: parseObject.get<DateTime>('createdAt') ?? DateTime.now(),
    );
  }

  /// Convert Note to Map (for backwards compatibility if needed)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
    if (objectId != null) {
      map['objectId'] = objectId;
    }
    return map;
  }

  /// Create Note from Map (for backwards compatibility)
  static Note fromMap(Map<String, dynamic> m) => Note(
    m['text'] as String,
    objectId: m['objectId'] as String?,
    createdAt: m['createdAt'] is String
        ? DateTime.parse(m['createdAt'] as String)
        : m['createdAt'] as DateTime,
  );
}
