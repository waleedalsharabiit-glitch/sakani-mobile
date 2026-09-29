import 'package:dio/dio.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../models/auth_user.dart';
import 'auth_api.dart';

class AuthRepository {
  AuthRepository(
    this._authApi,
    this._storage,
  );

  final AuthApi _authApi;
  final SecureStorageService _storage;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authApi.login(
        email: email,
        password: password,
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'فشل تسجيل الدخول',
        );
      }

      final accessToken = response['accessToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('لم يتم استلام رمز الدخول');
      }

      await _storage.saveAccessToken(accessToken);

      final userJson = Map<String, dynamic>.from(
        response['user'] as Map,
      );

      return AuthUser.fromJson(userJson);
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _authApi.register(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'فشل إنشاء الحساب',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        throw Exception(data['message'].toString());
      }

      throw Exception('تعذر الاتصال بالخادم');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAccessToken();
  }

  Future<String?> getAccessToken() {
    return _storage.getAccessToken();
  }
}