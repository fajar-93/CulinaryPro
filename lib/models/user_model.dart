import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String address;
  final String bio;
  final String? profileImage;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.bio,
    this.profileImage,
    this.updatedAt,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      bio: data['bio'] ?? '',
      profileImage: data['profileImage'],
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'bio': bio,
      if (profileImage != null) 'profileImage': profileImage,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? username,
    String? email,
    String? phone,
    String? address,
    String? bio,
    String? profileImage,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
