import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Current user provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref.watch(authServiceProvider));
});

/// Auth state
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final User? user;
  final bool requiresOTP;
  final String? pendingEmail;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.user,
    this.requiresOTP = false,
    this.pendingEmail,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    User? user,
    bool? requiresOTP,
    String? pendingEmail,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      user: user ?? this.user,
      requiresOTP: requiresOTP ?? this.requiresOTP,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState());

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        successMessage: result['message'],
        requiresOTP: result['requiresOTP'] ?? false,
        pendingEmail: email,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  /// Verify OTP
  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    final result = await _authService.verifyOTPAndRegister(
      email: email,
      otp: otp,
    );

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        successMessage: result['message'],
        user: result['user'],
        requiresOTP: false,
        pendingEmail: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  /// Resend OTP
  Future<void> resendOTP(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    final result = await _authService.resendOTP(email);

    state = state.copyWith(
      isLoading: false,
      errorMessage: result['success'] ? null : result['message'],
      successMessage: result['success'] ? result['message'] : null,
    );
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result['success']) {
      state = state.copyWith(
        isLoading: false,
        successMessage: result['message'],
        user: result['user'],
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result['message'],
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = AuthState();
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);

    final result = await _authService.resetPassword(email);

    state = state.copyWith(
      isLoading: false,
      errorMessage: result['success'] ? null : result['message'],
      successMessage: result['success'] ? result['message'] : null,
    );
  }

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}
