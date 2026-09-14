## Jobsheet 2: Declarative UI & Responsive Design

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

### Langkah-langkah beserta bukti Screenshoot:

## LAPORAN PRAKTIKUM WEEK02
<details>
<summary><h3>4. Praktikum: Layout Sederhana (Warm-Up)</h3></summary>
<br>
<blockquote>

## Ringkasan

Pada bagian ini dilakukan pemanasan (*warm-up*) penggunaan widget dasar Flutter sebelum masuk ke praktikum dashboard responsif, yaitu `Container`, `Row`, `Column`, dan `Expanded`, melalui pembuatan tampilan kartu profil sederhana (`ProfileCard`). Selain membangun tampilannya, dilakukan juga tiga eksperimen untuk memahami perilaku layout: menghapus `Expanded` pada baris nama untuk mengamati peringatan *overflow*, mengubah `mainAxisSize` dari `MainAxisSize.min` ke nilai default untuk melihat perubahan tinggi kartu, serta menambahkan satu baris data baru (Email) menggunakan pola `Row` + `Expanded` yang sama. <br>

---

## Langkah Praktikum :

Sebelum dashboard responsif, latih dulu widget dasar dengan membuat kartu profil sederhana. Buat project baru atau ganti sementara isi lib/main.dart: <br>

### Eksperimen warm-up
### 1.Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.
![alt text](<screenshots/Screenshot 2026-09-14 100901.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 100920.png>) <br>
Before: <br>
![alt text](<screenshots/Screenshot 2026-09-14 072016.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 102505.png>) <br>
Running:
![alt text](<screenshots/Screenshot 2026-09-14 102927.png>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 10.35.30.jpeg>) <br>
After: <br>
![alt text](<screenshots/Screenshot 2026-09-14 104234.png>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 10.39.12.jpeg>) <br>
Kembali ke Kondisi Normal: <br>
![alt text](<screenshots/Screenshot 2026-09-14 105246.png>) <br>
### 2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu.
Before: <br>
![alt text](<screenshots/Screenshot 2026-09-14 072016.png>)<br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 10.35.30.jpeg>) <br>
After: <br>
![alt text](<screenshots/Screenshot 2026-09-14 105708.png>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 11.00.22.jpeg>) <br>
### 3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama.
![alt text](<screenshots/Screenshot 2026-09-14 114809.png>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 11.46.53.jpeg>) <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>5. Praktikum: Dashboard Responsif</h3></summary>
<br>
<blockquote>

