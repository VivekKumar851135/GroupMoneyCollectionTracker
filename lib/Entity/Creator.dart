class Creator {
  final int userId;
  final String username;
  final String email;
  final String createdAt;

  Creator({
    required this.userId,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      createdAt: json['createdAt'],
    );
  }
   Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
    };
  }
}
