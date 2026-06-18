# BarakahHub

A Flutter mobile application for Muslim community management — connecting members with events, volunteer opportunities, and announcements through a live Firebase backend.

---

## Overview

| Item | Detail |
|---|---|
| Platform | Android & iOS (Flutter cross-platform) |
| Backend | Firebase (Auth, Firestore, Cloud Messaging) |
| Repository | github.com/nurdanish22/BarakahHub |
| Default Branch | master |
| Version | 1.0.0 |
| Firebase Project | barakahhub-ef014 |

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (Dart) |
| State Management | Provider |
| Authentication | Firebase Auth |
| Database | Cloud Firestore |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Date Formatting | intl package |

---

## Project Structure

```
lib/
├── main.dart                  — App entry point, Firebase init, providers
├── firebase_options.dart      — Firebase project config
├── utils/
│   └── app_navigator.dart     — Global navigator key (for notifications)
├── models/
│   ├── user_model.dart
│   ├── event_model.dart
│   ├── announcement_model.dart
│   └── volunteer_model.dart
├── services/
│   ├── auth_service.dart
│   ├── event_service.dart
│   ├── announcement_service.dart
│   ├── volunteer_service.dart
│   ├── admin_service.dart
│   └── notification_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── event_provider.dart
│   ├── announcement_provider.dart
│   └── volunteer_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── main_screen.dart
│   ├── auth/                  — Login, Register, Forgot Password
│   ├── dashboard/             — Home screen
│   ├── events/                — Listing, Details, My Registered Events
│   ├── announcements/         — Listing, Details
│   ├── volunteers/            — Listing, Details
│   ├── profile/               — Profile, Edit Profile
│   └── admin/                 — Admin Panel + 3 form screens
└── widgets/                   — Reusable UI components
```

---

## Firestore Database Structure

```
users/{userId}
  — userId, name, email, phone, role
  — location, bio
  — fcmToken, tokenUpdatedAt

events/{eventId}
  — title, description, location
  — date (Timestamp), category
  — maxParticipants, currentParticipants
  — imageUrl, organizerId, isActive

eventRegistrations/{registrationId}
  — userId, eventId
  — registeredAt (Timestamp)
  — status: 'confirmed' | 'cancelled'

announcements/{announcementId}
  — title, content
  — date (Timestamp), category
  — imageUrl, organizerId, isActive

volunteerOpportunities/{opportunityId}
  — title, description, location, requirements
  — date (Timestamp), category
  — maxVolunteers, currentVolunteers
  — imageUrl, organizerId, isActive

volunteerApplications/{applicationId}
  — userId, opportunityId
  — appliedAt (Timestamp)
  — status: 'applied' | 'confirmed' | 'completed' | 'cancelled'
```

---

## Screens & Features

### Splash Screen
- Animated logo with fade and scale transition
- Restores login session automatically on app launch
- Initialises FCM notifications if session exists

### Login & Register
- Email and password authentication via Firebase Auth
- Register creates a Firestore user document with default role `Community Member`
- FCM token saved on login and register
- Forgot password flow included

### Dashboard (Home)
- Greeting: "Assalamualaikum, [first name]" with today's date
- Three sections: Upcoming Events, Announcements, Volunteer Opportunities
- Pull-to-refresh on all sections
- "See all" navigates to the relevant tab

### Events
- Search bar and category filter chips
- **Categories:** All · Tazkirah · Charity · Education · Community · Youth · Other
- Event detail: full info, participant count, registration progress bar
- Register / Cancel Registration with confirmation dialog
- Participant count uses Firestore transactions — always accurate

### Announcements
- Category badge and date + time on each card
- **Categories:** General · News · Reminder · Event · Volunteer · Important · Other
- Detail screen shows full content with optional banner image

### Volunteers
- Category filter chips
- **Categories:** All · Community · Charity · Education · Mosque · Youth · Other
- Apply / Cancel Application flow
- Volunteer count tracked in Firestore

### Profile
- Avatar with initials, name, email, phone, location, bio, role badge
- Shows registered events and volunteer history
- Edit Profile: name, phone, location, bio (email is read-only)
- Logout with confirmation dialog

---

## Admin Panel

### How to Unlock Admin Access
1. Go to the **Profile** tab
2. Scroll to the bottom and tap **`BarakahHub v1.0.0`** five times quickly
3. Enter the passcode: **`BARAKAH2024`**
4. Your account is promoted to Admin in Firestore instantly
5. A green **Admin Panel** button appears on your Profile

### Admin Capabilities

| Section | Create | Edit | Delete | Fix Count |
|---|---|---|---|---|
| Events | ✓ | ✓ | ✓ | ✓ |
| Announcements | ✓ | ✓ | ✓ | — |
| Volunteers | ✓ | ✓ | ✓ | — |

### Event / Volunteer Form Fields
- Title, Description, Location, Requirements (volunteers only)
- Date + Time picker
- Category dropdown
- Max Participants / Max Volunteers
- Image URL with live preview
- Active toggle (hide or show from users)

### Announcement Form Fields
- Title, Content
- Date + Time picker
- Category dropdown
- Active toggle

### Fix Count (Events)
Each event card in the admin panel has a sync button. Tapping it recalculates `currentParticipants` by counting actual confirmed registrations in Firestore — use this if the count ever appears wrong.

---

## How to Add Content

1. Log in to the app
2. Go to **Profile** → tap version text 5 times → enter `BARAKAH2024`
3. Tap **Admin Panel**
4. Select a tab: Events, Announcements, or Volunteers
5. Tap **+ Add New**
6. Fill in the form and tap **Save**
7. Content appears immediately for all users

---

## Push Notifications

- FCM token saved to the user's Firestore document on login
- Token auto-refreshes when it changes
- Background messages handled by `_firebaseMessagingBackgroundHandler` in `main.dart`
- Foreground messages displayed as a floating green SnackBar with title and body
- Token removed from Firestore on logout

---

## User Roles

| Role | Access |
|---|---|
| `Community Member` | Default for all new signups |
| `Admin` | Unlocked via passcode — full content management |

---

## Adding Images to Events / Volunteers

Events and volunteers support a banner image via a public URL. Free image sources:

- **unsplash.com** — search for a topic, right-click the image, select "Copy image address"
- **picsum.photos/800/400** — random placeholder image
- Any direct `.jpg` or `.png` URL from the web works

---

## Getting Started (Development)

### Prerequisites
- Flutter SDK `^3.11.1`
- Android Studio or VS Code with Flutter extension
- A Firebase project with Android and iOS apps configured

### Setup
```bash
git clone https://github.com/nurdanish22/BarakahHub.git
cd BarakahHub
flutter pub get
flutter run
```

### Firebase Configuration
- `android/app/google-services.json` — Android Firebase config (already included)
- `ios/Runner/GoogleService-Info.plist` — iOS Firebase config
- `lib/firebase_options.dart` — generated Firebase options for all platforms
