class AppConstants {
  // Firestore Collection
  static const String paymentsCollection = 'payments';

  // SMS Sender IDs
  static const List<String> bkashSenders = [
    'bKash',
    '16247',
    '01521798452'
  ];

  static const List<String> nagadSenders = [
    'NAGAD',
    '16167',
    'Nagad',
    '01521456789'
  ];

  // SMS Keywords for received money
  static const List<String> receiveKeywords = [
    'received',
    'পেয়েছেন',
    'টাকা জমা',
    'Cash In',
    'Money Received',
  ];

  // Regex Patterns
  static final RegExp bkashAmountPattern = RegExp(
    r'Tk\s?(\d+(?:,\d+)*(?:\.\d+)?)|BDT\s?(\d+(?:,\d+)*(?:\.\d+)?)|Amount:\s?Tk\s?(\d+(?:,\d+)*(?:\.\d+)?)',
    caseSensitive: false,
  );

  static final RegExp nagadAmountPattern = RegExp(
    r'Tk\.?\s?(\d+(?:,\d+)*(?:\.\d+)?)|টাকা\s?(\d+(?:,\d+)*(?:\.\d+)?)|Amount:\s?Tk\s?(\d+(?:,\d+)*(?:\.\d+)?)',
    caseSensitive: false,
  );

  static final RegExp bkashTransactionIdPattern = RegExp(
    r'TrxID\s?[:]?\s?([A-Z0-9]+)|TxnID\s?[:]?\s?([A-Z0-9]+)',
    caseSensitive: false,
  );

  static final RegExp nagadTransactionIdPattern = RegExp(
    r'Transaction\s?ID\s?[:]?\s?([A-Z0-9]+)|TxnID\s?[:]?\s?([A-Z0-9]+)',
    caseSensitive: false,
  );

  static final RegExp phoneNumberPattern = RegExp(
    r'01[3-9]\d{8}',
  );

  // Background Service
  static const String serviceNotificationChannelId = 'autopay_service';
  static const String serviceNotificationChannelName = 'AutoPay Service';
  static const String serviceNotificationTitle = 'AutoPay চলছে';
  static const String serviceNotificationBody = 'SMS মনিটরিং সক্রিয়';
}
