import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state provider (stream of current user)
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Auth error state
final authErrorProvider = StateProvider<String?>((ref) => null);

/// Auth controller for handling auth operations
class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  final Ref _ref;

  AuthController(this._authService, this._ref)
    : super(const AsyncValue.loading());

  /// Sign in with email
  Future<bool> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final result = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(result.user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    }
  }

  /// Sign up with email
  Future<bool> signUpWithEmail(
    String email,
    String password,
    String username,
  ) async {
    state = const AsyncValue.loading();
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final result = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      state = AsyncValue.data(result.user);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        state = AsyncValue.data(result.user);
        return true;
      }
      state = const AsyncValue.data(null);
      return false;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _ref.read(authErrorProvider.notifier).state = null;

    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    }
  }
}

/// Auth controller provider
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
      final authService = ref.watch(authServiceProvider);
      return AuthController(authService, ref);
    });
