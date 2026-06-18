class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String location;
  final String bio;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.location = '',
    this.bio = '',
  });

  bool get isAdmin => role == 'Admin';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'Community Member',
      location: map['location'] ?? '',
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'location': location,
      'bio': bio,
    };
  }
}
