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

    return await _handleLoginResponse(response);
  } on DioException catch (error) {
    throw Exception(_getDioErrorMessage(error));
  }
}

 Future<AuthUser> loginWithGoogle({
  required String idToken,
}) async {
  try {
    final response = await _authApi.loginWithGoogle(
      idToken: idToken,
    );

    return await _handleLoginResponse(response);
  } on DioException catch (error) {
    throw Exception(_getDioErrorMessage(error));
  }
}

  Future<AuthUser> _handleLoginResponse(
    Map<String, dynamic> response,
  ) async {
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

    final userData = response['user'];

    if (userData is! Map) {
      throw Exception('بيانات المستخدم غير صحيحة');
    }

    final userJson = Map<String, dynamic>.from(userData);

    return AuthUser.fromJson(userJson);
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
      throw Exception(_getDioErrorMessage(error));
    }
  }

  Future<AuthUser> getMe() async {
    try {
      return await _authApi.getMe();
    } on DioException catch (error) {
      throw Exception(_getDioErrorMessage(error));
    }
  }

  Future<AuthUser> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      return await _authApi.updateProfile(
        name: name,
        phone: phone,
      );
    } on DioException catch (error) {
      throw Exception(_getDioErrorMessage(error));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authApi.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on DioException catch (error) {
      throw Exception(_getDioErrorMessage(error));
    }
  }

  Future<void> logout() async {
    await _storage.deleteAccessToken();
  }

  Future<String?> getAccessToken() {
    return _storage.getAccessToken();
  }

  String _getDioErrorMessage(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (data is Map && data['message'] != null) {
      return 'الخادم: ${data['message']}';
    }

    if (response != null) {
      return 'خطأ HTTP ${response.statusCode}: '
          '${response.statusMessage ?? 'بدون رسالة'}';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال بالخادم';

      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة إرسال الطلب';

      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة استقبال الرد من الخادم';

      case DioExceptionType.connectionError:
        return 'فشل الاتصال بالخادم: '
            '${error.message ?? 'Connection Error'}';

      case DioExceptionType.badCertificate:
        return 'مشكلة في شهادة HTTPS: '
            '${error.message ?? 'Bad Certificate'}';

      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';

      case DioExceptionType.badResponse:
        return 'استجابة غير صحيحة من الخادم';

      case DioExceptionType.transformTimeout:
        return 'انتهت مهلة معالجة البيانات';

      case DioExceptionType.unknown:
        return 'خطأ غير معروف: '
            '${error.message ?? error.toString()}';
    }
  }
}