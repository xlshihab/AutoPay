import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseService.initialize();
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase init error: $e');
  }
  
  // Initialize Notifications
  try {
    await NotificationService.initialize();
    print('✅ Notification service initialized');
  } catch (e) {
    print('❌ Notification init error: $e');
  }
  
  // Initialize FCM with status check
  try {
    bool fcmStatus = await FCMService.initialize();
    if (fcmStatus) {
      print('✅ FCM initialized and token saved');
    } else {
      print('⚠️ FCM initialized but token not saved');
    }
  } catch (e) {
    print('❌ FCM init error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
