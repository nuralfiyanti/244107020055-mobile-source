## Jobsheet 11: Optimasi Performa

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## Struktur Project
- `lib/` : kode aplikasi utama (`campus_notify` dengan optimasi performa)
  - `ai/` : service komunikasi ke Gemini AI API (`ai_service.dart`)
  - `core/` : konfigurasi dasar, error handling, dan utilitas performa
  - `data/` : konfigurasi API client (`dio`), caching, dan penyimpanan token
  - `features/` : halaman fitur (auth, notes, chat AI, dll.)
  - `messaging/` : implementasi Firebase Cloud Messaging
  - `pages/` & `providers/` : halaman UI dan state management Riverpod
- `test/` : kumpulan unit test dan widget test
- `docs/` : dokumentasi hasil profiling dan catatan optimasi performa
- `screenshots/` : bukti tangkapan layar pengerjaan, DevTools profiling, dan pengujian

## Cara Menjalankan
```bash
flutter pub get
flutter run
```

Untuk menjalankan aplikasi pada mode profiling (akurasi pengukuran performa & Flutter DevTools):
```bash
flutter run --profile
```

Untuk menjalankan analisis statis dan seluruh pengujian:
```bash
flutter analyze
flutter test
```

----

## LAPORAN PRAKTIKUM WEEK 11

<details open>
<summary><h3>2. Konsep Optimasi Performa & Frame Budget</h3></summary>
<br>
<blockquote>

Aplikasi mobile modern harus responsif, hemat baterai, dan berjalan mulus pada 60/120 FPS. Performa yang buruk dapat menyebabkan *frame drop* (*jank*), konsumsi memori tinggi, baterai cepat habis, dan pengalaman pengguna yang buruk.

### Pipeline Rendering Flutter
- **UI Thread (Dart):** Menjalankan `Build Widget`, `Layout`, dan `Paint` — harus selesai dalam waktu `< 16 ms`.
- **Raster Thread (GPU):** Menjalankan `Composite` dan `Rasterize` — dapat menjadi *bottleneck* jika gambar berukuran terlalu besar atau efek visual kompleks.
- **Frame Budget:** `16,67 ms` (60 FPS) atau `8,33 ms` (120 FPS). Jika melebihi *budget*, terjadi *frame drop* (*jank*).

### Kategori Optimasi Utama

| Kategori | Fokus | Tools / Pendekatan |
|---|---|---|
| **CPU / Build** | Widget rebuild berlebih, layout berat, komputasi di UI thread | DevTools Performance, Timeline |
| **Memori** | Memory leak, gambar besar, listener/controller tidak di-dispose | DevTools Memory, Heap Snapshot |
| **Jaringan** | Request berulang, payload besar, tidak ada cache | DevTools Network, Dio Interceptor |
| **Gambar** | Resolusi tidak sesuai, format tidak efisien | DevTools Memory, `cached_network_image` |

</blockquote>
</details>

<details>
<summary><h3>3. Flutter DevTools: Profiling CPU dan Memori</h3></summary>
<br>
<blockquote>

- **Mode Profiling:** Selalu gunakan `flutter run --profile` (bukan `--debug` atau `--release`) saat melakukan profiling agar hasil pengukuran akurat tanpa *overhead* mode debug.
- **Tab Performance (CPU Profiling):**
  - *Flame Chart*: Visualisasi *call stack* per frame untuk menemukan fungsi paling atas yang memakan waktu lama.
  - *Frame Chart*: Bar hijau (`< 16 ms`), kuning (`16–32 ms`), dan merah (`> 32 ms` / *jank*).
  - *UI Thread* vs *Raster Thread*: Memisahkan analisis `build/layout/paint` dari `rasterize/image decode`.
- **Tab Memory (Memory Profiling):**
  - Memantau *Heap Size*, memori Dart + native (*Used/External*), serta *GC Events* (GC yang terlalu sering menandakan tekanan memori).
  - *Heap Snapshot & Leak Detection*: Membandingkan snapshot sebelum dan sesudah navigasi untuk mendeteksi instance yang tidak terbuang.

</blockquote>
</details>

<details>
<summary><h3>4. Mengurangi Widget Rebuild yang Tidak Perlu</h3></summary>
<br>
<blockquote>

Penyebab umum rebuild berlebih meliputi pemanggilan `setState` pada widget root yang besar, listener Riverpod pada widget yang tidak membutuhkannya, item `ListView.builder` tanpa `const`, *anonymous function* di `build`, serta penggunaan `StatefulWidget` padahal cukup `StatelessWidget`.

Teknik optimasi yang diterapkan:
- **Gunakan `const` Constructor:** Widget statis tidak ikut di-rebuild saat parent berubah.
- **Ekstrak Widget ke Class Terpisah:** Memperkecil ruang lingkup rebuild hanya pada bagian yang berubah.
- **Gunakan `RepaintBoundary`:** Mengisolasi area *paint* widget yang mahal agar tidak memicu *repaint* seluruh layar.
- **Riverpod `select` & `Consumer`:** Gunakan `ref.watch(provider.select((s) => s.field))` atau `Consumer` agar rebuild hanya terjadi saat field spesifik berubah.
- **Hindari Anonymous Function di `build`:** Gunakan *method reference* / *tear-off* agar tidak membuat closure baru di setiap frame.

</blockquote>
</details>

<details>
<summary><h3>5. Lazy Loading, Pagination, dan Optimasi Gambar</h3></summary>
<br>
<blockquote>

- **Lazy Loading dengan `ListView.builder`:** Hanya membangun item yang terlihat di *viewport* (hindari `ListView(children: [...])` untuk daftar panjang), gunakan `const` pada item widget, dan hindari `Expanded`/`Flexible` yang tidak perlu di dalam item.
- **Pagination (*Infinite Scroll*):** Memuat data per halaman menggunakan `ScrollController` (misal memuat halaman berikutnya saat mendekati `maxScrollExtent - 200`) dengan guard `_isLoading` dan `_hasMore`.
- **Optimasi Gambar:**
  - *Cache lokal & Placeholder*: Menggunakan `cached_network_image` (`CachedNetworkImage`) agar gambar tersimpan di disk dan tidak diunduh berulang.
  - *Memcache & Resize*: Mengatur `memCacheWidth` dan `memCacheHeight` sesuai ukuran tampil (bukan *full-resolution*) untuk menekan pemakaian memori GPU/RAM, serta `PaintingBinding.instance.imageCache` / `precacheImage` bila diperlukan.

</blockquote>
</details>

<details>
<summary><h3>6. Optimasi Jaringan dan Caching</h3></summary>
<br>
<blockquote>

- **HTTP Client & Interceptor (`dio`):** Memanfaatkan `Dio` dengan interceptor untuk caching respons, kompresi/payload minimal, dan pembatasan request berulang.
- **Strategi Offline-First & Local Cache:** Menyimpan data/respons secara lokal (in-memory atau storage lokal) agar tampilan tetap cepat, hemat kuota, dan tetap tersedia saat koneksi melambat atau terputus.

</blockquote>
</details>

*(Tahap 1 selesai — inisialisasi proyek, dependensi `cached_network_image` & `dio`, serta kerangka laporan awal. Pengerjaan akan berlanjut ke **Tahap 2**.)*

