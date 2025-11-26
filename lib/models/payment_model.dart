import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String? id;
  final double amount;
  final String senderNumber;
  final String method; // 'bkash' or 'nagad'
  final String transactionId;
  final DateTime timestamp;
  final String rawMessage;
  final String? deviceId;

  PaymentModel({
    this.id,
    required this.amount,
    required this.senderNumber,
    required this.method,
    required this.transactionId,
    required this.timestamp,
    required this.rawMessage,
    this.deviceId,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'senderNumber': senderNumber,
      'method': method,
      'transactionId': transactionId,
      'timestamp': Timestamp.fromDate(timestamp),
      'rawMessage': rawMessage,
      'deviceId': deviceId,
    };
  }

  // Create from Firestore Document
  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      senderNumber: data['senderNumber'] ?? '',
      method: data['method'] ?? '',
      transactionId: data['transactionId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      rawMessage: data['rawMessage'] ?? '',
      deviceId: data['deviceId'],
    );
  }

  // Create from Map
  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'],
      amount: (map['amount'] ?? 0.0).toDouble(),
      senderNumber: map['senderNumber'] ?? '',
      method: map['method'] ?? '',
      transactionId: map['transactionId'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.parse(map['timestamp']),
      rawMessage: map['rawMessage'] ?? '',
      deviceId: map['deviceId'],
    );
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $amount, method: $method, transactionId: $transactionId)';
  }
}
