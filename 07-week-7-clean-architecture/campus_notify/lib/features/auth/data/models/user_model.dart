import '../../domain/entities/user.dart';

/// Model — representasi data + mapping ke entity.
class UserModel extends User {
  const UserModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      accessToken: map['access'] as String? ?? '',
      refreshToken: map['refresh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'access': accessToken,
        'refresh': refreshToken,
      };
}