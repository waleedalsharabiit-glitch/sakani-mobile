class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.phone,
    required this.role,
  });

  final String id;
  final String? name;
  final String email;
  final String? image;
  final String? phone;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'USER',
    );
  }
}