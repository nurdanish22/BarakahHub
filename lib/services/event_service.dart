import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _eventsCollection =>
      _firestore.collection('events');
  CollectionReference get _registrationsCollection =>
      _firestore.collection('eventRegistrations');

  // ─────────────────────────────────────────────
  // EVENT FETCHING
  // ─────────────────────────────────────────────

  Stream<List<EventModel>> getUpcomingEventsStream() {
    return _eventsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final snapshot = await _eventsCollection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming events: $e');
    }
  }

  Future<EventModel?> getEventById(String eventId, {bool forceServer = false}) async {
    try {
      final doc = await _eventsCollection.doc(eventId).get(
        forceServer ? const GetOptions(source: Source.server) : const GetOptions(source: Source.serverAndCache),
      );
      if (doc.exists) {
        return EventModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch event: $e');
    }
  }

  Stream<EventModel?> getEventStream(String eventId) {
    return _eventsCollection.doc(eventId).snapshots().map((doc) {
      if (doc.exists) return EventModel.fromFirestore(doc);
      return null;
    });
  }

  // ─────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────

  Future<List<EventModel>> searchEvents(String query) async {
    if (query.trim().isEmpty) return getUpcomingEvents();

    try {
      final snapshot = await _eventsCollection
          .where('isActive', isEqualTo: true)
          .get();

      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((event) =>
              event.title.toLowerCase().contains(lowerQuery) ||
              event.description.toLowerCase().contains(lowerQuery) ||
              event.location.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  Future<List<EventModel>> getEventsByCategory(String category) async {
    try {
      final snapshot = await _eventsCollection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .where((e) => e.category == category)
          .toList();
    } catch (e) {
      throw Exception('Failed to filter events by category: $e');
    }
  }

  // ─────────────────────────────────────────────
  // EVENT REGISTRATION
  // ─────────────────────────────────────────────

  Future<void> registerForEvent({
    required String userId,
    required String eventId,
  }) async {
    // Check for duplicate outside the transaction (queries can't run inside)
    final existing = await _registrationsCollection
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You are already registered for this event.');
    }

    final eventRef = _eventsCollection.doc(eventId);
    final registrationRef = _registrationsCollection.doc();

    await _firestore.runTransaction((tx) async {
      final eventDoc = await tx.get(eventRef);
      if (!eventDoc.exists) throw Exception('Event not found.');

      final data = eventDoc.data() as Map<String, dynamic>;
      final current = (data['currentParticipants'] as int?) ?? 0;
      final max = (data['maxParticipants'] as int?) ?? 100;

      if (current >= max) throw Exception('This event is fully booked.');

      tx.set(registrationRef, {
        'registrationId': registrationRef.id,
        'userId': userId,
        'eventId': eventId,
        'registeredAt': Timestamp.now(),
        'status': 'confirmed',
      });

      // Explicit read-then-write so count is always accurate
      tx.update(eventRef, {'currentParticipants': current + 1});
    });
  }

  Future<void> cancelRegistration({
    required String userId,
    required String eventId,
  }) async {
    final snapshot = await _registrationsCollection
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Registration not found.');
    }

    final cancelCount = snapshot.docs.length;
    final eventRef = _eventsCollection.doc(eventId);

    await _firestore.runTransaction((tx) async {
      final eventDoc = await tx.get(eventRef);
      if (!eventDoc.exists) throw Exception('Event not found.');

      final data = eventDoc.data() as Map<String, dynamic>;
      final current = (data['currentParticipants'] as int?) ?? 0;
      // Clamp to 0 — this self-corrects any previous drift
      final newCount = (current - cancelCount).clamp(0, 999999);

      for (final doc in snapshot.docs) {
        tx.update(doc.reference, {'status': 'cancelled'});
      }

      tx.update(eventRef, {'currentParticipants': newCount});
    });
  }

  /// Recalculates currentParticipants from actual confirmed registrations.
  /// Call this from the admin panel to fix any drifted counts.
  Future<int> recalculateParticipantCount(String eventId) async {
    final confirmed = await _registrationsCollection
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    final correctCount = confirmed.docs.length;
    await _eventsCollection.doc(eventId).update({
      'currentParticipants': correctCount,
    });
    return correctCount;
  }

  Future<bool> isUserRegistered({
    required String userId,
    required String eventId,
  }) async {
    final snapshot = await _registrationsCollection
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // ─────────────────────────────────────────────
  // USER REGISTERED EVENTS
  // ─────────────────────────────────────────────

  Future<List<EventModel>> getUserRegisteredEvents(String userId) async {
    try {
      final regSnapshot = await _registrationsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'confirmed')
          .get();

      if (regSnapshot.docs.isEmpty) return [];

      final eventIds = regSnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['eventId'] as String)
          .toList();

      final List<EventModel> events = [];
      for (int i = 0; i < eventIds.length; i += 10) {
        final batch = eventIds.sublist(
            i, i + 10 > eventIds.length ? eventIds.length : i + 10);
        final eventsSnapshot = await _eventsCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        events.addAll(eventsSnapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
      }

      events.sort((a, b) => a.date.compareTo(b.date));
      return events;
    } catch (e) {
      throw Exception('Failed to fetch registered events: $e');
    }
  }

  Stream<List<EventRegistrationModel>> getUserRegistrationsStream(
      String userId) {
    return _registrationsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventRegistrationModel.fromFirestore(doc))
            .toList());
  }
}