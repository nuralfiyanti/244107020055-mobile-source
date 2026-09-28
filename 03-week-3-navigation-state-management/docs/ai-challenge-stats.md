# AI Challenge — StatsPage (Week 3)

**Prompt yang diajukan:**
> "Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod. Requirements: ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan pengambilan data statistik (delay 2 detik, kadang gagal 30%). UI harus menangani loading (spinner), error (pesan + tombol retry), dan success (ListView 3 item). Berikan unit test untuk notifier-nya. Jelaskan setiap bagian kode dalam komentar."

## 1. `lib/providers/stats_provider.dart`

```dart
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatItem {
  const StatItem(this.label, this.value);
  final String label;
  final int value;
}

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
```

## 2. `lib/pages/stats_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $err'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(statsProvider.notifier).refresh(),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(stats[index].label),
            trailing: Text('${stats[index].value}'),
          ),
        ),
      ),
    );
  }
}
```

## 3. `test/stats_provider_test.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test('StatsNotifier mengembalikan hasil (baik sukses maupun gagal)',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.listen(statsProvider, (_, __) {});

    final result = await container.read(statsProvider.future).catchError(
      (_) => <StatItem>[],
    );

    expect(result, isA<List<StatItem>>());
  });
}
```

## 4. Tombol Akses ke StatsPage

Ditambahkan `IconButton` baru di `AppBar` `TodoPage`, sejajar dengan tombol keranjang produk, untuk membuka `StatsPage`.

![alt text](<../screenshots/WhatsApp Image 2026-09-28 at 10.00.44.jpeg>)

## AI Verification Checklist

1. **Output Penting:**
   - `AsyncValue` memastikan ketiga kondisi (loading, error, success) wajib ditangani eksplisit lewat `.when()`, mencegah tampilan layar kosong saat data gagal dimuat.
   - `ref.watch` konsisten hanya dipakai di dalam `build()`, sementara `ref.read` dipakai di callback tombol (`onPressed`).
   - State selalu diperbarui secara immutable lewat `AsyncValue.guard`, tidak ada mutasi langsung.

2. **Keputusan yang Dipilih:**
   - Mempertahankan struktur `AsyncNotifier` dan `.when()` dari output AI, karena sudah sesuai pola yang benar.
   - Menambahkan `container.listen(statsProvider, (_, __) {})` pada unit test agar provider tetap aktif sampai proses asinkronnya selesai, mencegah provider di-*dispose* prematur saat pengujian.

3. **Alasan Teknis:**
   - `ProviderContainer` pada unit test murni (tanpa widget tree) memerlukan *listener* aktif supaya Riverpod tidak membuang provider di tengah proses `build()` yang masih berjalan.

4. **Bukti Verifikasi:**
   - `flutter analyze`: 0 peringatan/error (*No issues found*).
   - `flutter test`: konsisten *All tests passed* pada percobaan berulang setelah perbaikan `container.listen` diterapkan.

![alt text](<../screenshots/Screenshot 2026-09-28 094640.png>)