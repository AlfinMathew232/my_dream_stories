import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final bool isPro;
  final DateTime? subscriptionExpiry;
  final DateTime? subscriptionStartDate;
  final DateTime? createdAt;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.isPro,
    this.subscriptionExpiry,
    this.subscriptionStartDate,
    this.createdAt,
    this.profileImageUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      isPro: data['isPro'] ?? false,
      subscriptionExpiry: data['subscriptionExpiry'] != null
          ? (data['subscriptionExpiry'] as Timestamp).toDate()
          : null,
      subscriptionStartDate: data['subscriptionStartDate'] != null
          ? (data['subscriptionStartDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'isPro': isPro,
      'subscriptionExpiry': subscriptionExpiry,
      'subscriptionStartDate': subscriptionStartDate,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
    };
  }
}
