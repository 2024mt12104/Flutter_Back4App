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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8E7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.deepOrange,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black87,
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Colors.orangeAccent,
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
              child: CircularProgressIndicator(color: Colors.deepOrange),
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
            color: Colors.deepOrange,
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
            fillColor: Colors.orange.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
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
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
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
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
                      color: Colors.redAccent,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
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
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade100,
                            Colors.orange.shade200,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.note_alt,
                          color: Colors.black54,
                          size: 26,
                        ),
                        title: Text(
                          note.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Created: ${note.createdAt.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
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
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
