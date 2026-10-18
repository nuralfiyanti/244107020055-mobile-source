import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Implementasi konkret — boleh pakai Dio, SQLite, dll.
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return UserModel(
      accessToken: 'mock-access-for-$email',
      refreshToken: 'mock-refresh-for-$email',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}