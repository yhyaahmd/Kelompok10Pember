import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      return true;
    } catch (e) {
      print('Google sign in error: $e');
      return false;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile data
  Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  // Get user email
  String? get userEmail => currentUser?.email;

  // Get user full name
  String? get userFullName => userMetadata?['full_name'];

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Get error message in Indonesian
  String getErrorMessage(dynamic error) {
    String errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('invalid login credentials') ||
        errorMessage.contains('invalid_credentials')) {
      return 'Email atau password salah';
    } else if (errorMessage.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan cek email Anda';
    } else if (errorMessage.contains('user already registered')) {
      return 'Email sudah terdaftar';
    } else if (errorMessage.contains('password should be at least')) {
      return 'Password minimal 6 karakter';
    } else if (errorMessage.contains('invalid email')) {
      return 'Format email tidak valid';
    } else if (errorMessage.contains('network')) {
      return 'Tidak ada koneksi internet';
    } else if (errorMessage.contains('too many requests')) {
      return 'Terlalu banyak percobaan. Coba lagi nanti';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi';
    }
  }
}
