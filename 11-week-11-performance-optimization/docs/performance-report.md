# Laporan Optimasi Performa — Week 11 (`campus_notify`)

## 1. Ringkasan Proyek & Lingkungan

- **Aplikasi:** `campus_notify` (Flutter + Clean Architecture + Riverpod 3.x)
- **Komponen Utama:** `go_router`, `dio` (HTTP client & interceptor), `cached_network_image`, `flutter_secure_storage`, `firebase_messaging`, dan `AiService` (Gemini API).
- **Dokumen Audit Awal:** [performance-findings.md](performance-findings.md)

---

## 2. Baseline Metrics & Skenario Uji

### Skenario Uji
Pengukuran diarahkan pada alur utama pengguna:
1. Membuka `HomePage` dan menavigasi ke `NotesPage`, `AnnouncementPage`, serta `ChatScreen`.
2. Mengetik dan menghapus kata kunci pencarian secara cepat pada `NotesPage`.
3. Mengirim pesan pada `ChatScreen` hingga animasi indikator loading (`_DotsLoader`) dan streaming teks (`_StreamingText`) berjalan, lalu menutup halaman.
4. Melakukan navigasi ke halaman detail dan kembali ke daftar sebanyak **5 kali** untuk memantau alokasi memori.

### Baseline Metrics (Target & Pengamatan Awal)
- **Target Frame Budget:** `16,67 ms` per frame (60 FPS) atau `8,33 ms` (120 FPS).
- **Potensi Bottleneck Awal (Hasil Audit Statis):**
  - Rebuild seluruh `Scaffold` pada `NotesPage` (`setState(() {})` per ketikan), `LoginPage`, dan `ChatScreen` (`ref.watch` tanpa `.select()`).
  - Animasi `_DotsLoader` dan `_StreamingText` belum diisolasi dengan `RepaintBoundary`.
  - `HomePage` memakai `ListView(children: [...])` dan navigasi `NotesPage()` non-`const`.
  - Cache pencarian `NotesRepositoryImpl` dan cache respons `GET` pada `Dio` belum dibatasi/belum tersedia; `AnnouncementPage` belum memakai `CachedNetworkImage`; `PushService` dan `_StreamingTextState` belum membatalkan subscription/`Timer` secara eksplisit saat `dispose()`.

### Tabel Pencatatan Metrik DevTools (`before-profile.png`)
*(Diisi berdasarkan rekaman layar tab Performance & Memory pada mode `flutter run --profile`; hasil antar-rekaman dapat bervariasi tergantung beban perangkat/emulator).*

| Metrik DevTools | Baseline (`screenshots/before-profile.png`) | Target |
|---|---|---|
| Rata-rata Frame Time (UI / Raster) | *(diisi dari rekaman `before-profile.png`)* | `< 16,67 ms` |
| Jumlah Frame Kuning / Merah (*Jank*) | *(diisi dari rekaman `before-profile.png`)* | `0` atau berkurang signifikan |
| Rata-rata FPS | *(diisi dari rekaman `before-profile.png`)* | Stabil ~60 FPS |
| Heap Snapshot (5x navigasi detail–kembali) | *(diisi dari tab Memory sebelum optimasi)* | Tidak ada objek tertahan |

---

## 3. Temuan Bottleneck & Optimasi yang Diterapkan

| Komponen | Masalah Awal | Optimasi & Alasan Pemilihan | Trade-off |
|---|---|---|---|
| `NotesPage` (`notes_page.dart`) | `setState(() {})` tiap ketikan dan `ref.watch` di root `build()` | Mengganti `setState` dengan `ValueListenableBuilder`, melokalisasi `Consumer`, dan mengekstrak sub-widget `const` (`_NotesSearchBar`, `_NotesEmptyState`, `_NotesListView`, `_NoteTile`) untuk membatasi lingkup rebuild hanya ke daftar atau ikon clear | Menambah jumlah class kecil di file UI |
| `LoginPage` (`login_page.dart`) | `ref.watch(authStateProvider)` me-rebuild seluruh form termasuk kedua `TextField` | Menggunakan `Consumer` + `authStateProvider.select(...)` khusus untuk teks error dan tombol submit | Sedikit lebih verbose dibanding satu `ref.watch` di root |
| `ChatScreen` (`chat_screen.dart`) | `ref.watch(_chatProvider)` di root; `_SecurityBanner` non-`const`; animasi tanpa `RepaintBoundary`; `Future.delayed` tanpa cancel | Menambahkan `const _SecurityBanner()`, memakai `.select()` untuk `messages` & `isLoading`, membungkus `_MessageBubble` & `_TypingIndicator` dengan `RepaintBoundary`, serta mengganti `Future.delayed` dengan `Timer?` yang dibatalkan di `dispose()` | Penambahan layer `RepaintBoundary` per item pesan menggunakan sedikit memori layer GPU |
| `HomePage` (`home_page.dart`) | `ListView(children: [...])` inline dan `NotesPage()` non-`const` | Memakai `ListView.builder`, mengekstrak `_HomeQuickActions` & `_AnnouncementTile` (`const`), serta memakai `const NotesPage()` | Struktur layout berubah dari satu `ListView` menjadi `Column` + `Expanded(ListView.builder)` |
| `AnnouncementPage` (`announcement_page.dart`) | Belum memanfaatkan caching gambar jaringan dengan batas ukuran dekode | Menambahkan `CachedNetworkImage` dengan `memCacheWidth: 600`, `memCacheHeight: 300`, `placeholder`, dan `errorWidget` | Membutuhkan koneksi untuk pemuatan awal sebelum tersimpan di disk cache |
| `NotesRepositoryImpl` (`notes_repository_impl.dart`) | Filter `.where(...)` berulang untuk query sama tanpa batas cache | Menambahkan `_searchCache` dengan batas `_maxCacheEntries = 50` dan mengembalikan salinan `List<Note>.from(...)` | Penggunaan memori kecil untuk menyimpan hingga 50 hasil query terakhir |
| `Dio` Client (`api_client.dart`) | Belum ada cache untuk request `GET` berulang | Menambahkan `_GetResponseCacheInterceptor` dengan TTL 30 detik, batas `_maxEntries = 50`, dan opsi `extra['skipCache'] = true` | Data `GET` dapat tertinggal maksimal 30 detik kecuali melewati cache dengan `skipCache` |
| `PushService` (`push_service.dart`) | Tiga listener stream (`onTokenRefresh`, `onMessage`, `onMessageOpenedApp`) tidak disimpan untuk dibersihkan | Menyimpan seluruh `StreamSubscription` ke `_subscriptions` dan menambahkan `dispose()` | Pemanggil `PushService` perlu memanggil `dispose()` saat lifecycle berakhir |

---

## 4. Hasil Verifikasi (`Metrics After` & Pengujian)

### A. Bukti Terverifikasi via Kode, Analisis Statis, dan Pengujian Otomatis
1. **Analisis Statis (`flutter analyze`):**
   - `No issues found!` — seluruh refactor dan penambahan test bersih tanpa error maupun warning.
2. **Unit Test & Widget Test (`flutter test -r compact`):**
   - **51 test lulus** (`All tests passed!`), termasuk 4 test baru di `test/performance_optimization_test.dart`:
     - Verifikasi `_searchCache` pada `NotesRepositoryImpl` dan isolasi salinan list hasil.
     - Verifikasi `_GetResponseCacheInterceptor` pada `Dio` (cache hit `GET` 200 dalam TTL dan bypass via `skipCache: true`).
     - Verifikasi filter pencarian serta pembersihan `TextEditingController` pada `NotesPage.dispose()`.
     - Verifikasi pembatalan `Timer` pada `_StreamingTextState.dispose()` di `ChatScreen` saat halaman ditutup di tengah animasi streaming (`tester.takeException()` bernilai `null`).

### B. Pencatatan Metrik DevTools (`after-profile.png`)
*(Diisi dari rekaman layar tab Performance & Memory setelah optimasi menggunakan `flutter run --profile`; variasi antar-rekaman dapat terjadi tergantung kondisi runtime perangkat).*

| Metrik DevTools | Before (`screenshots/before-profile.png`) | After (`screenshots/after-profile.png`) |
|---|---|---|
| Rata-rata Frame Time (UI / Raster) | *(dari `before-profile.png`)* | *(dari `after-profile.png`)* |
| Jumlah Frame Kuning / Merah (*Jank*) | *(dari `before-profile.png`)* | *(dari `after-profile.png`)* |
| Rata-rata FPS | *(dari `before-profile.png`)* | *(dari `after-profile.png`)* |
| Heap Snapshot (5x navigasi detail–kembali) | *(sebelum optimasi)* | *(sesudah optimasi — controller & timer dibersihkan di `dispose()`)* |

