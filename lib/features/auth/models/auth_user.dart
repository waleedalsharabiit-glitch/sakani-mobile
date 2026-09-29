class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.image,
    required this.role,
  });

  final String id;
  final String email;
  final String? name;
  final String? image;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      image: json['image'] as String?,
      role: json['role'] as String? ?? 'USER',
    );
  }
}