import '../models/payment_model.dart';
import '../utils/constants.dart';

class ParserService {
  // Parse SMS and extract payment information
  static PaymentModel? parseSms(String address, String body) {
    // Check if it's from bKash or Nagad
    final method = _identifyMethod(address, body);
    if (method == null) return null;

    // Check if it's a receive SMS
    if (!_isReceiveSms(body)) return null;

    // Extract data based on method
    if (method == 'bkash') {
      return _parseBkashSms(address, body);
    } else {
      return _parseNagadSms(address, body);
    }
  }

  // Identify if SMS is from bKash or Nagad
  static String? _identifyMethod(String address, String body) {
    // Check sender address
    for (final sender in AppConstants.bkashSenders) {
      if (address.contains(sender) || body.toLowerCase().contains('bkash')) {
        return 'bkash';
      }
    }

    for (final sender in AppConstants.nagadSenders) {
      if (address.contains(sender) || body.toLowerCase().contains('nagad')) {
        return 'nagad';
      }
    }

    return null;
  }

  // Check if SMS is about receiving money
  static bool _isReceiveSms(String body) {
    for (final keyword in AppConstants.receiveKeywords) {
      if (body.toLowerCase().contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  // Parse bKash SMS
  static PaymentModel? _parseBkashSms(String address, String body) {
    try {
      // Extract amount
      final amountMatch = AppConstants.bkashAmountPattern.firstMatch(body);
      if (amountMatch == null) return null;
      
      final amountString = (amountMatch.group(1) ?? amountMatch.group(2) ?? amountMatch.group(3) ?? '0')
          .replaceAll(',', '')
          .replaceAll(' ', '');
      final amount = double.tryParse(amountString);
      if (amount == null || amount <= 0) return null;

      // Extract transaction ID
      final trxMatch = AppConstants.bkashTransactionIdPattern.firstMatch(body);
      if (trxMatch == null) return null;
      final transactionId = (trxMatch.group(1) ?? trxMatch.group(2))!;

      // Extract sender phone number
      final phoneMatch = AppConstants.phoneNumberPattern.firstMatch(body);
      final senderNumber = phoneMatch?.group(0) ?? 'Unknown';

      return PaymentModel(
        amount: amount,
        senderNumber: senderNumber,
        method: 'bkash',
        transactionId: transactionId,
        timestamp: DateTime.now(),
        rawMessage: body,
      );
    } catch (e) {
      return null;
    }
  }

  // Parse Nagad SMS
  static PaymentModel? _parseNagadSms(String address, String body) {
    try {
      // Extract amount
      final amountMatch = AppConstants.nagadAmountPattern.firstMatch(body);
      if (amountMatch == null) return null;
      
      final amountString = (amountMatch.group(1) ?? amountMatch.group(2) ?? amountMatch.group(3) ?? '0')
          .replaceAll(',', '')
          .replaceAll(' ', '');
      final amount = double.tryParse(amountString);
      if (amount == null || amount <= 0) return null;

      // Extract transaction ID
      final trxMatch = AppConstants.nagadTransactionIdPattern.firstMatch(body);
      if (trxMatch == null) return null;
      final transactionId = (trxMatch.group(1) ?? trxMatch.group(2))!;

      // Extract sender phone number
      final phoneMatch = AppConstants.phoneNumberPattern.firstMatch(body);
      final senderNumber = phoneMatch?.group(0) ?? 'Unknown';

      return PaymentModel(
        amount: amount,
        senderNumber: senderNumber,
        method: 'nagad',
        transactionId: transactionId,
        timestamp: DateTime.now(),
        rawMessage: body,
      );
    } catch (e) {
      return null;
    }
  }

}
