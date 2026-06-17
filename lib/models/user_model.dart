class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String role;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  // Convert a Firestore Document/Map into a UserModel object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'Community Member', // Default role matching your target users
    );
  }

  // Convert a UserModel object into a Map to save into Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}