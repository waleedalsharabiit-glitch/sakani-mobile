import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import 'auth_providers.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthUser?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    final token = await ref
        .read(authRepositoryProvider)
        .getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    // في هذه المرحلة وجود التوكن يعني أن الجلسة محفوظة.
    // سيتم لاحقًا إضافة /me للتحقق من صلاحية التوكن وإرجاع المستخدم.
    return null;
  }

  Future<AuthUser?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .login(
            email: email,
            password: password,
          );

      state = AsyncData(user);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}