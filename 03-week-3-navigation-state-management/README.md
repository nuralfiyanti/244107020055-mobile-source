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
Mengosongkan layar saat *refresh* membuat pengguna kehilangan akses ke data yang sebenarnya masih relevan, dan terasa lambat karena harus menunggu ulang dari nol. Menampilkan data lama sambil memberi indikator refresh kecil (misalnya `RefreshProgressIndicator`) jauh lebih nyaman — pengguna tetap bisa membaca data lama sambil menunggu data baru siap. Pola ini penting terutama untuk data yang jarang berubah (misalnya daftar produk) atau saat refresh berjalan otomatis di background (*pull-to-refresh*, polling), karena pengguna tidak boleh kehilangan informasi yang sudah mereka punya hanya karena sistem sedang memperbarui data. <br>

</blockquote>
</details>
