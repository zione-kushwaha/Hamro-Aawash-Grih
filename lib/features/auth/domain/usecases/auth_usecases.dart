import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail extends UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;
  SignInWithEmail(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) =>
      repository.signInWithEmail(params.email, params.password);
}

class SignInParams extends Equatable {
  final String email;
  final String password;
  const SignInParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogle extends UseCase<UserEntity, NoParams> {
  final AuthRepository repository;
  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) => repository.signInWithGoogle();
}

class Register extends UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  Register(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) =>
      repository.register(params.name, params.email, params.password);
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String password;
  const RegisterParams({required this.name, required this.email, required this.password});

  @override
  List<Object> get props => [name, email, password];
}

class SignOut extends UseCase<void, NoParams> {
  final AuthRepository repository;
  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.signOut();
}

class SendPasswordResetEmail extends UseCase<void, String> {
  final AuthRepository repository;
  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) => repository.sendPasswordResetEmail(email);
}

class SendEmailVerification extends UseCase<void, NoParams> {
  final AuthRepository repository;
  SendEmailVerification(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.sendEmailVerification();
}
