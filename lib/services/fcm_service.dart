import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notification
  await NotificationService.handleFCMMessage(message);
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static bool _initialized = false;

  // Initialize FCM
  static Future<void> initialize() async {
    if (_initialized) return;

    // Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_saveFCMToken);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        NotificationService.handleFCMMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle notification tap (app opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle notification tap
      });

      _initialized = true;
    }
  }

  // Save FCM token to Firestore
  static Future<void> _saveFCMToken(String token) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('device_tokens')
          .doc('admin_device');
      
      final doc = await docRef.get();
      
      if (doc.exists) {
        // Add token to array if not exists
        final data = doc.data();
        List<String> tokens = List<String>.from(data?['tokens'] ?? []);
        
        if (!tokens.contains(token)) {
          tokens.add(token);
          await docRef.update({
            'tokens': tokens,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Create new document with tokens array
        await docRef.set({
          'tokens': [token],
          'updatedAt': FieldValue.serverTimestamp(),
          'platform': 'android',
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  // Get current FCM token
  static Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Delete token (for logout)
  static Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }
}
