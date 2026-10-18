import '../features/auth/domain/entities/user.dart';
import '../features/auth/domain/repositories/auth_repository.dart' as domain;

class AuthSession extends User {
  const AuthSession({required super.accessToken, required super.refreshToken});
  String get access => accessToken;
  String get refresh => refreshToken;
}

class AuthRepository implements domain.AuthRepository {
  // GANTI titik ini dengan FirebaseAuth.instance.signInWithEmailAndPassword
  // atau GoogleSignIn saat backend Firebase sudah siap.
  @override
  Future<AuthSession> login(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    // Simulasi JWT: header.payload.signature (jangan parse manual di produksi,
    // gunakan verifikasi server).
    return AuthSession(
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