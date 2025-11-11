# 📝 Flutter Notes App with Authentication

A full-featured Flutter notes application with user authentication and cloud database integration using Back4App (Parse Server).

## 🎯 Project Overview

This Flutter application provides a complete notes management system with user authentication, allowing users to create, read, update, and delete personal notes stored securely in the cloud. Each user's notes are private and accessible only after authentication.

## ✨ Features

### 🔐 Authentication System
- **User Registration**: Create new account with username, email, and password
- **User Login**: Secure authentication with username and password
- **Session Management**: Automatic session handling and persistence
- **Logout Functionality**: Secure logout with confirmation dialog
- **Password Security**: 
  - Minimum 6 characters requirement
  - Password visibility toggle
  - Password confirmation on registration
  - Secure server-side encryption via Back4App

### 📋 Notes Management (CRUD Operations)
- **Create**: Add new notes with text content (up to 120 characters)
- **Read**: View all notes sorted by creation date (newest first)
- **Update**: Edit existing notes via tap interaction
- **Delete**: 
  - Swipe-to-delete with visual feedback
  - Undo option with SnackBar notification
  - Confirmation before permanent deletion

### ☁️ Cloud Integration
- **Back4App Database**: Cloud-based Parse Server backend
- **User-Specific Data**: Notes automatically filtered by logged-in user
- **Real-time Sync**: All operations sync with cloud database
- **Cross-Device Access**: Access notes from any device after login

### 🎨 User Interface
- **Material Design 3**: Modern, clean interface with Material You theming
- **Gradient Backgrounds**: Beautiful orange/peach gradient color scheme
- **Custom Styling**: 
  - Rounded corners and shadows
  - Custom list tiles with icons
  - Colorful dialog boxes
  - Smooth animations
- **Responsive Design**: Works on Android, iOS, and other platforms
- **Loading States**: Visual feedback during async operations
- **Error Handling**: User-friendly error messages via SnackBars

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                    # App entry point, authentication wrapper
├── db_helper.dart              # Database operations with Back4App
├── models/
│   └── note.dart               # Note data model with Parse integration
└── screens/
    ├── login_screen.dart       # User login interface
    └── register_screen.dart    # User registration interface
```

### Key Components

#### 1. **Authentication Wrapper**
- Checks user authentication status on app launch
- Routes to Login screen if not authenticated
- Routes to Notes Home if authenticated
- Displays loading indicator during check

#### 2. **Database Helper (DBHelper)**
- Singleton pattern for database operations
- Parse Server SDK integration
- User-scoped queries (automatic filtering by current user)
- Comprehensive error handling and logging

#### 3. **Note Model**
- Parse-compatible data structure
- Converts between Dart objects and Parse objects
- Supports both cloud and local data representation

#### 4. **Authentication Screens**
- Form validation with real-time feedback
- Loading states during API calls
- Error handling with descriptive messages
- Navigation between login and registration

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Parse Server SDK for Back4App integration
  parse_server_sdk_flutter: ^9.0.0
  
  # Local database support (legacy, not actively used)
  sqflite: ^2.2.8
  path: ^1.8.4
  path_provider: ^2.0.15
  
  # Icons
  cupertino_icons: ^1.0.8
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Back4App account (free tier available)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd first_flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Back4App credentials**
   
   Open `lib/main.dart` and update with your Back4App credentials:
   ```dart
   const keyApplicationId = 'YOUR_APP_ID_HERE';
   const keyClientKey = 'YOUR_CLIENT_KEY_HERE';
   const keyParseServerUrl = 'https://parseapi.back4app.com';
   ```

4. **Run the app**
   ```bash
   # For Android emulator
   flutter run -d emulator-5554
   
   # For specific device
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

## 🔧 Configuration

### Back4App Setup

1. **Create Back4App Account**
   - Visit [Back4App.com](https://www.back4app.com/)
   - Sign up for a free account

2. **Create New App**
   - Click "Build new app"
   - Choose "Parse" as backend
   - Name your application

3. **Get Credentials**
   - Go to App Settings > Security & Keys
   - Copy Application ID and Client Key
   - Update `lib/main.dart` with these credentials

4. **Database Classes**
   - User class is automatically created
   - Notes are stored in `Ajeesh_2024MT12104` class
   - Access via Database Browser in Back4App dashboard

### Class Name Configuration

To change the database class name, edit `lib/db_helper.dart`:
```dart
static const String _className = 'Ajeesh_2024MT12104';
```
**Note**: Class names must start with a letter (A-Z, a-z)

## 💾 Database Schema

### User Class (Built-in)
| Field | Type | Description |
|-------|------|-------------|
| objectId | String | Unique user identifier |
| username | String | User's username (unique) |
| email | String | User's email address |
| password | String | Encrypted password |
| sessionToken | String | Current session token |
| createdAt | DateTime | Account creation date |
| updatedAt | DateTime | Last update timestamp |

### Notes Class (Ajeesh_2024MT12104)
| Field | Type | Description |
|-------|------|-------------|
| objectId | String | Unique note identifier |
| text | String | Note content (max 120 chars) |
| createdAt | DateTime | Note creation date |
| updatedAt | DateTime | Last modified date |
| user | Pointer | Reference to User who owns the note |
| ACL | ACL | Access control list |

## 🎨 UI/UX Features

### Color Scheme
- Primary: Deep Orange (`Colors.deepOrange`)
- Accent: Orange Accent (`Colors.orangeAccent`)
- Background: Peach gradient (`#FFE5B4`, `#FFD580`, `#FFCBA4`)
- Surface: White with subtle shadows

### Interactions
- **Tap**: Edit note
- **Swipe Right**: Delete note (with undo)
- **FAB**: Add new note
- **Long Press**: (Available for future features)

### Visual Feedback
- Loading spinners during operations
- Success/error messages via SnackBars
- Smooth animations and transitions
- Elevation and shadows for depth

## 🔒 Security Features

- ✅ Password encryption (handled by Parse Server)
- ✅ Session token management
- ✅ User-scoped data access (ACL)
- ✅ Secure HTTPS communication
- ✅ Client key authentication
- ✅ Auto-session management

## 🐛 Debugging

### Common Issues

**Issue**: "No implementation found for method getApplicationDocumentsDirectory"
- **Solution**: Don't run on Chrome/Web. Use Android, iOS, or desktop platforms.

**Issue**: "schema class name does not revalidate"
- **Solution**: Class names must start with a letter, not a number.

**Issue**: Notes not loading
- **Solution**: Check user is logged in and Back4App credentials are correct.

### Debug Logging

Debug logs are enabled in the app. Check console for:
```
I/flutter: DBHelper - Inserting note: ...
I/flutter: DBHelper - Insert successful, objectId: ...
I/flutter: Creating note: ...
```

## 📱 Supported Platforms

- ✅ Android (Tested)
- ✅ iOS (Should work)
- ✅ macOS (Requires Xcode)
- ❌ Web (Parse SDK not fully compatible)
- ✅ Linux (Should work)
- ✅ Windows (Should work)

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 📈 Future Enhancements

- [ ] Search functionality for notes
- [ ] Categories/Tags for organization
- [ ] Rich text formatting
- [ ] Image attachments
- [ ] Note sharing between users
- [ ] Dark mode support
- [ ] Biometric authentication
- [ ] Offline mode with sync
- [ ] Export notes (PDF, TXT)
- [ ] Note archiving

## 📄 License

This project is created for educational purposes.

## 👤 Author

**Ajeesh** - Student ID: 2024MT12104

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Back4App for cloud database services
- Parse Platform for the server SDK
- Material Design team for UI guidelines

## 📞 Support

For issues and questions:
- Check the [Flutter documentation](https://docs.flutter.dev/)
- Visit [Back4App documentation](https://www.back4app.com/docs)
- Review [Parse Server SDK docs](https://pub.dev/packages/parse_server_sdk_flutter)

---

**Built with ❤️ using Flutter & Back4App**
