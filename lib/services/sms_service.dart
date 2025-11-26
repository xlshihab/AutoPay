import 'package:another_telephony/telephony.dart';
import 'package:flutter/services.dart';
import 'firebase_service.dart';
import 'parser_service.dart';
import 'foreground_sms_service.dart';
import '../models/payment_model.dart';
import '../sms_background_handler.dart';

class SmsService {
  static final Telephony telephony = Telephony.instance;
  static const MethodChannel _smsBackgroundChannel = MethodChannel('com.elbito.autopay/sms_background');

  // Initialize SMS listener
  static Future<bool> initialize() async {
    try {
      // Request permissions
      final bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
      
      if (permissionsGranted != true) {
        return false;
      }

      // Setup background channel handler
      _smsBackgroundChannel.setMethodCallHandler(_handleBackgroundSms);

      // Start foreground service for persistent SMS listening
      await ForegroundSmsService.startService();

      // Also start telephony listener (as fallback)
      telephony.listenIncomingSms(
        onNewMessage: _onSmsReceived,
        onBackgroundMessage: onBackgroundMessage,
        listenInBackground: true,
      );

      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Handle SMS from background service
  static Future<void> _handleBackgroundSms(MethodCall call) async {
    if (call.method == 'onSmsReceived') {
      try {
        final Map<dynamic, dynamic> data = call.arguments;
        final String address = data['address'] ?? '';
        final String body = data['body'] ?? '';
        
        // Parse SMS
        final payment = ParserService.parseSms(address, body);
        
        if (payment != null) {
          // Initialize Firebase if needed
          if (!FirebaseService.isInitialized()) {
            await FirebaseService.initialize();
          }
          
          // Save to Firebase
          await FirebaseService.savePayment(payment);
        }
      } catch (e) {
        // Silent fail
      }
    }
  }

  // Handle SMS received when app is in foreground
  static void _onSmsReceived(SmsMessage message) async {
    await _processSms(message);
  }

  // Process SMS and save to Firebase if it's a payment
  static Future<void> _processSms(SmsMessage message) async {
    try {
      final address = message.address ?? '';
      final body = message.body ?? '';

      // Parse SMS
      final payment = ParserService.parseSms(address, body);

      if (payment != null) {
        // Check Firebase initialization
        if (!FirebaseService.isInitialized()) {
          await FirebaseService.initialize();
        }
        
        // Save to Firebase
        await FirebaseService.savePayment(payment);
      }
    } catch (e) {
      // Silent fail
    }
  }

  // Get all SMS messages
  static Future<List<SmsMessage>> getAllSms() async {
    try {
      final messages = await telephony.getInboxSms(
        columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
        sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
      );
      return messages;
    } catch (e) {
      return [];
    }
  }

  // Get recent SMS from bKash/Nagad
  static Future<List<PaymentModel>> getRecentPaymentSms({int limit = 10}) async {
    try {
      final messages = await getAllSms();
      final List<PaymentModel> payments = [];

      for (var message in messages) {
        if (payments.length >= limit) break;

        final address = message.address ?? '';
        final body = message.body ?? '';
        
        final payment = ParserService.parseSms(address, body);
        if (payment != null) {
          payments.add(payment);
        }
      }

      return payments;
    } catch (e) {
      return [];
    }
  }

  // Test SMS parsing with manual input
  static PaymentModel? testParseSms(String sender, String message) {
    return ParserService.parseSms(sender, message);
  }
}
