# Security Best Practices

## 🔐 API Key Management

This project uses environment variables to securely manage sensitive API keys and credentials.

### Setup Instructions

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the `.env` file with your actual credentials:**
   ```env
   BACK4APP_APPLICATION_ID=your_actual_application_id
   BACK4APP_CLIENT_KEY=your_actual_client_key
   BACK4APP_SERVER_URL=https://parseapi.back4app.com
   ```

3. **Never commit the `.env` file to version control**
   - The `.env` file is already listed in `.gitignore`
   - Only commit `.env.example` with placeholder values

### Why Use Environment Variables?

✅ **Benefits:**
- Prevents exposing sensitive credentials in source code
- Different credentials for development, staging, and production
- Easy to rotate keys without changing code
- Follows security best practices
- Prevents accidental leaks in public repositories

❌ **Don't:**
- Hard-code API keys directly in source files
- Commit `.env` files to version control
- Share credentials via email or chat
- Use production keys in development

### Getting Your Back4App Credentials

1. Log in to [Back4App Dashboard](https://dashboard.back4app.com/)
2. Select your app
3. Go to **App Settings** → **Security & Keys**
4. Copy your:
   - Application ID
   - Client Key
5. Paste them into your `.env` file

### Architecture

The app uses `flutter_dotenv` package to load environment variables:

```dart
// Load environment variables
await dotenv.load(fileName: ".env");

// Access variables
final keyApplicationId = dotenv.env['BACK4APP_APPLICATION_ID'] ?? '';
```

### File Structure

```
Flutter_Back4App/
├── .env                 # Your actual credentials (NEVER commit!)
├── .env.example         # Template file (safe to commit)
├── .gitignore           # Ensures .env is ignored
└── lib/
    └── main.dart        # Loads credentials from .env
```

### Validation

The app validates that all required environment variables are present at startup:

```dart
if (keyApplicationId.isEmpty || keyClientKey.isEmpty) {
  throw Exception('Missing Back4App credentials. Please check your .env file.');
}
```

### Additional Security Measures

1. **Password Security**
   - Minimum 6 characters required
   - Passwords are encrypted by Parse Server
   - Never stored in plain text

2. **Session Management**
   - Automatic session token handling
   - Secure HTTPS communication
   - Auto-logout on session expiry

3. **Access Control**
   - User-scoped data access (ACL)
   - Notes are private to each user
   - No cross-user data access

4. **Network Security**
   - All API calls use HTTPS
   - TLS/SSL encryption
   - Client key authentication

## 🚨 What to Do if Credentials are Exposed

If you accidentally commit your credentials:

1. **Immediately rotate your keys:**
   - Log in to Back4App Dashboard
   - Generate new Application ID and Client Key
   - Update your `.env` file

2. **Remove from Git history:**
   ```bash
   # Remove sensitive file from history
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch .env" \
     --prune-empty --tag-name-filter cat -- --all
   
   # Force push
   git push origin --force --all
   ```

3. **Update the repository:**
   - Ensure `.gitignore` includes `.env`
   - Commit only `.env.example`

## 📋 Security Checklist

- [x] API keys stored in `.env` file
- [x] `.env` file added to `.gitignore`
- [x] `.env.example` provided as template
- [x] Credentials validated at startup
- [x] HTTPS-only communication
- [x] Password encryption enabled
- [x] User-scoped access control (ACL)
- [x] Session token management
- [x] No hard-coded credentials in source

## 🔍 Auditing

To check if credentials are in your repository:

```bash
# Search for potential credentials
git log --all --full-history --source --pretty=format:'' -- .env
git log --all -S'BACK4APP_APPLICATION_ID' --source --pretty=format:'%h %an %ad %s'

# Check current files for hard-coded keys
grep -r "APPLICATION_ID" lib/ --exclude-dir=.git
```

## 📚 References

- [Back4App Security Best Practices](https://www.back4app.com/docs/security)
- [Flutter Environment Variables](https://pub.dev/packages/flutter_dotenv)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Parse Security Guide](https://docs.parseplatform.org/parse-server/guide/#security)

---

**Remember: Security is everyone's responsibility. Never commit sensitive credentials!** 🔒
