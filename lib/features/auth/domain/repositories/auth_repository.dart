import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> register(String name, String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> changePassword(String currentPassword, String newPassword);
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
}
