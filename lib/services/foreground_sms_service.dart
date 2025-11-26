import 'package:flutter/services.dart';

class ForegroundSmsService {
  static const MethodChannel _channel = MethodChannel('com.elbito.autopay/foreground_service');

  // Start foreground service
  static Future<bool> startService() async {
    try {
      final result = await _channel.invokeMethod('startForegroundService');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  // Stop foreground service
  static Future<bool> stopService() async {
    try {
      final result = await _channel.invokeMethod('stopForegroundService');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  // Check if service is running
  static Future<bool> isServiceRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      return result == true;
    } catch (e) {
      return false;
    }
  }
}
