
# BarakahHub — Member 3 : Nurdanish Effendi bin Roestam Effendi 2224875 : Volunteer Management Module

> **Group 6 | INFO 4335 SEC 1 | Sem 2, 2025/2026**

This document outlines the design, backend structure, and engineering implementation of the **Volunteer Management Module** for BarakahHub, designed and developed exclusively by **Nurdanish (Volunteer Management Lead)**.

---

## 📋 Module Overview & Scope

The **Volunteer Management Module** serves as the core community service engine of BarakahHub. Its purpose is to connect active community members with localized charity work, mosque maintenance, and youth programs.

As the technical lead for this module, I built a highly responsive, secure, and asynchronous pipeline that allows users to seamlessly browse community service roles, track available openings in real time, apply or cancel slots instantly, and view their personal service history.

---

## 🔥 Managed Firestore Collections

To ensure optimal performance and strict data separation, my module owns and operates two specific top-level collections within Cloud Firestore:

### 1. `volunteerOpportunities`

Stores the master details for all active community service programs available in the app.

* **`opportunityId`** *(Document ID)*: Unique identifier for the program.
* **`title`** *(String)*: The name of the volunteer project.
* **`description`** *(String)*: Full details about what the project entails.
* **`requirements`** *(String)*: Special skills, age limits, or items volunteers need to bring.
* **`location`** *(String)*: The physical venue or mosque zone.
* **`date`** *(Timestamp)*: The exact scheduled calendar date and time.
* **`category`** *(String)*: Behavioral tags for filtering (`Community`, `Charity`, `Mosque`, `Youth`, `Other`).
* **`maxVolunteers`** *(Integer)*: The strict maximum capacity limit for the project.
* **`currentVolunteers`** *(Integer)*: A live counter tracking how many spots are currently taken.
* **`imageUrl`** *(String)*: Public web address link for the top display banner.
* **`isActive`** *(Boolean)*: Toggle to instantly show or hide the project from the public feed.

### 2. `volunteerApplications`

Acts as a secure transactional ledger mapping which community members have signed up for which programs.

* **`applicationId`** *(Document ID)*: Unique transactional reference code.
* **`userId`** *(String / Foreign Key)*: References the unique ID of the participating user from the `users` collection.
* **`opportunityId`** *(String / Foreign Key)*: References the targeted project document ID from `volunteerOpportunities`.
* **`appliedAt`** *(Timestamp)*: Precise server timestamp recording when the user tapped join.
* **`status`** *(String)*: Tracks the application lifecycle state (`'applied'`, `'confirmed'`, `'completed'`, or `'cancelled'`).

---

## 📂 Codebase File Architecture

I implemented this module using a clean **Data-Service-Provider-UI** structural pattern to ensure absolute decoupling and maintainability.

```
lib/
├── models/
│   └── volunteer_model.dart       — Handles object modeling, Firestore maps parsing, & UI helpers
├── services/
│   └── volunteer_service.dart     — Low-level Firebase queries & atomic data mutations
├── providers/
│   └── volunteer_provider.dart    — Asynchronous state engine (Provider) managing app loading lifecycles
├── screens/
│   └── volunteers/
│       ├── volunteer_listing_screen.dart — The public feed with gesture filter chips and dynamic progress bars
│       └── volunteer_details_screen.dart — Slivers detail page handling single-tap sign-ups and safe cancellations

```

---

## 🛠️ Key Functionalities & Engineering Implementations

### Object Mapping Integrity (`volunteer_model.dart`)

* **Safe Parsing Factory (`fromFirestore`)**: Extracts raw database maps securely, casting types explicitly and providing clean fallback defaults to shield the app from crashing if any text fields or timestamps are empty.
* **Instant Logic Hooks**: Exposes computed properties directly to layout widgets on demand, including:
* `isFull` $\rightarrow$ Checks if `currentVolunteers` meets or exceeds `maxVolunteers`.
* `remainingSlots` $\rightarrow$ Dynamically outputs remaining spots left for display.



### The Asynchronous Pipeline (`volunteer_provider.dart`)

* **`VolunteerLoadingState` Machine**: Manages the interface lifecycle modes explicitly using an enumeration containing `idle`, `loading`, `loaded`, and `error` parameters. This allows widgets to smoothly transition from skeletal progress wheels to structured data streams or catch errors safely without freezing.
* **Smart Local Data Synced Clears**: Modifying endpoints automatically run micro-fetches to sync internal arrays instantly upon a transaction closing, keeping states fast without forcing full-page reloads.

### Adaptive UI Component Systems (`screens/volunteers/`)

* **Category Tag Filter Rows**: Uses gesture chips updating the provider asynchronously, swapping lists dynamically with a snappy animation.
* **Collapsing Sliver Details Layout**: Extends Flutter’s `CustomScrollView` with a dynamic `SliverAppBar` that compresses smooth background banners beautifully as the screen scrolls.
* **State-Driven Action Toggles**: The primary bottom button reads application records reactively—transforming its text, colors, and capabilities automatically into "Join as Volunteer" (Orange), "Cancel Application" (Red), or "Fully Booked" (Grey) depending on user status and data bounds.

---

## 🔒 Data Security: Atomic Concurrency Protection

To solve the classic development risk where two active users click the last remaining slot at the exact same millisecond—causing counting errors—I designed the enrollment logic around a strict backend **Firestore Write Batch**.

```dart
final batch = _firestore.batch();
final appRef = _applicationsCollection.doc();

// Step 1: Securely stage the user application metadata log
batch.set(appRef, {
  'applicationId': appRef.id,
  'userId': userId,
  'opportunityId': opportunityId,
  'appliedAt': Timestamp.now(),
  'status': 'applied',
});

// Step 2: Push mathematically uncompromised server increments to the slot tracking document
batch.update(_opportunitiesCollection.doc(opportunityId), {
  'currentVolunteers': FieldValue.increment(1),
});

// Step 3: Atomic commit execution
await batch.commit();

```

* **Why it matters:** This block forces document writing and counter ticking to succeed or fail as a single atomic unit. Using server-controlled operations (`FieldValue.increment`) completely bypasses local device miscalculations, guaranteeing flawless transactional data integrity across all active users.

---

## 📝 Team Integration Guidelines

* **Project Requirements**: Relies heavily on the `provider`, `cloud_firestore`, and `intl` packages within your project.
* **Session Interlocks**: The detail screen targets active identities by requesting data pointers through `context.read<AppAuthProvider>().currentUser?.userId`. Ensure an active session state exists before initializing navigation.
* **Global Cache Management**: On global user sign-out prompts, make sure your handler calls `context.read<VolunteerProvider>().reset()` to instantly flush memory allocations, keeping user data safe and ready for the next account session.