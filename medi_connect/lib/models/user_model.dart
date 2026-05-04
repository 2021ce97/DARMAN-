import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'patient' | 'doctor' | 'admin'
  final String? phone;
  final String? photoUrl;
  final String? bloodType;
  final double? weight;
  final double? height;
  final String? allergies;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    this.bloodType,
    this.weight,
    this.height,
    this.allergies,
    this.dateOfBirth,
    this.gender,
    required this.createdAt,
  });

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'patient',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      bloodType: data['bloodType'],
      weight: (data['weight'] as num?)?.toDouble(),
      height: (data['height'] as num?)?.toDouble(),
      allergies: data['allergies'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bloodType != null) 'bloodType': bloodType,
      if (weight != null) 'weight': weight,
      if (height != null) 'height': height,
      if (allergies != null) 'allergies': allergies,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (gender != null) 'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? bloodType,
    double? weight,
    double? height,
    String? allergies,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      bloodType: bloodType ?? this.bloodType,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      allergies: allergies ?? this.allergies,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      createdAt: createdAt,
    );
  }
}
