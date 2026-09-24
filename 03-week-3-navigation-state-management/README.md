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
