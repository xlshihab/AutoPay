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
  static bool _tokenSaved = false;

  // Initialize FCM
  static Future<bool> initialize() async {
    if (_initialized) return _tokenSaved;

    try {
      // Get token first (no permission needed for this)
      String? token = await _messaging.getToken();
      print('🔵 FCM Token retrieved: ${token?.substring(0, 20)}...');
      
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('🔵 FCM Permission: ${settings.authorizationStatus}');

      // Save token regardless of permission (for future use)
      if (token != null) {
        bool saved = await _saveFCMToken(token);
        _tokenSaved = saved;
        print(saved ? '✅ FCM Token saved successfully' : '❌ FCM Token save failed');
      }

      // Setup handlers only if authorized
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Listen to token refresh
        _messaging.onTokenRefresh.listen((newToken) async {
          await _saveFCMToken(newToken);
        });

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
      }

      _initialized = true;
      return _tokenSaved;
    } catch (e) {
      print('❌ FCM initialization error: $e');
      return false;
    }
  }

  // Save FCM token to Firestore
  static Future<bool> _saveFCMToken(String token) async {
    try {
      print('🔵 Saving FCM token to Firestore...');
      
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
          print('✅ Token added to existing array');
        } else {
          print('ℹ️ Token already exists in array');
        }
      } else {
        // Create new document with tokens array
        await docRef.set({
          'tokens': [token],
          'updatedAt': FieldValue.serverTimestamp(),
          'platform': 'android',
        });
        print('✅ New token document created');
      }
      
      _tokenSaved = true;
      return true;
    } catch (e) {
      print('❌ Token save error: $e');
      return false;
    }
  }

  // Check if token is saved
  static Future<bool> isTokenSaved() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) return false;

      final docRef = FirebaseFirestore.instance
          .collection('device_tokens')
          .doc('admin_device');
      
      final doc = await docRef.get();
      if (!doc.exists) return false;

      final data = doc.data();
      List<String> tokens = List<String>.from(data?['tokens'] ?? []);
      return tokens.contains(token);
    } catch (e) {
      return false;
    }
  }

  // Force save token (manual trigger)
  static Future<bool> forceSaveToken() async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) {
        print('❌ No FCM token available');
        return false;
      }
      return await _saveFCMToken(token);
    } catch (e) {
      print('❌ Force save error: $e');
      return false;
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
