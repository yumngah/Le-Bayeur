import 'package:dio/dio.dart';
import 'package:app_mobil_bayeur/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Response> signup(Map<String, dynamic> data) async {
    return _apiService.dio.post('/auth/signup', data: data);
  }

  Future<Response> login(String email, String password) async {
    return _apiService.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> verifyEmail(String userId, String code) async {
    return _apiService.dio.post('/auth/verify-email', data: {
      'user_id': userId,
      'code': code,
    });
  }

  Future<Response> verifyPhone(String userId, String code) async {
    return _apiService.dio.post('/auth/verify-phone', data: {
      'user_id': userId,
      'code': code,
    });
  }

  Future<Response> refreshToken(String refreshToken) async {
    return _apiService.dio.post('/auth/refresh-token', data: {
      'refreshToken': refreshToken,
    });
  }
}
