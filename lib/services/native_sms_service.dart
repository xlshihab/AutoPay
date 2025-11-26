import 'package:flutter/services.dart';
import '../models/payment_model.dart';
import 'parser_service.dart';

class NativeSmsService {
  static const platform = MethodChannel('com.elbito.autopay/sms');

  // Check if app is default SMS app
  static Future<bool> isDefaultSmsApp() async {
    try {
      final bool result = await platform.invokeMethod('isDefaultSmsApp');
      return result;
    } catch (e) {
      return false;
    }
  }

  // Request to become default SMS app
  static Future<bool> requestDefaultSmsApp() async {
    try {
      final bool result = await platform.invokeMethod('requestDefaultSmsApp');
      return result;
    } catch (e) {
      return false;
    }
  }

  // Get all SMS messages from native code
  static Future<List<Map<String, dynamic>>> getAllSms() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getAllSms');
      return result.cast<Map<dynamic, dynamic>>().map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get recent SMS messages
  static Future<List<Map<String, dynamic>>> getRecentSms({int limit = 50}) async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getRecentSms', {'limit': limit});
      return result.cast<Map<dynamic, dynamic>>().map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Parse SMS to payment models
  static Future<List<PaymentModel>> getRecentPayments({int limit = 50}) async {
    try {
      final smsList = await getRecentSms(limit: limit);
      final List<PaymentModel> payments = [];

      for (var sms in smsList) {
        final address = sms['address'] as String? ?? '';
        final body = sms['body'] as String? ?? '';
        
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
}
