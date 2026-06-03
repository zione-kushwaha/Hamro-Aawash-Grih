import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailRequested({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class SignInWithGoogleRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const RegisterRequested({required this.name, required this.email, required this.password});
  @override
  List<Object> get props => [name, email, password];
}

class SignOutRequested extends AuthEvent {}

class SendPasswordResetRequested extends AuthEvent {
  final String email;
  const SendPasswordResetRequested(this.email);
  @override
  List<Object> get props => [email];
}

class SendEmailVerificationRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}
