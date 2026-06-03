import 'package:equatable/equatable.dart';

enum UserRole { guest, user, staff, admin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoUrl;
  final UserRole role;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoUrl,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, email, name, phone, photoUrl, role, emailVerified];

  bool get isAdmin => role == UserRole.admin;
  bool get isStaff => role == UserRole.staff || role == UserRole.admin;
}
