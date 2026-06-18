import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _announcementsCollection =>
      _firestore.collection('announcements');

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final snapshot = await _announcementsCollection
          .where('isActive', isEqualTo: true)
          .get();
      final list = snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  Future<AnnouncementModel?> getAnnouncementById(String id) async {
    try {
      final doc = await _announcementsCollection.doc(id).get();
      if (doc.exists) return AnnouncementModel.fromFirestore(doc);
      return null;
    } catch (e) {
      throw Exception('Failed to fetch announcement: $e');
    }
  }

  Future<List<AnnouncementModel>> getLatestAnnouncements({int limit = 3}) async {
    try {
      final snapshot = await _announcementsCollection
          .where('isActive', isEqualTo: true)
          .get();
      final list = snapshot.docs
          .map((doc) => AnnouncementModel.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch latest announcements: $e');
    }
  }
}
