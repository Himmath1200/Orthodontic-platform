enum UserRole { doctor, patient, researcher, admin }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final String? specialization;
  final String? licenseNumber;
  final bool? isEmailVerified;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.specialization,
    this.licenseNumber,
    this.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: UserRole.values.byName(json['role'] ?? 'doctor'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      profileImageUrl: json['profileImageUrl'],
      specialization: json['specialization'],
      licenseNumber: json['licenseNumber'],
      isEmailVerified: json['isEmailVerified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'isEmailVerified': isEmailVerified,
    };
  }
}
