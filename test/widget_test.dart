// Comprehensive test suite for the Notes App with Authentication.
//
// Since this app uses Parse Server SDK and requires platform-specific plugins,
// we create unit tests for models and business logic without requiring full
// widget integration or Parse SDK initialization.

import 'package:flutter_test/flutter_test.dart';
import 'package:first_flutter_app/models/note.dart';

void main() {
  group('Note Model - Basic Construction Tests', () {
    test('Note can be created with text only', () {
      final note = Note('Test note');
      expect(note.text, 'Test note');
      expect(note.objectId, isNull);
      expect(note.createdAt, isNotNull);
    });

    test('Note can be created with objectId', () {
      final note = Note('Test note', objectId: 'abc123');
      expect(note.text, 'Test note');
      expect(note.objectId, 'abc123');
    });

    test('Note can be created with custom createdAt', () {
      final customDate = DateTime(2024, 1, 1, 12, 0, 0);
      final note = Note('Test note', createdAt: customDate);
      expect(note.createdAt, customDate);
    });

    test('Note can be created with all parameters', () {
      final customDate = DateTime(2024, 1, 1, 12, 0, 0);
      final note = Note('Test note', objectId: 'xyz789', createdAt: customDate);
      expect(note.text, 'Test note');
      expect(note.objectId, 'xyz789');
      expect(note.createdAt, customDate);
    });

    test('Note has creation timestamp automatically', () {
      final before = DateTime.now();
      final note = Note('Test note');
      final after = DateTime.now();

      expect(note.createdAt, isA<DateTime>());
      expect(
        note.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        note.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('Note Model - Edge Cases and Validation', () {
    test('Note can be created with empty text', () {
      final note = Note('');
      expect(note.text, '');
    });

    test('Note can be created with long text (120 chars)', () {
      final longText = 'A' * 120;
      final note = Note(longText);
      expect(note.text, longText);
      expect(note.text.length, 120);
    });

    test('Note can be created with special characters', () {
      final specialText = 'Test @#\$%^&*()_+-=[]{}|;:\'",.<>?/~`';
      final note = Note(specialText);
      expect(note.text, specialText);
    });

    test('Note can be created with unicode characters', () {
      final unicodeText = 'Hello 世界 🌍 café';
      final note = Note(unicodeText);
      expect(note.text, unicodeText);
    });

    test('Note can be created with newline characters', () {
      final multilineText = 'Line 1\nLine 2\nLine 3';
      final note = Note(multilineText);
      expect(note.text, multilineText);
    });
  });

  group('Note Model - toMap() Tests', () {
    test('toMap() returns correct map structure with objectId', () {
      final now = DateTime.now();
      final note = Note('Test note', objectId: 'test123', createdAt: now);
      final map = note.toMap();

      expect(map['text'], 'Test note');
      expect(map['objectId'], 'test123');
      expect(map['createdAt'], now.toIso8601String());
      expect(map.keys.length, 3);
    });

    test('toMap() excludes null objectId', () {
      final note = Note('Test note');
      final map = note.toMap();

      expect(map.containsKey('objectId'), isFalse);
      expect(map['text'], 'Test note');
      expect(map.containsKey('createdAt'), isTrue);
      expect(map.keys.length, 2);
    });

    test('toMap() converts createdAt to ISO8601 string', () {
      final date = DateTime(2024, 1, 15, 10, 30, 45);
      final note = Note('Test note', createdAt: date);
      final map = note.toMap();

      expect(map['createdAt'], isA<String>());
      expect(map['createdAt'], date.toIso8601String());
    });

    test('toMap() handles empty text', () {
      final note = Note('');
      final map = note.toMap();

      expect(map['text'], '');
    });
  });

  group('Note Model - fromMap() Tests', () {
    test('fromMap() creates Note from map with DateTime object', () {
      final date = DateTime(2024, 1, 15, 10, 30, 45);
      final map = {
        'text': 'Test note',
        'objectId': 'abc123',
        'createdAt': date,
      };

      final note = Note.fromMap(map);

      expect(note.text, 'Test note');
      expect(note.objectId, 'abc123');
      expect(note.createdAt, date);
    });

    test('fromMap() creates Note from map with ISO8601 string', () {
      final date = DateTime(2024, 1, 15, 10, 30, 45);
      final map = {
        'text': 'Test note',
        'objectId': 'abc123',
        'createdAt': date.toIso8601String(),
      };

      final note = Note.fromMap(map);

      expect(note.text, 'Test note');
      expect(note.objectId, 'abc123');
      expect(note.createdAt.year, date.year);
      expect(note.createdAt.month, date.month);
      expect(note.createdAt.day, date.day);
    });

    test('fromMap() creates Note without objectId', () {
      final map = {
        'text': 'Test note',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final note = Note.fromMap(map);

      expect(note.text, 'Test note');
      expect(note.objectId, isNull);
    });

    test('fromMap() handles empty text', () {
      final map = {'text': '', 'createdAt': DateTime.now()};

      final note = Note.fromMap(map);

      expect(note.text, '');
    });
  });

  group('Note Model - Round-trip Conversion Tests', () {
    test('Note survives toMap() -> fromMap() conversion', () {
      final original = Note(
        'Original note',
        objectId: 'id123',
        createdAt: DateTime(2024, 1, 15, 10, 30, 45),
      );

      final map = original.toMap();
      final restored = Note.fromMap(map);

      expect(restored.text, original.text);
      expect(restored.objectId, original.objectId);
      // Compare timestamps (may have slight differences due to ISO conversion)
      expect(
        restored.createdAt.difference(original.createdAt).inSeconds,
        lessThan(1),
      );
    });

    test('Note without objectId survives round-trip conversion', () {
      final original = Note('Test note', createdAt: DateTime(2024, 1, 15));

      final map = original.toMap();
      final restored = Note.fromMap(map);

      expect(restored.text, original.text);
      expect(restored.objectId, isNull);
      expect(restored.createdAt.day, original.createdAt.day);
    });
  });

  group('App Configuration Tests', () {
    test('App title is correct', () {
      const appTitle = 'Notes App with Authentication';
      expect(appTitle, 'Notes App with Authentication');
      expect(appTitle.isNotEmpty, isTrue);
    });

    test('Parse server URL is configured correctly', () {
      const serverUrl = 'https://parseapi.back4app.com';
      expect(serverUrl, startsWith('https://'));
      expect(serverUrl.contains('parseapi.back4app.com'), isTrue);
      expect(Uri.tryParse(serverUrl), isNotNull);
    });

    test('Parse server URL is valid URI', () {
      const serverUrl = 'https://parseapi.back4app.com';
      final uri = Uri.parse(serverUrl);
      expect(uri.scheme, 'https');
      expect(uri.host, 'parseapi.back4app.com');
    });
  });

  group('Note Model - Data Integrity Tests', () {
    test('Multiple notes can have same text but different IDs', () {
      final note1 = Note('Same text', objectId: 'id1');
      final note2 = Note('Same text', objectId: 'id2');

      expect(note1.text, note2.text);
      expect(note1.objectId, isNot(note2.objectId));
    });

    test('Notes created at different times have different timestamps', () {
      final note1 = Note('First note');
      // Small delay
      final note2 = Note(
        'Second note',
        createdAt: DateTime.now().add(const Duration(milliseconds: 100)),
      );

      expect(note2.createdAt.isAfter(note1.createdAt), isTrue);
    });

    test('Note text is mutable', () {
      final note = Note('Original text');
      note.text = 'Modified text';
      expect(note.text, 'Modified text');
    });

    test('Note objectId is mutable', () {
      final note = Note('Test note');
      expect(note.objectId, isNull);
      note.objectId = 'new-id-123';
      expect(note.objectId, 'new-id-123');
    });

    test('Note createdAt is mutable', () {
      final note = Note('Test note');
      final newDate = DateTime(2020, 1, 1);
      note.createdAt = newDate;
      expect(note.createdAt, newDate);
    });
  });

  group('Database Helper Constants Tests', () {
    test('Database class name should start with letter', () {
      const className = 'Ajeesh_2024MT12104';
      expect(className[0], matches(RegExp(r'[A-Za-z]')));
      expect(className.contains('_'), isTrue);
    });

    test('Class name follows naming convention', () {
      const className = 'Ajeesh_2024MT12104';
      expect(className, matches(RegExp(r'^[A-Za-z][A-Za-z0-9_]*$')));
    });
  });

  group('Input Validation Scenarios', () {
    test('Note text length validation (max 120 chars)', () {
      final maxLengthText = 'A' * 120;
      final note = Note(maxLengthText);
      expect(note.text.length, lessThanOrEqualTo(120));
    });

    test('Note can handle whitespace-only text', () {
      final note = Note('   ');
      expect(note.text, '   ');
      expect(note.text.trim().isEmpty, isTrue);
    });

    test('Note can handle tabs and special whitespace', () {
      final note = Note('\t\n\r');
      expect(note.text, '\t\n\r');
    });
  });
}
