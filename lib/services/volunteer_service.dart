import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer_model.dart';

class VolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _opportunitiesCollection =>
      _firestore.collection('volunteerOpportunities');
  CollectionReference get _applicationsCollection =>
      _firestore.collection('volunteerApplications');

  Future<List<VolunteerOpportunityModel>> getOpportunities() async {
    try {
      final snapshot = await _opportunitiesCollection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => VolunteerOpportunityModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch volunteer opportunities: $e');
    }
  }

  Future<VolunteerOpportunityModel?> getOpportunityById(String id) async {
    try {
      final doc = await _opportunitiesCollection.doc(id).get();
      if (doc.exists) return VolunteerOpportunityModel.fromFirestore(doc);
      return null;
    } catch (e) {
      throw Exception('Failed to fetch opportunity: $e');
    }
  }

  Future<List<VolunteerOpportunityModel>> getOpportunitiesByCategory(
      String category) async {
    try {
      final snapshot = await _opportunitiesCollection
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => VolunteerOpportunityModel.fromFirestore(doc))
          .where((o) => o.category == category)
          .toList();
    } catch (e) {
      throw Exception('Failed to filter opportunities: $e');
    }
  }

  Future<void> applyForOpportunity({
    required String userId,
    required String opportunityId,
  }) async {
    final existing = await _applicationsCollection
        .where('userId', isEqualTo: userId)
        .where('opportunityId', isEqualTo: opportunityId)
        .where('status', whereIn: ['applied', 'confirmed'])
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already applied for this opportunity.');
    }

    final oppDoc = await _opportunitiesCollection.doc(opportunityId).get();
    if (!oppDoc.exists) throw Exception('Opportunity not found.');
    final opp = VolunteerOpportunityModel.fromFirestore(oppDoc);
    if (opp.isFull) throw Exception('This opportunity is fully booked.');

    final batch = _firestore.batch();

    final appRef = _applicationsCollection.doc();
    batch.set(appRef, {
      'applicationId': appRef.id,
      'userId': userId,
      'opportunityId': opportunityId,
      'appliedAt': Timestamp.now(),
      'status': 'applied',
    });

    batch.update(_opportunitiesCollection.doc(opportunityId), {
      'currentVolunteers': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> cancelApplication({
    required String userId,
    required String opportunityId,
  }) async {
    final snapshot = await _applicationsCollection
        .where('userId', isEqualTo: userId)
        .where('opportunityId', isEqualTo: opportunityId)
        .where('status', whereIn: ['applied', 'confirmed'])
        .get();

    if (snapshot.docs.isEmpty) throw Exception('Application not found.');

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'status': 'cancelled'});
    }
    batch.update(_opportunitiesCollection.doc(opportunityId), {
      'currentVolunteers': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Future<bool> hasApplied({
    required String userId,
    required String opportunityId,
  }) async {
    final snapshot = await _applicationsCollection
        .where('userId', isEqualTo: userId)
        .where('opportunityId', isEqualTo: opportunityId)
        .where('status', whereIn: ['applied', 'confirmed'])
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<List<VolunteerOpportunityModel>> getUserVolunteerHistory(
      String userId) async {
    try {
      final appSnapshot = await _applicationsCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (appSnapshot.docs.isEmpty) return [];

      final opportunityIds = appSnapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['opportunityId'] as String)
          .toSet()
          .toList();

      final List<VolunteerOpportunityModel> opportunities = [];
      for (int i = 0; i < opportunityIds.length; i += 10) {
        final batch = opportunityIds.sublist(
            i, i + 10 > opportunityIds.length ? opportunityIds.length : i + 10);
        final snap = await _opportunitiesCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        opportunities.addAll(snap.docs
            .map((doc) => VolunteerOpportunityModel.fromFirestore(doc))
            .toList());
      }

      opportunities.sort((a, b) => b.date.compareTo(a.date));
      return opportunities;
    } catch (e) {
      throw Exception('Failed to fetch volunteer history: $e');
    }
  }

  Future<String> getApplicationStatus({
    required String userId,
    required String opportunityId,
  }) async {
    final snapshot = await _applicationsCollection
        .where('userId', isEqualTo: userId)
        .where('opportunityId', isEqualTo: opportunityId)
        .get();
    if (snapshot.docs.isEmpty) return 'none';
    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return data['status'] ?? 'none';
  }
}
