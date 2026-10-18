import 'package:campus_notify/features/auth/data/models/user_model.dart';
import 'package:campus_notify/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    const tUserModel = UserModel(
      accessToken: 'test-access',
      refreshToken: 'test-refresh',
    );

    test('harus merupakan subclass dari entity User', () {
      expect(tUserModel, isA<User>());
    });

    test('fromMap mengonversi JSON map dengan benar', () {
      final map = {
        'access': 'access-token-123',
        'refresh': 'refresh-token-456',
      };
      final model = UserModel.fromMap(map);

      expect(model.accessToken, 'access-token-123');
      expect(model.refreshToken, 'refresh-token-456');
    });

    test('toMap mengonversi UserModel menjadi Map dengan benar', () {
      final map = tUserModel.toMap();

      expect(map['access'], 'test-access');
      expect(map['refresh'], 'test-refresh');
    });

    test('fromEntity mengonversi entity User menjadi UserModel', () {
      const entity = User(
        accessToken: 'entity-access',
        refreshToken: 'entity-refresh',
      );
      final model = UserModel.fromEntity(entity);

      expect(model.accessToken, 'entity-access');
      expect(model.refreshToken, 'entity-refresh');
    });
  });
}
