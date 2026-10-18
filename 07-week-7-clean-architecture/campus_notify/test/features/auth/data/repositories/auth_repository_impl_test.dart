import 'package:campus_notify/features/auth/data/models/user_model.dart';
import 'package:campus_notify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepositoryImpl', () {
    late AuthRepositoryImpl repository;

    setUp(() {
      repository = AuthRepositoryImpl();
    });

    test('login berhasil mengembalikan UserModel untuk email dan kata sandi valid', () async {
      final user = await repository.login(
        email: 'mahasiswa@kampus.ac.id',
        password: 'password123',
      );

      expect(user, isA<UserModel>());
      expect(user.accessToken, 'mock-access-for-mahasiswa@kampus.ac.id');
      expect(user.refreshToken, 'mock-refresh-for-mahasiswa@kampus.ac.id');
    });

    test('login melempar Exception jika email tidak valid', () async {
      expect(
        () => repository.login(
          email: 'invalid-email',
          password: 'password123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('login melempar Exception jika kata sandi kurang dari 6 karakter', () async {
      expect(
        () => repository.login(
          email: 'mahasiswa@kampus.ac.id',
          password: '123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh mengembalikan token baru jika refresh token valid', () async {
      final newToken = await repository.refresh('valid-refresh-token');

      expect(newToken, startsWith('mock-access-renewed-'));
    });

    test('refresh melempar Exception jika refresh token kosong', () async {
      expect(
        () => repository.refresh(''),
        throwsA(isA<Exception>()),
      );
    });
  });
}
