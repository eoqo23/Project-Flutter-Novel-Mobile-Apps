class User {
  final String token;
  final String role;
  final String name;
  final String email;
  final String id;

  User({
    required this.token,
    required this.role,
    required this.name,
    required this.email,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      id: json['id']?.toString() ?? '',
    );
  }
}