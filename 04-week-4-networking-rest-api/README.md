## Jobsheet 4: Networking & REST API

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

## LAPORAN PRAKTIKUM WEEK04

<details>
<summary><h3>2. Konsep HTTP, REST, dan JSON<</h3></summary>
<br>
<blockquote>

## Ringkasan
HTTP adalah protokol *request–response*: client mengirim request (method + URL + header + body), server membalas dengan status code + body. REST adalah gaya arsitektur yang m/emetakan operasi ke *resource* melalui URL dan method HTTP (`GET` membaca data, `POST` membuat resource baru, `PUT`/`PATCH` mengganti/memperbarui, `DELETE` menghapus). Status code penting yang perlu disiapkan UI-nya: `200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found`, `500 Internal Server Error` — mencakup kelompok sukses (2xx), client error (4xx), dan server/network error (5xx/timeout).

JSON (*JavaScript Object Notation*) adalah format tukar data standar API. Data mentah JSON (`Map<String, dynamic>`) perlu dipetakan ke *class model* di Dart agar aman terhadap `null` dan kesalahan ketik — pola manual `fromJson`/`toJson` cukup untuk codelab ini, sementara untuk project besar biasanya dipakai *code generator* (`json_serializable`/`freezed`).

**Repository pattern dasar** (jembatan menuju Clean Architecture di minggu 7): UI tidak boleh memanggil Dio/http secara langsung — UI hanya membaca provider. *Repository* adalah satu-satunya pintu ke sumber data (API), mengubah exception jaringan menjadi kegagalan bermakna bagi UI. Provider Riverpod mengekspos `AsyncValue` ke UI (loading/error/data). <br>

---

</blockquote>
</details>

<br>

<details>
<summary><h3>3. Praktikum 1: Dio dan Model Data</h3></summary>
<br>
<blockquote>

## Ringkasan

Pada praktikum ini dibangun fondasi *networking* aplikasi: model data (`Post`) dengan parsing JSON yang aman terhadap `null`, konfigurasi `Dio` terpusat (base URL, timeout, logging), dan `PostRepository` sebagai satu-satunya pintu pengambilan data dari API [JSONPlaceholder](https://jsonplaceholder.typicode.com/) (`GET /posts`).

---

## Langkah Praktikum beserta Bukti Screenshoot

Siapkan project (`flutter create`, `flutter pub add dio flutter_riverpod`), susun struktur folder (`lib/data/models/`, `lib/data/repositories/`, `lib/pages/`): <br>
![alt text](<screenshots/Screenshot 2026-09-29 103020.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-30 174531.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-30 174554.png>) <br>

Struktur folder: <br>
![alt text](<screenshots/Screenshot 2026-10-05 145943.png>) <br>

### 1. Model Data dengan `fromJson` Aman Null (`lib/data/models/post.dart`)
![alt text](<screenshots/Screenshot 2026-10-05 150744.png>) <br>

Respons API nyata sering tidak sesuai dokumentasi (field hilang, tipe berubah). Pola `as String? ?? ''` mencegah crash `type 'Null' is not a subtype` yang menjadi sumber bug paling umum pada integrasi API pertama.<br>

### 2. Konfigurasi Dio Terpusat (`lib/data/api_client.dart`)
![alt text](<screenshots/Screenshot 2026-10-05 151555.png>) <br>

Dio dipilih dibanding package `http` karena memberi timeout per-request, interceptor (logging/auth header), dan error terstruktur (`DioException` dengan `type`) tanpa boilerplate tambahan.

### 3. Repository sebagai Pintu Data (`lib/data/repositories/post_repository.dart`)
![alt text](<screenshots/Screenshot 2026-10-05 151843.png>) <br>

Repository tidak menampilkan UI apa pun dan tidak menangkap exception menjadi nilai diam-diam — exception dibiarkan naik agar provider mengubahnya menjadi `AsyncError` secara otomatis di langkah berikutnya.

</blockquote>
</details>

<br>

<details>
<summary><h3>4. Praktikum 2: Provider dan error handling</h3></summary>
<br>
<blockquote>

### 4. Provider AsyncNotifier + pesan error ramah pengguna (`lib/data/providers.dart`)
![alt text](<screenshots/Screenshot 2026-10-05 161849.png>) <br>
![alt text](<screenshots/Screenshot 2026-10-05 161906.png>) <br>
![alt text](<screenshots/Screenshot 2026-10-05 161929.png>) <br>

### 5. UI: loading, error, empty, success (`lib/pages/post_list_page.dart`)
![alt text](<screenshots/Screenshot 2026-10-05 162208.png>) <br>
![alt text](<screenshots/Screenshot 2026-10-05 162217.png>) <br>

### 6. Entry point dengan ProviderScope (`lib/main.dart`)
![alt text](<screenshots/Screenshot 2026-10-05 154846.png>) <br>

### Uji tiga skenario error
1. Jalankan aplikasi dengan internet normal, amati loading lalu daftar 100 posts. <br>
![alt text](<screenshots/WhatsApp Image 2026-10-05 at 16.34.26.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-10-05 at 16.34.27 (1).jpeg>) <br>

2. Matikan internet (mode pesawat), tekan refresh, amati pesan ramah + tombol Coba lagi. Nyalakan kembali internet, tekan Coba lagi. <br>
![alt text](<screenshots/WhatsApp Image 2026-10-05 at 16.34.27.jpeg>) <br>

3. Sementara ubah baseUrl menjadi URL salah, amati pesan error koneksi. Kembalikan setelah uji. <br>
![alt text](<screenshots/Screenshot 2026-10-05 164123.png>) <br>
![alt text](<screenshots/WhatsApp Image 2026-10-05 at 16.43.26.jpeg>) <br>

