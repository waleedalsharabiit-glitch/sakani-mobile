import '../../../core/network/api_client.dart';
import '../models/auth_user.dart';

class AuthApi {
  AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.dio.post(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      '/mobile/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await _apiClient.dio.post(
      '/mobile/auth/google',
      data: {
        'idToken': idToken,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<AuthUser> getMe() async {
    final response = await _apiClient.dio.get(
      '/mobile/auth/me',
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل جلب بيانات المستخدم',
      );
    }

    return AuthUser.fromJson(
      Map<String, dynamic>.from(
        data['user'] as Map,
      ),
    );
  }

  Future<AuthUser> updateProfile({
    String? name,
    String? phone,
  }) async {
    final response = await _apiClient.dio.put(
      '/mobile/profile',
      data: {
        'name': name,
        'phone': phone,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل تحديث الملف الشخصي',
      );
    }

    return AuthUser.fromJson(
      Map<String, dynamic>.from(
        data['user'] as Map,
      ),
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.dio.put(
      '/mobile/profile/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    final data = Map<String, dynamic>.from(
      response.data as Map,
    );

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'فشل تغيير كلمة المرور',
      );
    }
  }
}
