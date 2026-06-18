import 'package:cloud_firestore/cloud_firestore.dart';

class VolunteerOpportunityModel {
  final String opportunityId;
  final String title;
  final String description;
  final Timestamp date;
  final String location;
  final String imageUrl;
  final String organizerId;
  final String category;
  final int maxVolunteers;
  final int currentVolunteers;
  final bool isActive;
  final String requirements;

  VolunteerOpportunityModel({
    required this.opportunityId,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.imageUrl = '',
    this.organizerId = '',
    this.category = 'General',
    this.maxVolunteers = 50,
    this.currentVolunteers = 0,
    this.isActive = true,
    this.requirements = '',
  });

  factory VolunteerOpportunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VolunteerOpportunityModel(
      opportunityId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      organizerId: data['organizerId'] ?? '',
      category: data['category'] ?? 'General',
      maxVolunteers: data['maxVolunteers'] ?? 50,
      currentVolunteers: data['currentVolunteers'] ?? 0,
      isActive: data['isActive'] ?? true,
      requirements: data['requirements'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'category': category,
      'maxVolunteers': maxVolunteers,
      'currentVolunteers': currentVolunteers,
      'isActive': isActive,
      'requirements': requirements,
    };
  }

  DateTime get dateTime => date.toDate();
  bool get isFull => currentVolunteers >= maxVolunteers;
  int get remainingSlots => maxVolunteers - currentVolunteers;
}

class VolunteerApplicationModel {
  final String applicationId;
  final String userId;
  final String opportunityId;
  final Timestamp appliedAt;
  final String status; // 'applied', 'confirmed', 'completed', 'cancelled'

  VolunteerApplicationModel({
    required this.applicationId,
    required this.userId,
    required this.opportunityId,
    required this.appliedAt,
    this.status = 'applied',
  });

  factory VolunteerApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VolunteerApplicationModel(
      applicationId: doc.id,
      userId: data['userId'] ?? '',
      opportunityId: data['opportunityId'] ?? '',
      appliedAt: data['appliedAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'applied',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'applicationId': applicationId,
      'userId': userId,
      'opportunityId': opportunityId,
      'appliedAt': appliedAt,
      'status': status,
    };
  }
}
