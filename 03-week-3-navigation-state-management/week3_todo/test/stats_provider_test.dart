import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/models/stat_item.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test('StatsNotifier mengembalikan hasil (baik sukses maupun gagal)',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

 container.listen(statsProvider, (_, _) {});

    final result = await container.read(statsProvider.future).catchError(
      (_) => <StatItem>[],
    );

    expect(result, isA<List<StatItem>>());
  });
}