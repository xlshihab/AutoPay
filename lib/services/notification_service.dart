import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Create notification channel and request permission
    const channel = AndroidNotificationChannel(
      'transactions_channel',
      'Transactions',
      description: 'Notifications for new transactions',
      importance: Importance.high,
    );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  // Show custom notification
  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general_channel',
      'General',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // Handle FCM message and show notification
  static Future<void> handleFCMMessage(RemoteMessage message) async {
    final data = message.data;

    if (!data.containsKey('type')) return;

    final type = data['type'];
    final amount = data['amount'] ?? '0';
    final userName = data['userName'] ?? 'Unknown';
    final phoneNumber = data['phoneNumber'] ?? '';
    final trxId = data['trxId'] ?? '';
    final method = data['method'] ?? '';
    final status = data['status'] ?? 'pending';

    String title = '';
    String body = '';

    switch (type) {
      case 'deposit':
        title = '💰 নতুন ডিপোজিট রিকুয়েস্ট';
        body = 'Name: $userName\n'
               'Phone: $phoneNumber\n'
               'Amount: ৳$amount\n'
               'TrxID: $trxId\n'
               'Status: $status';
        break;
      case 'entry_fee':
        title = '🎮 নতুন এন্ট্রি ফি';
        body = 'Name: $userName\n'
               'Phone: $phoneNumber\n'
               'Amount: ৳$amount\n'
               'TrxID: $trxId\n'
               'Status: $status';
        break;
      case 'withdraw':
        title = '💸 নতুন উইথড্র রিকুয়েস্ট';
        body = 'Name: $userName\n'
               'Phone: $phoneNumber\n'
               'Amount: ৳$amount\n'
               'Method: $method\n'
               'Status: $status';
        break;
      default:
        return;
    }

    // Show local notification with full details
    final androidDetails = AndroidNotificationDetails(
      'transactions_channel',
      'Transactions',
      channelDescription: 'Notifications for new transactions',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
