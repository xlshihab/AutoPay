import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/payment_model.dart';
import '../utils/constants.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      rethrow;
    }
  }

  // Check if Firebase is initialized
  static bool isInitialized() {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Save payment to Firestore
  static Future<bool> savePayment(PaymentModel payment) async {
    try {
      // Check if transaction already exists
      final existingDoc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('transactionId', isEqualTo: payment.transactionId)
          .limit(1)
          .get();

      if (existingDoc.docs.isNotEmpty) {
        return false;
      }

      // Add new payment
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .add(payment.toMap());

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get recent payments
  static Future<List<PaymentModel>> getRecentPayments({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get today's total amount
  static Future<double> getTodayTotal() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final payment = PaymentModel.fromFirestore(doc);
        total += payment.amount;
      }

      return total;
    } catch (e) {
      return 0;
    }
  }

  // Get payments by method
  static Future<List<PaymentModel>> getPaymentsByMethod(String method, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('method', isEqualTo: method)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Delete payment
  static Future<bool> deletePayment(String paymentId) async {
    try {
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Stream of payments (real-time updates)
  static Stream<List<PaymentModel>> paymentsStream({int limit = 10}) {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }

  // Stream recent payments with limit
  static Stream<List<PaymentModel>> streamRecentPayments({int limit = 10}) {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentModel.fromFirestore(doc))
            .toList());
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .limit(1)
          .get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
