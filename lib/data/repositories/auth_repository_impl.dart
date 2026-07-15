import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/constants/app_roles.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl(this._authService, this._firestoreService);

  @override
  Stream<AppUser?> authStateChanges() {
    return _authService.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final profile = await getUserProfile(firebaseUser.uid);
        return profile ??
            AppUserModel.fromFirebase(
                uid: firebaseUser.uid, email: firebaseUser.email);
      } on FirebaseException {
        return AppUserModel.fromFirebase(
            uid: firebaseUser.uid, email: firebaseUser.email);
      }
    });
  }

  @override
  Stream<AppUser?> currentUserStream() {
    return _authService.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await getUserProfile(firebaseUser.uid) ??
            AppUserModel.fromFirebase(
                uid: firebaseUser.uid, email: firebaseUser.email);
      } on FirebaseException {
        return AppUserModel.fromFirebase(
            uid: firebaseUser.uid, email: firebaseUser.email);
      }
    });
  }

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _authService.signIn(email: email, password: password);
      final user = credential.user;
      if (user == null) return null;

      try {
        final profile = await getUserProfile(user.uid);
        return profile ??
            AppUserModel.fromFirebase(uid: user.uid, email: user.email);
      } on FirebaseException {
        return AppUserModel.fromFirebase(uid: user.uid, email: user.email);
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user == null) return null;

      try {
        final profile = await getUserProfile(user.uid);
        if (profile != null) return profile;
      } on FirebaseException {
        // Continue and create the basic profile from the Google account.
      }

      final newUser = AppUserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        role: AppRoles.microempresario,
        photoUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestoreService.setUserProfile(
        uid: user.uid,
        data: newUser.toMap(),
      );

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  @override
  Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential =
          await _authService.register(email: email, password: password);
      final user = credential.user;
      if (user == null) return null;

      final newUser = AppUserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: AppRoles.microempresario,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setUserProfile(
        uid: user.uid,
        data: newUser.toMap(),
      );

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e));
    }
  }

  @override
  Future<AppUser?> getUserProfile(String uid) async {
    final data = await _firestoreService.getUserProfile(uid);
    if (data == null) return null;
    return AppUserModel.fromMap(data);
  }

  @override
  Future<AppUser> updateProfile({
    required AppUser user,
    required String name,
    required String email,
    required String photoUrl,
  }) async {
    final updated = AppUserModel(
      uid: user.uid,
      name: name,
      email: email,
      role: user.role,
      photoUrl: photoUrl,
      createdAt: user.createdAt,
    );

    await _firestoreService.setUserProfile(
      uid: user.uid,
      data: updated.toMap(),
    );

    return updated;
  }

  @override
  Future<void> signOut() => _authService.signOut();

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Intenta nuevamente.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'google-sign-in-cancelled':
        return 'Inicio de sesión con Google cancelado.';
      default:
        return 'Ocurrió un error de autenticación. Intenta nuevamente.';
    }
  }
}
