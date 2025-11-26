import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Check if all required permissions are granted
  static Future<bool> checkAllPermissions() async {
    final sms = await Permission.sms.status;
    final phone = await Permission.phone.status;
    final notification = await Permission.notification.status;
    final ignoreBatteryOptimizations = await Permission.ignoreBatteryOptimizations.status;

    return sms.isGranted && phone.isGranted && notification.isGranted && ignoreBatteryOptimizations.isGranted;
  }

  // Request all required permissions
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.sms,
      Permission.phone,
      Permission.notification,
      Permission.ignoreBatteryOptimizations,
    ].request();
  }

  // Request SMS permissions only
  static Future<bool> requestSmsPermissions() async {
    final statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    return statuses[Permission.sms]!.isGranted && 
           statuses[Permission.phone]!.isGranted;
  }

  // Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Check individual permissions
  static Future<bool> isSmsPermissionGranted() async {
    return await Permission.sms.isGranted;
  }

  static Future<bool> isPhonePermissionGranted() async {
    return await Permission.phone.isGranted;
  }

  static Future<bool> isNotificationPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  // Open app settings if permission permanently denied
  static Future<bool> openAppSettings() async {
    return await Permission.sms.request().isGranted ? true : await openAppSettings();
  }

  // Get permission status details
  static Future<Map<String, String>> getPermissionStatuses() async {
    final smsStatus = await Permission.sms.status;
    final phoneStatus = await Permission.phone.status;
    final notificationStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    return {
      'SMS (পড়া/গ্রহণ)': _getStatusString(smsStatus),
      'Phone (ডিভাইস ID)': _getStatusString(phoneStatus),
      'Notification (বিজ্ঞপ্তি)': _getStatusString(notificationStatus),
      'Background (ব্যাকগ্রাউন্ড চালু)': _getStatusString(batteryStatus),
    };
  }

  static String _getStatusString(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'অনুমোদিত';
      case PermissionStatus.denied:
        return 'অস্বীকৃত';
      case PermissionStatus.permanentlyDenied:
        return 'স্থায়ীভাবে অস্বীকৃত';
      case PermissionStatus.restricted:
        return 'সীমিত';
      case PermissionStatus.limited:
        return 'সীমিত';
      default:
        return 'অজানা';
    }
  }
}
