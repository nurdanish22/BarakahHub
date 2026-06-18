import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/announcement_model.dart';
import '../models/volunteer_model.dart';
import 'event_service.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Events ───────────────────────────────────────────────────────────────

  Future<List<EventModel>> getAllEvents() async {
    final snap = await _db.collection('events').get();
    final list = snap.docs.map((d) => EventModel.fromFirestore(d)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    final ref = _db.collection('events').doc();
    data['eventId'] = ref.id;
    await ref.set(data);
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    await _db.collection('events').doc(id).update(data);
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }

  Future<int> fixEventParticipantCount(String eventId) =>
      EventService().recalculateParticipantCount(eventId);

  // ── Announcements ─────────────────────────────────────────────────────────

  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    final snap = await _db.collection('announcements').get();
    final list = snap.docs.map((d) => AnnouncementModel.fromFirestore(d)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    final ref = _db.collection('announcements').doc();
    data['announcementId'] = ref.id;
    await ref.set(data);
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    await _db.collection('announcements').doc(id).update(data);
  }

  Future<void> deleteAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }

  // ── Volunteer Opportunities ───────────────────────────────────────────────

  Future<List<VolunteerOpportunityModel>> getAllVolunteerOpportunities() async {
    final snap = await _db.collection('volunteerOpportunities').get();
    final list = snap.docs.map((d) => VolunteerOpportunityModel.fromFirestore(d)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> createVolunteerOpportunity(Map<String, dynamic> data) async {
    final ref = _db.collection('volunteerOpportunities').doc();
    data['opportunityId'] = ref.id;
    await ref.set(data);
  }

  Future<void> updateVolunteerOpportunity(String id, Map<String, dynamic> data) async {
    await _db.collection('volunteerOpportunities').doc(id).update(data);
  }

  Future<void> deleteVolunteerOpportunity(String id) async {
    await _db.collection('volunteerOpportunities').doc(id).delete();
  }
}
