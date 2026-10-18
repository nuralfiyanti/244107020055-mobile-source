import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/api_client.dart';
import '../../../../data/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// Provider untuk interface AuthRepository.
/// Implementasi konkret (AuthRepositoryImpl) disuntikkan di sini.
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(),
);

/// Dio dengan token + refresh otomatis. UI tidak boleh memakai Dio langsung.
final apiClientProvider = Provider<Dio>(
  (ref) => buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  ),
);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: user.accessToken, refresh: user.refreshToken);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call();
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}