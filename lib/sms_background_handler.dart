import 'package:another_telephony/telephony.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_service.dart';
import 'services/parser_service.dart';
import 'firebase_options.dart';

// This is the background message handler
// It must be a top-level function and cannot be anonymous
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(SmsMessage message) async {
  try {
    // Initialize Firebase if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final address = message.address ?? '';
    final body = message.body ?? '';

    // Parse SMS
    final payment = ParserService.parseSms(address, body);

    if (payment != null) {
      // Save to Firebase
      await FirebaseService.savePayment(payment);
    }
  } catch (e) {
    // Silent fail
  }
}
