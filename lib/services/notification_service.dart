import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/app_navigator.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize({String? userId}) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _setupToken(userId);
      _listenToForegroundMessages();
    }
  }

  Future<void> _setupToken(String? userId) async {
    try {
      final token = await _messaging.getToken();
      if (token != null && userId != null) {
        await _saveTokenToFirestore(userId, token);
      }

      _messaging.onTokenRefresh.listen((newToken) {
        if (userId != null) _saveTokenToFirestore(userId, newToken);
      });
    } catch (e) {
      debugPrint('Error setting up FCM token: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'tokenUpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title ?? 'New Notification',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
                if (notification.body != null && notification.body!.isNotEmpty)
                  Text(
                    notification.body!,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
              ],
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1A6B3C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  Future<void> removeToken(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('Error removing FCM token: $e');
    }
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message: ${message.notification?.title}');
  }
}
