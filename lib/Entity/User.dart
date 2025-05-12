class User {
  final int userId;
  final String? username;
  final String? email;
  final String? password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? authProvider;
  final DateTime? dateOfBirth;
  final String? gender;
  final DateTime createdAt;
  final String? profileUrl;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.authProvider,
    required this.dateOfBirth,
    required this.gender,
    required this.createdAt,
    required this.profileUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      firstName: json['firstName'],
      lastName: json['lastName'] ?? '',  // Nullable field
      phone: json['phone'] ?? '',  // Nullable field
      authProvider: json['authProvider'] ?? '',  // Nullable field
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])  // Parse DateTime if exists
          : null,
      gender: json['gender'] ?? '',  // Nullable field
      createdAt: DateTime.parse(json['createdAt']),
      profileUrl: json['profileUrl'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'authProvider': authProvider,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'createdAt': createdAt.toIso8601String(),
      'profileUrl': profileUrl,
    };
  }
}