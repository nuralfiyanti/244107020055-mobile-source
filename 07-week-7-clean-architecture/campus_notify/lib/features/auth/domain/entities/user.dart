/// Entity User — murni Dart, tanpa anotasi Flutter/Dio.
class User {
  const User({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}