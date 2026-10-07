import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stat_item.dart';

class StatsNotifier extends AsyncNotifier<List<StatItem>> {
  @override
  Future<List<StatItem>> build() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Random().nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    return const [
      StatItem('Total Pengguna', 128),
      StatItem('Sesi Aktif', 42),
      StatItem('Error 24 Jam Terakhir', 3),
    ];
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<StatItem>>(StatsNotifier.new);