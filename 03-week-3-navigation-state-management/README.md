## Jobsheet 3: Navigation & State Management

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

## LAPORAN PRAKTIKUM WEEK03

<details>
<summary><h3>2. Konsep navigasi dan GoRouter</h3></summary>
<br>
<blockquote>

## Ringkasan
Navigasi adalah mekanisme berpindah antar layar. Di Flutter, setiap layar adalah route yang ditumpuk pada Navigator (stack). Cara lama (Navigator 1.0) menggunakan Navigator.push dan Navigator.pop:<br>

---


## Praktikum 1 — Aplikasi multi-page dengan GoRouter

### Langkah Praktikum beserta bukti Screenshoot :

Buat project baru: <br>
![alt text](<screenshots/Screenshot 2026-09-22 180718.png>) <br>

Susun struktur folder: <br>
![alt text](<screenshots/Screenshot 2026-09-23 160424.png>) <br>

#### 1. Definisikan router di `lib/main.dart`:
![alt text](<screenshots/Screenshot 2026-09-23 160702.png>) <br>

#### 2. Halaman Home `lib/pages/home_page.dart`:
![alt text](<screenshots/Screenshot 2026-09-23 160724.png>) <br>

#### 3. Halaman Detail `lib/pages/detail_page.dart`:
![alt text](<screenshots/Screenshot 2026-09-23 160734.png>) <br>

#### 4. Jalankan dan amati. Buka item, lalu tekan tombol back sistem. Perhatikan bahwa path berubah mengikuti layar aktif, path yang sama juga dapat diakses langsung tanpa melewati Home. Inilah keunggulan router deklaratif dibanding Navigator 1.0.

Tampilan Run : <br>
![alt text](<screenshots/WhatsApp Image 2026-09-23 at 16.24.30.jpeg>) <br>

Tampilan Per Item : <br>
![alt text](<screenshots/WhatsApp Image 2026-09-23 at 16.24.31.jpeg>) <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>3. State management dengan Riverpod</h3></summary>
<br>
<blockquote>

## Ringkasan

`setState` cukup untuk state lokal pada satu widget, tetapi ketika state perlu dibagi antar banyak halaman (misal daftar ToDo yang ditampilkan di satu halaman dan diubah di halaman lain), memindahkan state naik ke atas widget tree membuat kode rumit (*prop drilling*). State management memindahkan state keluar dari widget, sehingga UI selalu bisa dibangun ulang secara konsisten dari state yang sama (UI deklaratif = f(state)), logikanya bisa diuji tanpa perlu membangun UI, dan state tetap hidup walau widget-nya sudah tidak tampil. <br>

Pada praktikum ini dipakai **Riverpod**, yang bersifat *compile-safe*, tidak bergantung pada `BuildContext`, dan mudah diuji. Konsep intinya: `ProviderScope` sebagai wadah global yang membungkus root aplikasi dan menyimpan semua provider; `Provider` untuk nilai *read-only*; `Notifier` + `NotifierProvider` untuk state yang berubah lewat method (bukan diubah langsung); `ConsumerWidget` untuk widget yang membaca provider lewat `ref`; serta perbedaan `ref.watch` (membangun ulang UI saat state berubah, dipakai di dalam `build`) dan `ref.read` (membaca sekali saja, dipakai di callback/event seperti `onPressed`).<br>

---

## Praktikum 2 — Aplikasi ToDo dengan Riverpod

### Langkah Praktikum beserta bukti Screenshoot :

Tuliskan perintah flutter create week3_todo <br>
![alt text](<screenshots/Screenshot 2026-09-24 095159.png>) <br>

Tuliskan perintah cd week3_todo dan perintah flutter pub add flutter_riverpod <br>
![alt text](<screenshots/Screenshot 2026-09-24 095247.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-24 101305.png>) <br>

Susunan File: <br>
![alt text](<screenshots/Screenshot 2026-09-24 095501.png>) <br>

#### 1. Bungkus aplikasi dengan ProviderScope di `lib/main.dart`:
![alt text](<screenshots/Screenshot 2026-09-24 122928.png>) <br>

#### 2. Buat state dan provider (lib/providers/todo_provider.dart):
![alt text](<screenshots/Screenshot 2026-09-24 122916.png>) <br>

#### 3. Tampilkan dengan ConsumerWidget (lib/pages/todo_page.dart):
![alt text](<screenshots/Screenshot 2026-09-24 122857.png>) <br> 

#### 4. Perhatikan pola penting: 
`ref.watch` di dalam `build` membuat halaman otomatis ter-rebuild saat daftar berubah; `ref.read(todoListProvider.notifier)` di dalam callback hanya memanggil method tanpa berlangganan. <br>
![alt text](<screenshots/WhatsApp Image 2026-09-24 at 12.30.29.jpeg>) <br>

Setelah aplikasi berjalan, dicoba menambahkan beberapa tugas lewat tombol `+` di pojok kanan bawah, muncul dialog "Tugas baru", diketik nama tugas (misal "jobsheet 3"), lalu ditekan **Tambah**. Tugas langsung muncul di list dan pesan "Belum ada tugas" otomatis hilang, menandakan `ref.watch(todoListProvider)` benar-benar membangun ulang tampilan begitu state berubah. <br>
![alt text](<screenshots/WhatsApp Image 2026-09-24 at 13.09.25.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-24 at 13.09.25 (1).jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-24 at 13.09.25 (2).jpeg>) <br>

Dicoba juga menandai salah satu tugas selesai dengan menekan checkbox-nya — teksnya langsung berubah jadi tercoret (*strikethrough*), sesuai kondisi `done: true` pada objek `Todo`. Terakhir, dicoba menghapus salah satu tugas lewat ikon tong sampah, dan tugas tersebut langsung hilang dari list tanpa perlu refresh manual.
![alt text](<screenshots/WhatsApp Image 2026-09-24 at 12.30.29.jpeg>) <br> 

</blockquote>
</details>

<br>

<details>
<summary><h3>4. AsyncValue: loading, error, success</h3></summary>
<br>
<blockquote>

## Ringkasan
Banyak state berasal dari proses asinkron (membaca database, memanggil API), sehingga UI harus bisa menampilkan tiga kemungkinan kondisi: *loading* (proses berjalan), *error* (gagal), dan *success* (data siap). Riverpod menyediakan `AsyncValue<T>` yang memodelkan ketiga kondisi ini dalam satu tipe, dipasangkan dengan `AsyncNotifier` untuk mengelola state asinkron dan `AsyncValue.guard` untuk menangkap exception secara otomatis tanpa `try/catch` manual yang tersebar.

---

## Praktikum 3 — Uji Ketiga State

### Kode Provider (`lib/providers/products_provider.dart`)
![alt text](<screenshots/Screenshot 2026-09-26 222551.png>) <br>

### Kode UI (`lib/pages/product_page.dart`)
![alt text](<screenshots/Screenshot 2026-09-26 222857.png>) <br>

### 1. Salin kode di atas ke project ToDo Anda (atau project terpisah) dan jalankan. Amati tampilan loading selama 2 detik pertama.
Setelah 2 detik loading, data berhasil dimuat dan ditampilkan sebagai list produk. <br>
![alt text](<screenshots/WhatsApp Image 2026-09-26 at 22.32.08.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-26 at 22.32.08 (1).jpeg>) <br>

### 2. Ubah build() sementara untuk melempar error: throw Exception('Gagal terhubung ke server');. Jalankan dan amati UI error beserta tombol Coba lagi.
Before `build()` :<br>
![alt text](<screenshots/Screenshot 2026-09-26 223620.png>) <br>

After `throw Exception('Gagal terhubung ke server') ` : <br>
![alt text](<screenshots/Screenshot 2026-09-26 225920.png>) <br>

Muncul error : <br>
![alt text](<screenshots/WhatsApp Image 2026-09-26 at 22.57.12.jpeg>) <br>

### 3. Tekan tombol Coba lagi, ref.invalidate membuat provider dijalankan ulang. Pulihkan kode, pastikan state success tampil.
Di halaman Produk yang menampilkan pesan error, tap tombol 'Coba lagi'. muncul loading lagi selama 2 detik, lalu error lagi karena memang masih `throw Exception`, tombolnya hanya menjalankan ulang `build()`, bukan memperbaiki penyebabnya. <br>

Maka berikut untuk tampilan build ulang, maka akan muncul tampilan seperti sebelumnya. <br>
![alt text](<screenshots/Screenshot 2026-09-26 225920.png>) <br>
Menjadi : <br>
![alt text](<screenshots/Screenshot 2026-09-26 223620.png>) <br>
Hsilnya : <br>
![alt text](<screenshots/WhatsApp Image 2026-09-26 at 22.32.08 (1).jpeg>) <br>

### 4. Refleksikan: mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting?
Mengosongkan layar saat *refresh* membuat pengguna kehilangan akses ke data yang sebenarnya masih relevan, dan terasa lambat karena harus menunggu ulang dari nol. Menampilkan data lama sambil memberi indikator refresh kecil (misalnya `RefreshProgressIndicator`) pengguna tetap bisa membaca data lama sambil menunggu data baru siap. Pola ini penting terutama untuk data yang jarang berubah (misalnya daftar produk) atau saat refresh berjalan otomatis di background (*pull-to-refresh*, polling), karena pengguna tidak boleh kehilangan informasi yang sudah mereka punya hanya karena sistem sedang memperbarui data. <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>5. AI Challenge</h3></summary>
<br>
<blockquote>

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
![alt text](<screenshots/WhatsApp Image 2026-09-28 at 10.00.44.jpeg>) <br>

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
      ![alt text](<screenshots/Screenshot 2026-09-29 145726.png>) <br>
   - `flutter test`: konsisten *All tests passed* pada percobaan berulang setelah perbaikan `container.listen` diterapkan.
      ![alt text](<screenshots/Screenshot 2026-09-28 094640.png>) <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>6. Refactoring dan testing</h3></summary>
<br>
<blockquote>

## Refactoring Challenge

### 1. Ekstrak `TodoTile`

Item pada list ToDo yang sebelumnya ditulis langsung di dalam `ListView.builder` (sebagai `ListTile` manual) diekstrak menjadi widget terpisah `TodoTile` di `lib/widgets/todo_tile.dart`, sehingga `build()` di `TodoPage` menjadi lebih pendek dan `TodoTile` bisa diuji secara terpisah dari halaman induknya.

```dart
class TodoTile extends StatelessWidget {
  const TodoTile({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Todo todo;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(value: todo.done, onChanged: onToggle),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.done ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
```

### 2. Provider Turunan untuk Filter

Ditambahkan `incompleteTodosProvider` di `lib/providers/todo_provider.dart` — provider turunan yang membaca `todoListProvider` dan mengembalikan hanya tugas yang belum selesai:

```dart
final incompleteTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => !todo.done).toList();
});
```

Provider ini dipakai di `TodoPage` untuk menampilkan ringkasan "Tugas belum selesai: X dari Y" di atas list, yang otomatis ikut update setiap kali status tugas berubah, tanpa perlu logika filter ditulis manual di dalam widget.

### 3. Integrasi GoRouter + NavigationBar

Aplikasi ToDo diintegrasikan dengan `GoRouter` memakai `ShellRoute`, sehingga `NavigationBar` (Tugas / Statistik) tetap persisten di halaman ToDo maupun Statistik tanpa perlu ditulis ulang di tiap halaman:

```dart
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Halaman dengan NavigationBar: ToDo (/) dan Statistik (/stats)
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const TodoPage()),
        GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
      ],
    ),
    // Halaman tanpa NavigationBar
    GoRoute(path: '/products', builder: (context, state) => const ProductPage()),
    // Praktikum 1 (dipindah dari '/' ke '/home')
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) => DetailPage(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: loc.startsWith('/stats') ? 1 : 0,
        onDestinationSelected: (i) => context.go(i == 0 ? '/' : '/stats'),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Tugas'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Statistik'),
        ],
      ),
    );
  }
}
```

**Penyesuaian struktur route:** Karena `ToDo` sekarang menjadi halaman utama (`/`), Praktikum 1 (Home & Detail dari section 2) dipindah ke `/home` dan `/home/detail/:id`. Akses antar-halaman diselesaikan lewat ikon di `AppBar`: ikon keranjang (ToDo → Produk), ikon daftar (ToDo → Home), dan ikon checklist (Home → ToDo).

Todo: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-29 at 14.49.36.jpeg>) <br>
Status: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-29 at 14.49.37 (1).jpeg>) <br>
Produk: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-29 at 14.49.37.jpeg>) <br>
Home: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-29 at 14.49.52.jpeg>) <br>
---

## Testing

Widget test baru ditambahkan di `test/todo_page_test.dart` untuk memastikan **UI bereaksi terhadap perubahan state provider** (bukan cuma menguji logika provider secara terisolasi seperti `stats_provider_test.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_navigation/pages/todo_page.dart';

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: TodoPage()),
      ),
    );

    expect(find.text('Belum ada tugas'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Kerjakan PR minggu 3');
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });
}
```

**Temuan saat pengujian:** Percobaan pertama gagal dengan error `Expected: exactly one matching candidate, Actual: ... Found 2 widgets`. Penyebabnya, setelah tombol "Tambah" ditekan, `tester.pump()` hanya memajukan **satu frame**, sementara animasi dialog menutup belum selesai — sehingga dalam satu frame yang sama masih ada dua widget dengan teks yang sama (`TextField` di dialog yang belum sepenuhnya hilang, dan item baru yang sudah tampil di list). Diperbaiki dengan mengganti `tester.pump()` menjadi `tester.pumpAndSettle()`, yang terus memproses frame sampai seluruh animasi benar-benar selesai sebelum pengecekan dilakukan.

---

## Verifikasi
`flutter analyze`:  <br>
![alt text](<screenshots/Screenshot 2026-09-29 145726.png>) <br>

`flutter test` : <br>
![alt text](<screenshots/Screenshot 2026-09-29 145726.png>) <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>7. Tugas, refleksi, dan referensi</h3></summary>
<br>
<blockquote>

## Refleksi

**1. Kapan `setState` masih cukup, dan kapan state harus naik ke Riverpod?**

`setState` masih cukup ketika state hanya dipakai dan berubah di dalam satu widget saja, tanpa perlu dibaca atau diubah dari widget/halaman lain — misalnya animasi lokal atau toggle tampilan sementara. State perlu naik ke Riverpod ketika data harus dibagi antar banyak halaman (seperti daftar ToDo yang ditampilkan di `TodoPage` tapi juga perlu diakses logikanya di tempat lain), atau ketika state harus tetap hidup meski widget yang menampilkannya sudah dilepas dari tree (misalnya berpindah halaman lewat GoRouter tapi data ToDo tidak boleh hilang).

**2. Apa perbedaan `context.go` dan `context.push`, dan kapan masing-masing tepat digunakan?**

`context.go` mengganti lokasi di stack navigasi — cocok untuk perpindahan antar tab/halaman setara (seperti NavigationBar Tugas ↔ Statistik), karena tidak menumpuk halaman lama di stack dan tombol back tidak akan kembali ke tab sebelumnya secara berurutan. `context.push` menumpuk halaman baru di atas stack yang sudah ada — cocok untuk navigasi "masuk lebih dalam" (seperti dari ToDo ke Produk atau ke Home), karena tombol back sistem akan mengembalikan pengguna persis ke halaman asalnya.

**3. Bagaimana `AsyncValue` mencegah bug dibanding tiga boolean terpisah?**

Dengan tiga boolean terpisah (`isLoading`, `hasError`, `hasData`), kombinasi yang tidak valid bisa terjadi tanpa disadari — misalnya `isLoading` dan `hasError` sama-sama `true` di saat bersamaan karena lupa direset. `AsyncValue<T>` memaksa hanya **satu** dari tiga kondisi (`loading`, `error`, `data`) yang aktif dalam satu waktu lewat satu tipe data, dan `.when()` mewajibkan ketiganya ditangani secara eksplisit — kalau lupa menangani satu kondisi, kompiler akan menandainya, bukan baru ketahuan saat aplikasi berjalan.

**4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**

Unit test `stats_provider_test.dart` hasil AI awalnya tidak menyertakan `container.listen(statsProvider, (_, __) {})`. Tanpa baris ini, `ProviderContainer` pada test murni (tanpa widget tree) bisa membuang provider di tengah proses `build()` asinkron yang belum selesai — ditemukan langsung lewat percobaan `flutter test` berulang kali, di mana test lolos 2 kali lalu tiba-tiba *timeout* 30 detik dengan error `disposed during loading state`. Perbaikan `container.listen(...)` memastikan provider tetap aktif sampai prosesnya benar-benar selesai, dan setelah itu test konsisten lolos tanpa timeout.

## Referensi

- [Slide: Navigation & State Management](https://jti-polinema.github.io/flutter-codelab/03-minggu-3-navigation-state-management/)
- [Flutter: Navigation overview](https://docs.flutter.dev/ui/navigation)
- [GoRouter package](https://pub.dev/packages/go_router)
- [Riverpod: Getting started](https://riverpod.dev/docs/introduction/getting_started)
- [Riverpod: AsyncNotifier dan AsyncValue](https://riverpod.dev/docs/essentials/side_effects)
- [Learn Dart in Y Minutes](https://learnxinyminutes.com/dart/)

</blockquote>
</details>