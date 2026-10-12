typedef DeviceTokenSender = Future<void> Function(String token);

class DeviceRepository {
  DeviceRepository({this.sender});

  final DeviceTokenSender? sender;

  Future<void> registerToken(String token) async {
    if (sender != null) await sender!(token);
  }
}
