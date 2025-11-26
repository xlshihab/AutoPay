import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch deposits and entry fees
  static Future<List<TransactionModel>> fetchPayments({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('type', whereIn: ['deposit', 'entry_fee'])
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch withdrawals
  static Future<List<TransactionModel>> fetchWithdrawals({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('type', isEqualTo: 'withdraw')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Approve deposit/entry_fee - Update transaction and user balance
  static Future<bool> approveDeposit(TransactionModel transaction) async {
    try {
      // Use Firestore transaction for atomic operation
      await _firestore.runTransaction((txn) async {
        // Update transaction status
        final transactionRef = _firestore.collection('transactions').doc(transaction.id);
        txn.update(transactionRef, {
          'status': 'success',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update user balance
        final userRef = _firestore.collection('users').doc(transaction.userId);
        final userDoc = await txn.get(userRef);

        if (userDoc.exists) {
          final currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();
          final currentDeposited = (userDoc.data()?['totalDeposited'] ?? 0).toDouble();

          txn.update(userRef, {
            'balance': currentBalance + transaction.amount,
            'totalDeposited': currentDeposited + transaction.amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Reject deposit/entry_fee
  static Future<bool> rejectTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Approve withdrawal - Deduct from balance, add to totalWithdrawn
  static Future<bool> approveWithdrawal(TransactionModel transaction) async {
    try {
      await _firestore.runTransaction((txn) async {
        // Update transaction status
        final transactionRef = _firestore.collection('transactions').doc(transaction.id);
        txn.update(transactionRef, {
          'status': 'success',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update user balance
        final userRef = _firestore.collection('users').doc(transaction.userId);
        final userDoc = await txn.get(userRef);

        if (userDoc.exists) {
          final currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();
          final currentWithdrawn = (userDoc.data()?['totalWithdrawn'] ?? 0).toDouble();

          txn.update(userRef, {
            'balance': currentBalance - transaction.amount,
            'totalWithdrawn': currentWithdrawn + transaction.amount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
