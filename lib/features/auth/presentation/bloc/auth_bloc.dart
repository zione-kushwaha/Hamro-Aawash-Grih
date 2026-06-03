import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final Register register;
  final SignOut signOut;
  final SendPasswordResetEmail sendPasswordResetEmail;
  final SendEmailVerification sendEmailVerification;
  final Stream<dynamic> authStateChanges;

  AuthBloc({
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.register,
    required this.signOut,
    required this.sendPasswordResetEmail,
    required this.sendEmailVerification,
    required this.authStateChanges,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<RegisterRequested>(_onRegister);
    on<SignOutRequested>(_onSignOut);
    on<SendPasswordResetRequested>(_onSendPasswordReset);
    on<SendEmailVerificationRequested>(_onSendEmailVerification);
    add(AuthCheckRequested());
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    await emit.forEach(
      authStateChanges,
      onData: (user) => user != null ? Authenticated(user) : Unauthenticated(),
    );
  }

  Future<void> _onSignInWithEmail(SignInWithEmailRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInWithEmail(SignInParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogleRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signInWithGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegister(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await register(RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(RegisterSuccess(user)),
    );
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await signOut(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onSendPasswordReset(SendPasswordResetRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(PasswordResetEmailSent()),
    );
  }

  Future<void> _onSendEmailVerification(
      SendEmailVerificationRequested event, Emitter<AuthState> emit) async {
    final result = await sendEmailVerification(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(EmailVerificationSent()),
    );
  }
}
