import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final double balance;
  final double totalDeposited;
  final double totalEarned;
  final double totalSpent;
  final double totalWithdrawn;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.balance,
    required this.totalDeposited,
    required this.totalEarned,
    required this.totalSpent,
    required this.totalWithdrawn,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      balance: (data['balance'] ?? 0).toDouble(),
      totalDeposited: (data['totalDeposited'] ?? 0).toDouble(),
      totalEarned: (data['totalEarned'] ?? 0).toDouble(),
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      totalWithdrawn: (data['totalWithdrawn'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'balance': balance,
      'totalDeposited': totalDeposited,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'totalWithdrawn': totalWithdrawn,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
