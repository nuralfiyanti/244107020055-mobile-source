import '../../../../core/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Satu operasi bisnis — Login.
class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<(User?, Failure?)> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}