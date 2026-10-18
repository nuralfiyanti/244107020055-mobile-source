import 'dart:async';

import 'package:campus_notify/messaging/push_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maskToken hanya menampilkan 12 karakter pertama', () {
    expect(maskToken('12345678901234567890'), '123456789012...');
    expect(maskToken('short'), '***');
  });

  test('initFcmToken mengambil token awal dan memantau perubahan', () async {
    final refresh = StreamController<String>();
    final tokens = <String>[];
    final topics = <String>[];

    final subscription = await initFcmToken(
      getToken: () async => 'initial-token',
      tokenRefresh: refresh.stream,
      onToken: (token) async => tokens.add(token),
      subscribeToTopic: (topic) async => topics.add(topic),
    );

    refresh.add('renewed-token');
    await Future<void>.delayed(Duration.zero);

    expect(tokens, ['initial-token', 'renewed-token']);
    expect(topics, ['pengumuman-kampus']);

    await subscription.cancel();
    await refresh.close();
  });
}
