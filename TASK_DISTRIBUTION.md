# BarakahHub – Group Task Distribution

> **Team Size:** 4 Members | **Platform:** Flutter + Firebase

---

## Member 1 – Authentication & User Profile Lead

### Modules
- **Module 1: User Authentication** – Registration, Login, Forgot Password, Logout, Firebase Auth integration
- **Module 5: User Profile** – View/Edit Profile, Event Participation History, Volunteer History

### Screens
| Screen | Description |
|--------|-------------|
| Splash Screen | App entry point |
| Login Screen | Email/password login |
| Register Screen | New user registration |
| Forgot Password Screen | Password reset via email |
| User Profile Screen | View and edit user profile |

### Firebase Work
- Firebase Authentication
- Firestore `users` collection

### Deliverables
```
models/user_model.dart
services/auth_service.dart
providers/auth_provider.dart
screens/auth/login_screen.dart
screens/auth/register_screen.dart
screens/auth/forgot_password_screen.dart
screens/profile/profile_screen.dart
screens/profile/edit_profile_screen.dart
```

### Additional Responsibilities
- User model creation
- Authentication provider (session management)
- Form validation logic

---

## Member 2 – Event Management Lead

### Modules
- **Module 2: Event Management** – View Upcoming Events, Search Events, Event Details, Event Registration, View Registered Events

### Screens
| Screen | Description |
|--------|-------------|
| Dashboard Event Section | Event summary on home |
| Event Listing Screen | Browse all upcoming events |
| Event Details Screen | Full event info + register button |
| My Registered Events Screen | User's registered events list |

### Firebase Work
- Firestore `events` collection
- Event registration records

### Deliverables
```
models/event_model.dart
services/event_service.dart
providers/event_provider.dart
screens/events/event_list_screen.dart
screens/events/event_detail_screen.dart
screens/events/my_events_screen.dart
widgets/event_card.dart
```

### Additional Responsibilities
- Event search and filter functionality
- Event card UI component
- Event registration & participation tracking logic

---

## Member 3 – Volunteer Management Lead

### Modules
- **Module 3: Volunteer Management** – Browse Opportunities, Volunteer Registration, Status Tracking, Volunteer History

### Screens
| Screen | Description |
|--------|-------------|
| Volunteer Opportunities Screen | List of open volunteer roles |
| Volunteer Details Screen | Role info + apply button |
| Volunteer History Screen | User's past volunteer records |

### Firebase Work
- Firestore `volunteers` collection
- Volunteer status updates

### Deliverables
```
models/volunteer_model.dart
services/volunteer_service.dart
providers/volunteer_provider.dart
screens/volunteers/volunteer_list_screen.dart
screens/volunteers/volunteer_detail_screen.dart
screens/volunteers/volunteer_history_screen.dart
widgets/volunteer_card.dart
```

### Additional Responsibilities
- Volunteer application system
- Volunteer history tracking
- Volunteer status management (pending / accepted / completed)

---

## Member 4 – Announcements, Notifications & Integration Lead

### Modules
- **Module 4: Community Announcements** – View Announcements, Announcement Details, Event Reminders
- **Module 6: Push Notifications** – New Event Alerts, Volunteer Updates, Community Announcements

### Screens
| Screen | Description |
|--------|-------------|
| Dashboard Screen | App home with bottom nav |
| Announcements Screen | List of community announcements |
| Announcement Details Screen | Full announcement content |

### Firebase Work
- Firestore `announcements` collection
- Firebase Cloud Messaging (FCM)

### Deliverables
```
models/announcement_model.dart
services/announcement_service.dart
services/notification_service.dart
providers/announcement_provider.dart
screens/announcements/announcement_list_screen.dart
screens/announcements/announcement_detail_screen.dart
screens/dashboard/dashboard_screen.dart
```

### Additional Responsibilities
- Bottom Navigation Bar implementation
- Push notification setup (FCM)
- Dashboard integration of all modules
- Final system integration & app-wide bug fixing

---

## Shared Responsibilities (All Members)

| Task | All Members |
|------|-------------|
| UI Design Discussion | ✅ |
| Firebase Project Setup | ✅ |
| Unit & Widget Testing | ✅ |
| Debugging | ✅ |
| Documentation | ✅ |
| Presentation Preparation | ✅ |
| GitHub Repository Management | ✅ |

---

## Workload Summary

| Member | Main Modules | Screens | Estimated Workload |
|--------|-------------|---------|-------------------|
| Member 1 | Authentication + Profile | 5 | 25% |
| Member 2 | Event Management | 4 | 25% |
| Member 3 | Volunteer Management | 3 | 25% |
| Member 4 | Announcements + Notifications + Integration | 3 + Dashboard | 25% |

### Why This Division Is Balanced

Each member handles:
- 1–2 major modules
- 3–5 screens
- Firebase integration for their domain
- Provider state management (Provider pattern)
- Data models and service classes
- Testing of their own module

This structure **minimises merge conflicts** on GitHub since each member owns separate files and directories, making collaboration clean and straightforward.

---

## Firebase Collections Overview

| Collection | Owner |
|------------|-------|
| `users` | Member 1 |
| `events` | Member 2 |
| `volunteers` | Member 3 |
| `announcements` | Member 4 |

---

## Folder Structure Reference

```
lib/
├── models/
│   ├── user_model.dart          # Member 1
│   ├── event_model.dart         # Member 2
│   ├── volunteer_model.dart     # Member 3
│   └── announcement_model.dart  # Member 4
├── services/
│   ├── auth_service.dart        # Member 1
│   ├── event_service.dart       # Member 2
│   ├── volunteer_service.dart   # Member 3
│   ├── announcement_service.dart# Member 4
│   └── notification_service.dart# Member 4
├── providers/
│   ├── auth_provider.dart       # Member 1
│   ├── event_provider.dart      # Member 2
│   ├── volunteer_provider.dart  # Member 3
│   └── announcement_provider.dart# Member 4
├── screens/
│   ├── auth/                    # Member 1
│   ├── profile/                 # Member 1
│   ├── events/                  # Member 2
│   ├── volunteers/              # Member 3
│   ├── announcements/           # Member 4
│   └── dashboard/               # Member 4
└── widgets/
    ├── event_card.dart          # Member 2
    └── volunteer_card.dart      # Member 3
```
