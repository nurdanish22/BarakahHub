# BarakahHub — Member 1: Authentication & Profile Management

> **Group 6 | INFO 4335 SEC 1 | Sem 2, 2025/2026**[cite: 1]

This folder contains all files owned by **Member 1** for the BarakahHub Flutter project, establishing the core authentication framework, state management, and user profile ecosystem.

---

## Modules Covered

### Module 1: Authentication & Profile Management
- User Sign Up / Registration
- User Sign In / Login
- Password Reset / Forgot Password
- Global Authentication State Monitoring (Provider pattern)
- User Profile View & Data Retrieval

---

## File Structure

```
lib/
├── models/
│   └── user_model.dart             ← UserModel definitions
├── services/
│   └── auth_service.dart           ← All Firebase Auth + Firestore reads for users
├── providers/
│   └── auth_provider.dart          ← State management (Provider pattern) for session
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart           ← User login interface
│   │   ├── register_screen.dart        ← User account creation interface
│   │   └── forgot_password_screen.dart ← Password recovery interface
│   └── profile/
│       └── profile_screen.dart         ← Account details & profile overview
└── main.dart                       ← App initialization, Firebase config & root router
```

---

## Firestore Collections Used

### `users`
| Field | Type | Notes |
|---|---|---|
| `uid` | String | Firebase Authentication unique ID |
| `email` | String | |
| `name` | String | Display name |
| `createdAt` | Timestamp | Account creation date |
| `role` | String | e.g., Member, Admin |

---

## How to Wire Up (Integration Guide)

### 1. Register the provider in `main.dart`
Wrap your application root with the `AuthProvider` so session state is accessible globally[cite: 1]:

  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: const MyApp(),
  )

### 2. Guard screens or check authentication status
Other members can check if a user is securely logged in before showing private screens:

  final authProvider = context.read<AuthProvider>();
  if (authProvider.isAuthenticated) {
    // Proceed to secure screen
  }

### 3. Retrieve the active User Profile or UID
Replace any placeholder user IDs in your modules with the live authenticated user data[cite: 1]:

  // Get the current UID string
  String currentUserId = context.read<AuthProvider>().currentUser?.uid ?? '';

  // Get full user model details
  UserModel? userProfile = context.read<AuthProvider>().userModel;

### 4. Direct Navigation to Profile
To link to the user profile screen from the sidebar or dashboard[cite: 1]:

  Navigator.push(context, MaterialPageRoute(
    builder: (_) => const ProfileScreen(),
  ));

---

## Dependencies to Add

See pubspec_dependencies.yaml for the exact version constraints[cite: 1].
Key packages: `provider`, `firebase_core`, `firebase_auth`, `cloud_firestore`[cite: 1].

Run `flutter pub get` after updating your dependencies[cite: 1].

---

## Notes

- **State Persistence**: The `AuthProvider` continuously listens to the Firebase Auth state stream. If a user restarts the application, their session is automatically remembered and restored.
- **Cross-Platform Synchronization**: Web environments connect using the credentials inside `firebase_options.dart`, while Android platforms actively read from the native configurations inside `android/app/google-services.json`.
- **Validation Safety**: Email, login forms, and password reset interfaces include built-in structural regex validators to ensure clean inputs are handled before hitting backend servers.
