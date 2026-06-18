# BarakahHub — Member 2: Event Management

> **Group 6 | INFO 4335 SEC 1 | Sem 2, 2025/2026**

This folder contains all files owned by **Member 2** for the BarakahHub Flutter project.

---

## Modules Covered

### Module 2: Event Management
- View Upcoming Events
- Search Events
- Event Details
- Event Registration (register & cancel)
- View Registered Events

---

## File Structure

```
lib/
├── models/
│   └── event_model.dart           ← EventModel + EventRegistrationModel
│
├── services/
│   └── event_service.dart         ← All Firestore read/write for events
│
├── providers/
│   └── event_provider.dart        ← State management (Provider pattern)
│
├── screens/
│   └── events/
│       ├── event_listing_screen.dart       ← Browse + search all events
│       ├── event_details_screen.dart       ← Full event detail + register
│       └── my_registered_events_screen.dart ← User's registered events
│
└── widgets/
    ├── event_card.dart                     ← Reusable event list card
    └── dashboard_events_section.dart       ← Drop-in for Member 4's dashboard
```

---

## Firestore Collections Used

### `events`
| Field | Type | Notes |
|---|---|---|
| `eventId` | String | Auto-generated doc ID |
| `title` | String | |
| `description` | String | |
| `date` | Timestamp | |
| `location` | String | |
| `imageUrl` | String | Firebase Storage URL |
| `organizerId` | String | UID of organizer |
| `category` | String | e.g. Tazkirah, Charity |
| `maxParticipants` | int | |
| `currentParticipants` | int | Managed atomically via batch writes |
| `isActive` | bool | Soft delete flag |

### `eventRegistrations`
| Field | Type | Notes |
|---|---|---|
| `registrationId` | String | Auto-generated doc ID |
| `userId` | String | Firebase Auth UID |
| `eventId` | String | Reference to events collection |
| `registeredAt` | Timestamp | |
| `status` | String | `confirmed` / `cancelled` |

---

## How to Wire Up (Integration Guide)

### 1. Register the provider in `main.dart`
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => EventProvider()),
    // ... other providers
  ],
  child: const MyApp(),
)
```

### 2. Add EventProvider.loadUpcomingEvents() on app launch
Call this when the dashboard initialises so events are pre-loaded:
```dart
// Inside Member 4's DashboardScreen initState:
context.read<EventProvider>().loadUpcomingEvents();
```

### 3. Use the Dashboard widget (Member 4 integration)
```dart
// Inside your dashboard body column:
const DashboardEventsSection(),
```

### 4. Navigate to Event Listing
```dart
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const EventListingScreen(),
));
```

### 5. Replace the placeholder userId
All screens use `'PLACEHOLDER_USER_ID'`. Replace this with:
```dart
context.read<AuthProvider>().currentUser?.uid ?? ''
```

---

## Firestore Index Requirements

Create these composite indexes in the Firebase Console:

| Collection | Fields | Order |
|---|---|---|
| `events` | `isActive` ASC, `date` ASC | — |
| `events` | `isActive` ASC, `category` ASC, `date` ASC | — |
| `events` | `isActive` ASC, `titleLowercase` ASC | — |
| `eventRegistrations` | `userId` ASC, `status` ASC | — |
| `eventRegistrations` | `userId` ASC, `eventId` ASC, `status` ASC | — |

---

## Dependencies to Add

See `pubspec_dependencies.yaml` for the exact version constraints.
Key packages: `provider`, `cloud_firestore`, `intl`, `cached_network_image`.

Run `flutter pub get` after updating pubspec.

---

## Notes

- **Search**: Firestore doesn't support full-text search natively. The current implementation uses a `titleLowercase` prefix range query. For production, consider Algolia or Firebase Extensions (Typesense).
- **Registration safety**: Uses Firestore **batch writes** to atomically register a user AND increment `currentParticipants` — no double-counting.
- **Real-time**: `getUpcomingEventsStream()` and `getEventStream()` are available for live updates if needed.
- **Theme colour**: `#1A6B3C` (deep Islamic green) is used consistently. Update if the team agrees on a different primary colour.
