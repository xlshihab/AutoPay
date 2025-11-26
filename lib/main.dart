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
  } catch (e) {
    // Handle silently
  }
  
  // Initialize Notifications
  try {
    await NotificationService.initialize();
  } catch (e) {
    // Handle silently
  }
  
  // Initialize FCM
  try {
    await FCMService.initialize();
  } catch (e) {
    // Handle silently
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
