import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> register(String name, String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> deleteAccount();
  Future<void> changePassword(String currentPassword, String newPassword);
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _fetchOrCreateUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authClient = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final credential = GoogleAuthProvider.credential(
        accessToken: authClient?.accessToken,
        idToken: idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return await _fetchOrCreateUser(userCredential.user!, name: googleUser.displayName);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      await credential.user!.sendEmailVerification();
      return await _fetchOrCreateUser(credential.user!, name: name);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.disconnect()]);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No user logged in');
    await user.sendEmailVerification();
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No user logged in');
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).delete();
    await user.delete();
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No user logged in');
    final credential = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  @override
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        return await _fetchOrCreateUser(user);
      });

  @override
  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      photoUrl: user.photoURL,
      role: UserRole.user,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
    );
  }

  Future<UserModel> _fetchOrCreateUser(User user, {String? name}) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(user.uid).get();
    if (doc.exists) {
      final model = UserModel.fromFirestore(doc);
      if (model.emailVerified != user.emailVerified) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({'email_verified': user.emailVerified});
        return UserModel(
          id: model.id, email: model.email, name: model.name,
          phone: model.phone, photoUrl: model.photoUrl, role: model.role,
          emailVerified: user.emailVerified, createdAt: model.createdAt, updatedAt: DateTime.now(),
        );
      }
      return model;
    }
    final newUser = UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: name ?? user.displayName ?? '',
      photoUrl: user.photoURL,
      role: UserRole.user,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(newUser.toFirestore());
    return newUser;
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'An account already exists with this email';
      case 'invalid-email': return 'Invalid email address';
      case 'weak-password': return 'Password is too weak';
      case 'user-disabled': return 'This account has been disabled';
      case 'too-many-requests': return 'Too many attempts. Try again later';
      case 'network-request-failed': return 'Network error. Check your connection';
      default: return 'Authentication failed. Please try again';
    }
  }
}
