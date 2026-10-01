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
    final repository = ref.read(authRepositoryProvider);

    final token = await repository.getAccessToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await repository.getMe();
    } catch (_) {
      await repository.logout();
      return null;
    }
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

  Future<AuthUser?> loginWithGoogle({
    required String idToken,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref
          .read(authRepositoryProvider)
          .loginWithGoogle(
            idToken: idToken,
          );

      state = AsyncData(user);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<AuthUser> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .updateProfile(
            name: name,
            phone: phone,
          );

      state = AsyncData(user);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}