import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Penyimpanan palsu di memori untuk test (tanpa Keystore/Keychain).
class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final args = invocation.namedArguments;
    switch (invocation.memberName) {
      case #write:
        final key = args[#key] as String;
        final value = args[#value] as String?;
        if (value == null) {
          data.remove(key);
        } else {
          data[key] = value;
        }
        return Future<void>.value();
      case #read:
        return Future<String?>.value(data[args[#key] as String]);
      case #deleteAll:
        data.clear();
        return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}