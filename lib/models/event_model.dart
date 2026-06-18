import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String eventId;
  final String title;
  final String description;
  final Timestamp date;
  final String location;
  final String imageUrl;
  final String organizerId;
  final String category;
  final int maxParticipants;
  final int currentParticipants;
  final bool isActive;

  EventModel({
    required this.eventId,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.organizerId = '',
    this.category = 'General',
    this.maxParticipants = 100,
    this.currentParticipants = 0,
    this.isActive = true,
  });

  /// Convert Firestore document snapshot to EventModel
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      eventId: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      organizerId: data['organizerId'] ?? '',
      category: data['category'] ?? 'General',
      maxParticipants: data['maxParticipants'] ?? 100,
      currentParticipants: data['currentParticipants'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert EventModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'description': description,
      'date': date,
      'location': location,
      'imageUrl': imageUrl,
      'organizerId': organizerId,
      'category': category,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'isActive': isActive,
    };
  }

  /// Copy with updated fields
  EventModel copyWith({
    String? eventId,
    String? title,
    String? description,
    Timestamp? date,
    String? location,
    String? imageUrl,
    String? organizerId,
    String? category,
    int? maxParticipants,
    int? currentParticipants,
    bool? isActive,
  }) {
    return EventModel(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      organizerId: organizerId ?? this.organizerId,
      category: category ?? this.category,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get DateTime from Timestamp
  DateTime get dateTime => date.toDate();

  /// Check if event is upcoming (date is in the future)
  bool get isUpcoming => dateTime.isAfter(DateTime.now());

  /// Check if event is full
  bool get isFull => currentParticipants >= maxParticipants;

  /// Remaining slots
  int get remainingSlots => maxParticipants - currentParticipants;
}

/// Model for event registration (stored in `eventRegistrations` sub-collection or separate collection)
class EventRegistrationModel {
  final String registrationId;
  final String userId;
  final String eventId;
  final Timestamp registeredAt;
  final String status; // 'confirmed', 'pending', 'cancelled'

  EventRegistrationModel({
    required this.registrationId,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.status = 'confirmed',
  });

  factory EventRegistrationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventRegistrationModel(
      registrationId: doc.id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      registeredAt: data['registeredAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'confirmed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'registrationId': registrationId,
      'userId': userId,
      'eventId': eventId,
      'registeredAt': registeredAt,
      'status': status,
    };
  }
}
