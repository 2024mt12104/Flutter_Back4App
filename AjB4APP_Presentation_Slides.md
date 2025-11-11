---
title: "AjB4APP - Note It Down!"
subtitle: "Flutter Notes App with Cloud Integration"
author: "Ajeesh K Rajan (2024MT12104)"
institute: "BITS Pilani - WiLP Program"
date: "November 2025"
theme: "Madrid"
colortheme: "default"
fontsize: 12pt
aspectratio: 169
---

# Project Overview

## What is AjB4APP?

A modern, cross-platform mobile application built with Flutter

- ✅ Secure User Authentication
- ✅ Cloud-based Notes Management  
- ✅ Real-time Synchronization
- ✅ Beautiful UI/UX Design
- ✅ Custom Branding & Logo

**Tech Stack**: Flutter, Dart, Parse Server, Back4App

---

# Architecture

## System Design

```
Frontend (Flutter)
    ↓
DB Helper (Singleton)
    ↓
Parse Server SDK
    ↓
Back4App Cloud
```

**Design Pattern**: MVC with Singleton
**State Management**: StatefulWidget
**Backend**: Parse Server (Back4App)

---

# Key Features

## Authentication System 🔐

- User Registration with validation
- Secure Login with session management
- Password encryption (server-side)
- Persistent authentication state

## Notes Management 📋

- **Create**: Add new notes (120 chars)
- **Read**: View user-specific notes
- **Update**: Edit with tap interaction
- **Delete**: Swipe with undo option

---

# Technology Stack

## Frontend
- Flutter SDK 3.9.2+
- Material Design 3
- Dart Language

## Backend & Cloud
- Back4App (Parse Server)
- Parse Server SDK 9.0.0
- REST API

## Tools
- Git/GitHub
- VS Code
- Android Studio

---

# UI/UX Design

## Visual Elements 🎨

**Color Scheme:**
- Primary: Deep Orange (#FF5722)
- Accent: Orange Accent (#FFAB40)
- Background: Peach Gradient
- Text: Brown tones

**Features:**
- Custom animated logo
- Glassmorphic containers
- Smooth animations
- Material Design 3

---

# Database Schema

## Back4App Structure 💾

### User Class
- objectId, username, email
- password (encrypted)
- sessionToken

### Notes Class
- objectId, text, createdAt
- user (Pointer to User)
- ACL (Access Control)

**User-Specific**: Each note belongs to one user only

---

# Security

## Protection Measures 🔒

1. **Environment Variables**
   - API keys in `.env` file
   - Not committed to Git

2. **User Data Protection**
   - ACL on all notes
   - User-scoped queries

3. **Authentication Security**
   - Session tokens
   - HTTPS communication
   - Server-side encryption

---

# Testing

## Comprehensive Test Suite 🧪

**127 Unit Tests Total**

| Component | Tests | Coverage |
|-----------|-------|----------|
| Note Model | 56 | 74% |
| DB Helper | 23 | 100%* |
| Authentication | 31 | 100%* |
| Environment | 40 | 100%* |

*Logic coverage

**All tests pass in 2-8 seconds**

---

# Development Challenges

## Problems & Solutions 🎯

**Challenge**: Parse SDK Integration
- **Solution**: Custom model with serialization

**Challenge**: User-specific Data
- **Solution**: ACL + Pointer queries

**Challenge**: State Management
- **Solution**: StatefulWidget + async/await

**Challenge**: Environment Security
- **Solution**: flutter_dotenv + .gitignore

---

# Key Learnings

## Skills Acquired 📚

**Technical:**
- Flutter architecture & widgets
- Async programming in Dart
- REST API integration
- Cloud database operations
- Unit testing practices

**Professional:**
- Project planning
- Version control with Git
- Documentation writing
- Problem-solving

---

# Project Statistics

## Development Metrics 📊

- **Lines of Code**: 1,500+
- **Dart Files**: 7
- **Test Files**: 4
- **Total Tests**: 127
- **Git Commits**: 15+
- **Development Time**: 4-6 weeks
- **Dependencies**: 8 packages

---

# Future Enhancements

## Roadmap 🚀

**Phase 1:**
- Note categories/tags
- Search functionality
- Color coding
- Image attachments

**Phase 2:**
- Push notifications
- Share notes
- Offline mode
- Dark theme

**Phase 3:**
- Voice notes
- Rich text editing
- Collaborative notes

---

# Demonstration

## Live App Features 🎬

1. Login with animated logo
2. User registration
3. Create notes
4. Edit notes
5. Delete with undo
6. Swipe gestures
7. Logout functionality
8. About dialog

**Key Visuals:**
- Peach gradient backgrounds
- Custom logo animation
- Glassmorphic effects

---

# Conclusion

## Project Summary 🎯

**Achievements:**
- ✅ Fully functional app
- ✅ Secure authentication
- ✅ Cloud integration
- ✅ 127 tests written
- ✅ Professional UI/UX
- ✅ Complete documentation

**Value Delivered:**
A production-ready, secure, scalable note-taking application

---

# Thank You! 🙏

## Questions?

**Contact:**
- Ajeesh K Rajan (2024MT12104)
- 2024mt12104@wilp.bits-pilani.ac.in

**GitHub:**
- 2024mt12104/Flutter_Back4App

**Course:**
- Cross Platform Application Development
- Mentor: Chandan R N

© 2024-2025 All rights reserved
