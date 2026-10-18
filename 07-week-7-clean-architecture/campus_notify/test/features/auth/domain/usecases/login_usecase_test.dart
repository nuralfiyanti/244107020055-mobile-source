import 'package:campus_notify/features/auth/domain/entities/user.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastPassword;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    return const User(
      accessToken: 'fake-access',
      refreshToken: 'fake-refresh',
    );
  }

  @override
  Future<String> refresh(String refreshToken) async => 'fake-refreshed';
}

void main() {
  group('LoginUseCase', () {
    test('berhasil mengeksekusi login pada AuthRepository abstrak', () async {
      final fakeRepo = FakeAuthRepository();
      final useCase = LoginUseCase(fakeRepo);

      final result = await useCase(
        email: 'user@kampus.ac.id',
        password: 'password123',
      );

      expect(result.accessToken, 'fake-access');
      expect(result.refreshToken, 'fake-refresh');
      expect(fakeRepo.lastEmail, 'user@kampus.ac.id');
      expect(fakeRepo.lastPassword, 'password123');
    });
  });
}
