import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.photoUrl,
    required super.role,
    required super.emailVerified,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      photoUrl: data['photo_url'],
      role: UserRole.values.firstWhere(
        (r) => r.name == (data['role'] ?? 'user'),
        orElse: () => UserRole.user,
      ),
      emailVerified: data['email_verified'] ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id: entity.id,
        email: entity.email,
        name: entity.name,
        phone: entity.phone,
        photoUrl: entity.photoUrl,
        role: entity.role,
        emailVerified: entity.emailVerified,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'name': name,
        'phone': phone,
        'photo_url': photoUrl,
        'role': role.name,
        'email_verified': emailVerified,
        'created_at': Timestamp.fromDate(createdAt),
        'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };
}
