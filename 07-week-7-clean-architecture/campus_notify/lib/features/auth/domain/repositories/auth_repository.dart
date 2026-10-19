import '../../../../core/failures.dart';
import '../entities/user.dart';

/// Interface — kontrak yang harus dipenuhi implementasi.
/// Domain tidak tahu Dio/SQLite.
abstract class AuthRepository {
  Future<(User?, Failure?)> login({
    required String email,
    required String password,
  });

  Future<String> refresh(String refreshToken);
}