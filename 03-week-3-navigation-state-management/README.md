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