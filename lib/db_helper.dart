import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'models/note.dart';

/*
  DBHelper — handles all database operations using Back4App (singleton pattern)
  -----------------------------------------------------------------------------
  - Connects to Back4App Parse Server for cloud database operations
  - Provides CRUD methods: getNotes, insertNote, updateNote, deleteNote
  - All notes are stored in the 'Note' class in Back4App
  - Notes are associated with the currently logged-in user
*/

class DBHelper {
  // Private constructor for singleton
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  // Class name in Back4App
  static const String _className = 'Ajeesh_2024MT12104';

  /// Get current logged-in user
  Future<ParseUser?> _getCurrentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }

  /// Read all notes for the current user (sorted newest first)
  Future<List<Note>> getNotes() async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) {
        print('DBHelper - No user logged in');
        return [];
      }

      // Query notes from Back4App
      final query = QueryBuilder<ParseObject>(ParseObject(_className))
        ..whereEqualTo('user', currentUser) // Filter by current user
        ..orderByDescending('createdAt'); // Sort by newest first

      final response = await query.query();

      if (response.success && response.results != null) {
        print('DBHelper - Fetched ${response.results!.length} notes');
        return response.results!.map((parseNote) {
          return Note.fromParse(parseNote as ParseObject);
        }).toList();
      } else {
        print('DBHelper - Error fetching notes: ${response.error?.message}');
        return [];
      }
    } catch (e) {
      print('DBHelper - Exception fetching notes: $e');
      return [];
    }
  }

  /// Create a new note in Back4App
  Future<String> insertNote(Note note) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Create ParseObject for the note
      final parseNote = ParseObject(_className)
        ..set('text', note.text)
        ..set('createdAt', note.createdAt)
        ..set('user', currentUser); // Associate with current user

      print('DBHelper - Inserting note: ${note.text}');

      final response = await parseNote.save();

      if (response.success && response.result != null) {
        final savedNote = response.result as ParseObject;
        final objectId = savedNote.objectId!;
        print('DBHelper - Insert successful, objectId: $objectId');
        return objectId;
      } else {
        print('DBHelper - Error inserting note: ${response.error?.message}');
        throw Exception(response.error?.message ?? 'Failed to insert note');
      }
    } catch (e) {
      print('DBHelper - Exception inserting note: $e');
      rethrow;
    }
  }

  /// Update an existing note
  Future<bool> updateNote(Note note) async {
    try {
      if (note.objectId == null) {
        throw Exception('Note objectId is null');
      }

      // Get the existing note from Back4App
      final parseNote = ParseObject(_className)..objectId = note.objectId;

      // Update the text field
      parseNote.set('text', note.text);

      print('DBHelper - Updating note: ${note.objectId}');

      final response = await parseNote.save();

      if (response.success) {
        print('DBHelper - Update successful');
        return true;
      } else {
        print('DBHelper - Error updating note: ${response.error?.message}');
        return false;
      }
    } catch (e) {
      print('DBHelper - Exception updating note: $e');
      return false;
    }
  }

  /// Delete a note by objectId
  Future<bool> deleteNote(String objectId) async {
    try {
      final parseNote = ParseObject(_className)..objectId = objectId;

      print('DBHelper - Deleting note: $objectId');

      final response = await parseNote.delete();

      if (response.success) {
        print('DBHelper - Delete successful');
        return true;
      } else {
        print('DBHelper - Error deleting note: ${response.error?.message}');
        return false;
      }
    } catch (e) {
      print('DBHelper - Exception deleting note: $e');
      return false;
    }
  }
}
