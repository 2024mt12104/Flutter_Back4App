// Copyright (c) 2024-2025 2024mt12104@wilp.bits-pilani.ac.in
// All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'db_helper.dart';
import 'models/note.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Parse Server SDK with environment variables
  final keyApplicationId = dotenv.env['BACK4APP_APPLICATION_ID'] ?? '';
  final keyClientKey = dotenv.env['BACK4APP_CLIENT_KEY'] ?? '';
  final keyParseServerUrl =
      dotenv.env['BACK4APP_SERVER_URL'] ?? 'https://parseapi.back4app.com';

  // Validate that required keys are present
  if (keyApplicationId.isEmpty || keyClientKey.isEmpty) {
    throw Exception(
      'Missing Back4App credentials. Please check your .env file.',
    );
  }

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    debug: true, // Enable debug mode for development
    autoSendSessionId: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App with Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5722)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFE5B4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF5722),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF5722),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black87,
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Color(0xFFFFAB40),
        ),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

/// Wrapper to check authentication status
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  /// Get current logged in user
  Future<ParseUser?> _getCurrentUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ParseUser?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading screen while checking authentication
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF5722)),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - go to NotesHome
          return const NotesHome();
        } else {
          // User is not logged in - go to LoginScreen
          return const LoginScreen();
        }
      },
    );
  }
}

class NotesHome extends StatefulWidget {
  const NotesHome({super.key});

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  final List<Note> _items = [];

  @override
  void initState() {
    super.initState();
    _loadNotesFromDb();
  }

  Future<void> _loadNotesFromDb() async {
    final notes = await DBHelper.instance.getNotes();
    setState(() {
      _items
        ..clear()
        ..addAll(notes);
    });
  }

  Future<void> _addItem(String text) async {
    try {
      final note = Note(text);
      print('Creating note: ${note.text}');
      print('Note map before insert: ${note.toMap()}');

      final objectId = await DBHelper.instance.insertNote(note);
      print('Inserted note with objectId: $objectId');

      final savedNote = Note(
        note.text,
        objectId: objectId,
        createdAt: note.createdAt,
      );
      setState(() => _items.insert(0, savedNote));
      print('Added to list. Total items: ${_items.length}');
    } catch (e) {
      print('Error adding item: $e');
      // Show error to user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding note: $e')));
    }
  }

  Future<void> _updateItem(int index, String newText) async {
    final existing = _items[index];
    final updated = Note(
      newText,
      objectId: existing.objectId,
      createdAt: existing.createdAt,
    );
    final success = await DBHelper.instance.updateNote(updated);
    if (success) {
      setState(() => _items[index] = updated);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update note')));
      }
    }
  }

  Future<void> _removeItem(int index) async {
    final removed = _items[index];
    if (removed.objectId != null) {
      await DBHelper.instance.deleteNote(removed.objectId!);
    }
    setState(() => _items.removeAt(index));

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removed.text}"'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () async {
            final reObjectId = await DBHelper.instance.insertNote(removed);
            final reInserted = Note(
              removed.text,
              objectId: reObjectId,
              createdAt: removed.createdAt,
            );
            setState(() => _items.insert(index, reInserted));
          },
        ),
      ),
    );
  }

  Future<void> _showAddEditDialog({int? index}) async {
    final controller = TextEditingController(
      text: index == null ? '' : _items[index].text,
    );
    final title = index == null ? 'Add note' : 'Edit note';

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFFFF5722),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Type a short note',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFFFE5B4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF5D4037), fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, text);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      if (index == null) {
        await _addItem(result);
      } else {
        await _updateItem(index, result);
      }
    }
  }

  /// Handle user logout
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF5722),
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF5D4037)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = await ParseUser.currentUser() as ParseUser?;
      if (user != null) {
        await user.logout();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          // About/Copyright info
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'About AjB4APP',
                    style: TextStyle(
                      color: Color(0xFFFF5722),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Note It Down!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFAB40),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'A simple and elegant note-taking app with cloud sync powered by Back4App.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        '© ${DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '2024mt12104@wilp.bits-pilani.ac.in',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'All rights reserved.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFFFF5722),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE5B4), Color(0xFFFFD580), Color(0xFFFFCBA4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _items.isEmpty
            ? const Center(
                child: Text(
                  'No notes yet. Press + to add.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final note = _items[i];
                  return Dismissible(
                    key: ValueKey(
                      note.objectId ?? note.createdAt.toIso8601String(),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (_) => _removeItem(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFFFAB40).withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5722).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.note_alt_rounded,
                          color: Color(0xFFFF5722),
                          size: 28,
                        ),
                        title: Text(
                          note.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5D4037),
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Created: ${note.createdAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                        onTap: () => _showAddEditDialog(index: i),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFFF5722),
        elevation: 8,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Text(
          '© ${DateTime.now().year} 2024mt12104@wilp.bits-pilani.ac.in',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8D6E63),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
