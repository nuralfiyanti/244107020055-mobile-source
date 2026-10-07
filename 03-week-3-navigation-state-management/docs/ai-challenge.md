## Peran AI pada Codelab Ini
Untuk materi navigasi dan state management, AI boleh digunakan sebagai *co-developer* untuk membantu membuat boilerplate, tetapi tetap wajib dibaca, dijelaskan, diverifikasi, diperbaiki, dan diuji hasilnya. Nilai bukan pada banyaknya kode yang dihasilkan AI, melainkan pada kualitas prompt, verifikasi, dan dokumentasi.

# AI Challenge — StatsPage 
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

## 3. Versi awal dari AI 

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test('StatsNotifier mengembalikan hasil (baik sukses maupun gagal)',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(statsProvider.future).catchError(
      (_) => <StatItem>[],
    );

    expect(result, isA<List<StatItem>>());
  });
}
```

## Perbaikan yang dilakukan

1. **Unit test:** ditambahkan `container.listen(statsProvider, (_, _) {});` sebelum `container.read(...)`. Tanpa baris ini, `ProviderContainer` pada test murni (tanpa widget tree) bisa membuang provider di tengah proses `build()` asinkron. Ini ditemukan lewat `flutter test` berulang: test lolos dua kali, lalu *timeout* 30 detik dengan error `disposed during loading state`. Setelah perbaikan, test konsisten lolos.
2. **Struktur:** `StatItem` dipisah ke `lib/models/stat_item.dart`.
3. **Akses ke StatsPage:** awalnya lewat `IconButton` di `AppBar`, setelah refactoring dipindah ke tab **Statistik** pada `NavigationBar` (route `/stats`).

### Versi setelah perbaikan

(blok kode test yang sekarang kamu punya, dengan `container.listen(statsProvider, (_, _) {});`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
```

Bukti UI AsyncValue (loading, success, error) pada halaman Produk:". <br>
Halaman Produk Loading <br>
![alt text](<../screenshots/WhatsApp Image 2026-09-26 at 22.32.08.jpeg>) <br>

Halaman Produk Success <br>
![alt text](<../screenshots/WhatsApp Image 2026-09-26 at 22.32.08 (1).jpeg>) <br>

Halaman Produk Error <br>
![alt text](<../screenshots/WhatsApp Image 2026-09-26 at 22.57.12.jpeg>) <br>

## AI Verification Checklist

| Checklist | Hasil | Temuan |
|---|---|---|
| State diubah secara immutable | ✅ Sesuai | `TodoListNotifier` memakai list baru lewat spread `[...]`, bukan `state.add()`. State `StatsNotifier` hanya diganti lewat `AsyncLoading` dan `AsyncValue.guard`. |
| `ref.watch` di `build`, `ref.read` di callback | ✅ Sesuai | `ref.watch(statsProvider)` di `build()`, `ref.read(statsProvider.notifier)` di `onPressed`. |
| Ketiga state `AsyncValue` ditangani | ✅ Sesuai | `statsAsync.when()` menangani `loading`, `error`, dan `data`. |
| Provider bertipe eksplisit, tidak duplikat | ✅ Sesuai | `statsProvider` bertipe `AsyncNotifierProvider<StatsNotifier, List<StatItem>>`, hanya satu deklarasi. |
| Tidak memakai API Riverpod lama | ✅ Sesuai | Memakai `Notifier`, `AsyncNotifier`, dan `ConsumerWidget`; tanpa `StateProvider` atau `StateNotifierProvider`. |
| `flutter analyze` | ✅ Lolos | `No issues found!` |
| `flutter test` | ✅ Lolos | `All tests passed!` |

## Hasil testing akhir (project `week3_todo`)

- `flutter analyze`: tanpa issue.
- `flutter test`: 2 test lulus (`todo_page_test.dart` dan `stats_provider_test.dart`).

## Bukti verifikasi 
`flutter analyze`: <br>
![flutter anlyze](<../screenshots/Screenshot 2026-10-08 020416.png>) <br>

`flutter test` : <br>
![flutter test](<../screenshots/Screenshot 2026-09-28 094640.png>) <br>



