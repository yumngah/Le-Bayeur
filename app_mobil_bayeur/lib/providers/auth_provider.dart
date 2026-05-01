import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_mobil_bayeur/models/user_model.dart';
import 'package:app_mobil_bayeur/services/auth_service.dart';

enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  needsVerification,
  error
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.unauthenticated);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier() : super(AuthState.initial()) {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    final userJson = await _storage.read(key: 'user');
    
    if (token != null && userJson != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: User.fromJson(jsonDecode(userJson)),
      );
    }
  }

  Future<void> signup(Map<String, dynamic> data) async {
    state = AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _authService.signup(data);
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storage.write(key: 'jwt_token', value: authResponse.token);
      await _storage.write(key: 'refresh_token', value: authResponse.refreshToken);
      await _storage.write(key: 'user', value: jsonEncode(authResponse.user.toJson()));
      
      state = AuthState(
        status: AuthStatus.needsVerification,
        user: authResponse.user,
      );
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState(status: AuthStatus.authenticating);
    try {
      final response = await _authService.login(email, password);
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _storage.write(key: 'jwt_token', value: authResponse.token);
      await _storage.write(key: 'refresh_token', value: authResponse.refreshToken);
      await _storage.write(key: 'user', value: jsonEncode(authResponse.user.toJson()));
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: authResponse.user,
      );
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: 'Invalid credentials');
    }
  }

  Future<void> verifyEmail(String code) async {
    if (state.user == null) return;
    try {
      await _authService.verifyEmail(state.user!.id, code);
      // Move to next step or authenticated
    } catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: 'Verification failed');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
