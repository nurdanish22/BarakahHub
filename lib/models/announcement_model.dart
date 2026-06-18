import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String announcementId;
  final String title;
  final String content;
  final Timestamp date;
  final String imageUrl;
  final String category;
  final bool isActive;
  final String organizerId;

  AnnouncementModel({
    required this.announcementId,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl = '',
    this.category = 'General',
    this.isActive = true,
    this.organizerId = '',
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      announcementId: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      date: data['date'] ?? Timestamp.now(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      isActive: data['isActive'] ?? true,
      organizerId: data['organizerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'title': title,
      'content': content,
      'date': date,
      'imageUrl': imageUrl,
      'category': category,
      'isActive': isActive,
      'organizerId': organizerId,
    };
  }

  DateTime get dateTime => date.toDate();
}
