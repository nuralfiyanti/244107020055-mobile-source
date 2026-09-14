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
Running:<br>
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

## Langkah Praktikum

### 1. Menyiapkan project

![alt text](<screenshots/Screenshot 2026-09-14 121850.png>) <br>
Buka lib/main.dart. Buat aplikasi profil sederhana berikut, lalu jalankan pada emulator atau perangkat fisik. <br>
![alt text](<screenshots/Screenshot 2026-09-14 121437.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 121502.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 121511.png>) <br>
Hasil Setelah di Running: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 12.24.07.jpeg>) <br>

### 2. Menambahkan interaksi: StatefulWidget dan Cupertino
Sejauh ini dashboard masih StatelessWidget. Ubah DashboardApp menjadi StatefulWidget dan tambahkan CupertinoSwitch (widget Cupertino) pada AppBar untuk mengganti tema secara manual — sekaligus membedakan komponen Material dan Cupertino secara langsung: <br>
Code: <br>
![alt text](<screenshots/Screenshot 2026-09-14 131558.png>) <br>
Sesuaikan DashboardPage agar menerima state dan callback: <br>
![alt text](<screenshots/Screenshot 2026-09-14 131558.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 131610.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 131625.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 131639.png>) <br>
Hasilnya menampilkan mode Light dan Dark: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 13.15.39.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 13.15.40.jpeg>) <br>

CupertinoSwitch dipakai di sini karena berasal dari pustaka Cupertino dan selalu menampilkan gaya iOS di platform manapun ia dijalankan. Sebagai perbandingan, Switch.adaptive milik Material otomatis menyesuaikan tampilannya sendiri — jadi gaya Material di Android, tapi otomatis berganti gaya Cupertino saat dijalankan di iOS — tanpa perlu memilih widget secara manual seperti yang dilakukan di sini. <br>

## Eksperimen layout

### 1. Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom.
Code: <br>
![alt text](<screenshots/Screenshot 2026-09-14 134929.png>) <br>
Hasilnya versi Light dan Dark: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 13.48.03.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 13.48.03 (1).jpeg>) <br>
Breakpoint sempat dicoba dengan nilai 500 terlebih dahulu, namun tidak ada perubahan jumlah kolom yang tampak dibandingkan breakpoint asli (700) — baik di HP maupun jendela Chrome yang diuji, lebar layarnya tidak pernah melampaui 500px sehingga tampilan tetap 1 kolom seperti semula. Nilai breakpoint kemudian diturunkan lagi menjadi 250 agar efeknya benar-benar bisa diamati. <br>

Pada breakpoint 250 ini, hasilnya jauh berbeda: grid nyaris selalu tampil 2 kolom pada kondisi layar HP normal, sebab lebar layar portrait rata-rata (mulai dari sekitar 360px ke atas) sudah cukup jauh di atas angka 250. Kondisi 1 kolom baru akan muncul pada situasi ekstrem saja, misalnya saat jendela aplikasi dipersempit drastis atau pada mode split-screen. Konsekuensinya, ruang tiap kartu jadi lebih sempit dibanding rancangan awal karena grid dipaksa membagi 2 kolom meski lebar layarnya jauh lebih kecil dari breakpoint 700 yang seharusnya. Ini berisiko membuat isi DashboardCard (judul dan nilai) terlihat berdesakan, bahkan berpotensi overflow kalau teks judulnya cukup panjang. <br>

### 2. Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system.

Before: <br>
![alt text](<screenshots/Screenshot 2026-09-14 144503.png>) <br>
After: <br>
![alt text](<screenshots/Screenshot 2026-09-14 144523.png>) <br>
Hasil Running: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 14.48.40.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 14.48.40 (1).jpeg>) <br>
Saat themeMode diubah paksa menjadi ThemeMode.dark, aplikasi terkunci ke tampilan gelap dan CupertinoSwitch menjadi tidak berpengaruh — nilai isDark tetap berubah saat di-tap, tapi themeMode sudah tidak membaca nilai itu lagi. Ini menunjukkan bahwa kontrol tema bergantung pada bagaimana themeMode dihubungkan ke state, bukan pada keberadaan switch itu sendiri.<br>
Setelah dikembalikan ke isDark ? ThemeMode.dark : ThemeMode.light, switch berfungsi normal kembali. Ini mempertegas prinsip UI deklaratif: tampilan mengikuti perubahan state, bukan dimanipulasi langsung.<br>

### 3. Uji aplikasi dengan ukuran layar emulator yang berbeda.

![alt text](<screenshots/WhatsApp Image 2026-09-14 at 16.04.53.jpeg>) <br>
Aplikasi diuji dalam dua orientasi: portrait dan landscape, pada breakpoint normal (700). Pada kondisi portrait, tampilan 1 kolom karena lebar layar HP jauh di bawah 700. Saat diputar ke landscape, lebar layar bertambah signifikan hingga melewati ambang 700, sehingga LayoutBuilder otomatis mengganti tampilan menjadi 2 kolom tanpa perlu restart aplikasi maupun mengubah kode apa pun, membuktikan sifat responsif layout ini benar-benar bekerja mengikuti perubahan ukuran layar secara real-time, bukan cuma bereaksi terhadap perangkat yang berbeda. <br>

### 4. Tambahkan Semantics atau label yang bermakna pada elemen yang penting bagi screen reader.

Tanpa Semantics, screen reader membaca Text(title) dan Text(value) sebagai dua elemen terpisah — misalnya "Assignments" lalu "8" dibacakan berurutan tanpa penanda bahwa keduanya saling berkaitan. Setelah dibungkus Semantics(label: '$title: $value', ...), kedua informasi digabung menjadi satu label bermakna ("Assignments: 8"), sehingga screen reader membacakannya sebagai satu kesatuan informasi, bukan dua potongan teks yang berdiri sendiri. <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>6.Tugas dan AI design exploration</h3></summary>
<br>
<blockquote>

## Langkah Praktikum

### 1. Tugas utama

Dashboard dikembangkan menjadi halaman **Academic Overview** dengan ketentuan berikut: <br>

- Memiliki header profil dan minimal empat kartu informasi.<br>
- Menggunakan Row, Column, Expanded, dan Container. <br>
- Menampilkan satu kolom pada layar sempit dan dua kolom pada layar lebar. <br>
- Menyediakan light theme dan dark theme yang tetap terbaca, dengan toggle tema (misal CupertinoSwitch atau Switch.adaptive). <br>
- Memiliki label aksesibilitas untuk informasi atau tombol penting. <br>
- Menyertakan screenshot layar sempit dan lebar pada folder screenshots/. <br>

#### Langkah Implementasi

**Langkah 1 Menambahkan widget `ProfileHeader`**
![alt text](<screenshots/Screenshot 2026-09-14 172407.png>) <br>

**Langkah 2 Memanggil `ProfileHeader` di `DashboardPage`**
Before: <br>
![alt text](<screenshots/Screenshot 2026-09-14 172627.png>) <br>

After: <br>
![alt text](<screenshots/Screenshot 2026-09-14 172806.png>) <br>

Hasil layar sempit dan lebar: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 18.02.32.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 18.49.19.jpeg>) <br>

**Langkah 3 Menambahkan label aksesibilitas untuk tombol switch**
Before: <br>
![alt text](<screenshots/Screenshot 2026-09-14 185447.png>) <br>

After: <br>
![alt text](<screenshots/Screenshot 2026-09-14 185639.png>) <br>

Hasilnya: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 19.01.23.jpeg>) <br>

**Langkah 4 Screenshot layar lebar (Chrome)**
![alt text](<screenshots/Screenshot 2026-09-14 190616.png>) <br>
![alt text](<screenshots/Screenshot 2026-09-14 190818.png>) <br>

### 2. AI Prompt Challenge

Setelah implementasi mandiri (Tugas Utama) selesai, AI digunakan untuk membandingkan alternatif tata letak dan mengaudit hasil sendiri, sesuai instruksi tugas. <br>

#### Prompt 1 — Desain

**Prompt yang diajukan:**
> "Bandingkan dua tata letak dashboard akademik untuk Flutter: versi `GridView` dan versi `LayoutBuilder` + `Column`. Jelaskan trade-off responsif dan aksesibilitasnya."

**Ringkasan jawaban AI:**

`GridView.count`:
- Ringkas, cukup ubah `crossAxisCount` untuk mengubah jumlah kolom.
- Spacing antar kartu otomatis lewat `crossAxisSpacing`/`mainAxisSpacing`.
- Trade-off responsif: `childAspectRatio` tetap memaksa tinggi kartu seragam, berisiko konten terpotong kalau teks jauh lebih panjang.
- Trade-off aksesibilitas: urutan traversal screen reader mengikuti urutan `children` (row-major), umumnya intuitif tapi perlu diverifikasi manual dengan TalkBack.

`LayoutBuilder` + `Column` manual:
- Tinggi kartu bisa menyesuaikan konten, tidak dipaksa seragam.
- Kode jauh lebih verbose, logika "kelompokkan 2 kartu per baris" ditulis manual dan rawan salah kalau jumlah kartu ganjil.
- Struktur linear (`Column` berisi `Row`) lebih mudah diprediksi urutan traversal-nya.

**Keputusan yang dipakai:** tetap `GridView`, karena kartu info pada dashboard ini berukuran seragam sehingga fleksibilitas tinggi dari pendekatan manual tidak diperlukan, dan kode tetap ringkas.

---

#### Prompt 2 — Penguatan Konsep

**Prompt yang diajukan:**
> "Jelaskan kapan penggunaan `Expanded` justru menyebabkan overflow di dalam `Row`, beri contoh kode yang gagal dan perbaikannya."

**Ringkasan jawaban AI:**

`Expanded` mencegah overflow selama parent memberi batas lebar yang jelas (*bounded*). Masalah muncul ketika `Row` berada di dalam widget yang memberi lebar tak terbatas, contohnya `Row` di dalam `SingleChildScrollView(scrollDirection: Axis.horizontal)`.

Kode yang gagal:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Expanded(child: Container(height: 50, color: Colors.indigo)), // error
      Container(width: 120, height: 50, color: Colors.grey),
    ],
  ),
)
```

Error: `RenderFlex children have non-zero flex but incoming width constraints are unbounded` — scroll horizontal memberi lebar tak terbatas, sementara `Expanded` butuh angka pasti untuk menghitung porsinya.

Perbaikan — ganti `Expanded` dengan lebar tetap:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Container(width: 200, height: 50, color: Colors.indigo),
      Container(width: 120, height: 50, color: Colors.grey),
    ],
  ),
)
```

**Relevansi ke kode dashboard:** `DashboardCard` aman dari kasus ini karena `Row`-nya berada di dalam `Card` → `GridView`, bukan di dalam scroll horizontal — `GridView` selalu memberi lebar yang jelas ke tiap child, jadi `Expanded` bekerja normal.

---

#### Prompt 3 — Verifikasi Prompt

**Prompt yang diajukan:**
> "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"

**Ringkasan jawaban AI:**

- **Responsif di bawah 600px:** ya, breakpoint `700` memastikan grid konsisten 1 kolom pada lebar berapa pun di bawah 700, termasuk di bawah 600.
- **Mengurangi aksesibilitas:** ditemukan potensi redundansi — ikon dekoratif (`dark_mode`/`light_mode`) di sebelah `CupertinoSwitch` berisiko dibaca screen reader sebagai elemen terpisah, tumpang tindih dengan label `Semantics` pada switch. Diperbaiki dengan membungkus ikon dalam `ExcludeSemantics`.
- **Widget tidak tersedia di Flutter stable:** tidak ditemukan — `CupertinoSwitch`, `GridView.count`, `LayoutBuilder`, `Semantics`, `ExcludeSemantics`, dan `ColorScheme` (Material 3) semuanya API stabil.

**Perbaikan yang diterapkan dari audit ini:**
```dart
ExcludeSemantics(
  child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
),
```

Kode: <br>
![alt text](<screenshots/Screenshot 2026-09-14 195442.png>) <br>

Hasil Run tema Dark: <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 19.01.23.jpeg>) <br>
![alt text](<screenshots/WhatsApp Image 2026-09-14 at 19.02.55.jpeg>) <br>

### 3. Refactoring Challenge

#### 1. Ekstrak kartu informasi jadi widget reusable

`DashboardCard` sudah diekstrak sebagai widget reusable sejak awal implementasi (Praktikum 5) — didefinisikan satu kali dan dipanggil 4 kali dengan parameter `title` dan `value` yang berbeda, tanpa duplikasi struktur widget. Tidak ada perubahan tambahan yang diperlukan untuk poin ini.

Manfaatnya pada sisi pemeliharaan: kalau suatu saat tampilan kartu perlu diubah (misalnya padding atau bentuk sudutnya), cukup diedit satu kali di definisi `DashboardCard`, otomatis berlaku ke seluruh 4 kartu — dibanding harus menyalin dan mengedit 4 blok kode terpisah yang berisiko membuat tampilan antar kartu jadi tidak konsisten.

#### 2. Warna dan ukuran mengikuti Theme.of(context)

Gaya teks nama pada `ProfileHeader` yang sebelumnya hardcode (`TextStyle(fontSize: 18, fontWeight: FontWeight.bold)`) diganti menjadi `Theme.of(context).textTheme.titleLarge`, sehingga ukuran dan warnanya mengikuti tema aktif secara otomatis. `Text(value)` pada `DashboardCard` sudah menggunakan `Theme.of(context).textTheme.headlineSmall` sejak implementasi awal.

Diverifikasi dengan toggle tema: warna teks header dan kartu otomatis menyesuaikan mengikuti mode terang/gelap tanpa perlu mengubah kode.

kode sebelumnya di ProfileHeader : <br>
```dart
Text(name,
    style: const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold)),
```
Perubahan Kode menjadi: <br>
![alt text](<screenshots/Screenshot 2026-09-14 195442.png>) <br>

#### 3. Breakpoint dipindahkan ke konstanta tunggal

Sebelumnya, angka `700` ditulis langsung di dalam kondisi `LayoutBuilder` (`constraints.maxWidth >= 700 ? 2 : 1`). Nilai ini dipindahkan menjadi konstanta bernama `kWideBreakpoint`, didefinisikan satu kali di file terpisah `lib/constants.dart`:

```dart
const kWideBreakpoint = 700.0;
```

lalu diimpor dan dipakai di `main.dart`:

```dart
final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
```

Perubahan ini terasa manfaatnya karena sebelumnya sempat dilakukan eksperimen mengubah-ubah nilai breakpoint secara langsung di kode (lihat bagian Eksperimen Layout, dicoba nilai 500, lalu 250, sebelum dikembalikan ke 700). Kalau breakpoint ditulis berulang di banyak tempat, tiap eksperimen semacam itu berisiko ada satu titik yang lupa dikembalikan, menyebabkan perilaku responsif jadi tidak konsisten antar bagian aplikasi. Dengan satu konstanta terpusat, perubahan (baik permanen maupun sekadar untuk eksperimen) cukup dilakukan di satu baris saja, dan otomatis konsisten di seluruh `LayoutBuilder` yang memakainya.

#### 4. Hasil flutter analyze

Kode widget_test: <br>
![alt text](<screenshots/Screenshot 2026-09-15 064438.png>) <br>
Hasilnya: <br>
![alt text](<screenshots/Screenshot 2026-09-15 064559.png>) <br>

### 4. Testing Dasar

File test: `test/widget_test.dart`, berisi 2 widget test:

1. Layar sempit (400x800) — memverifikasi lebar `Card` pertama kurang dari 700, membuktikan layout 1 kolom.
2. Layar lebar (1200x800) — memverifikasi lebar `Card` pertama lebih dari 500, membuktikan layout 2 kolom.

Sempat ditemukan error `Bad state: Too many elements` karena `find.byType(Card)` menemukan 4 `Card` sekaligus (satu per `DashboardCard`), padahal `.getSize()` hanya menerima tepat satu widget. Diperbaiki dengan menambahkan `.first` pada kedua pemanggilan `find.byType(Card)`.

Kode: <br>
![alt text](<screenshots/Screenshot 2026-09-15 065352.png>)<br>
Hasil `flutter test`:
![alt text](<screenshots/Screenshot 2026-09-15 065423.png>) <br>

</blockquote>
</details>

<br>

<details>
<summary><h3>7. Refleksi/h3></summary>
<br>
<blockquote>

**1. Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?**

Pendekatan imperative mengharuskan tiap perubahan tampilan ditulis sebagai instruksi langkah demi langkah — misalnya "ubah warna elemen ini", "sembunyikan elemen itu". Pendekatan declarative, seperti yang dipakai Flutter, cukup mendeskripsikan tampilan seharusnya seperti apa untuk suatu kondisi *state* tertentu, lalu framework yang menentukan bagaimana perubahannya diterapkan. Hal ini terasa jelas saat mengerjakan toggle tema: kode hanya perlu memanggil `setState(() => isDark = value)`, dan seluruh bagian aplikasi yang bergantung pada `Theme.of(context)` (nama di header, nilai di kartu) otomatis ikut berubah tanpa perlu instruksi manual satu per satu ke tiap elemen.

**2. Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?**

`Expanded` membantu ketika parent (misalnya `Row`) memiliki batas lebar yang jelas — dia mencegah *overflow* dengan membagi sisa ruang secara proporsional, sekaligus mencegah teks panjang meluber ke luar kartu. Ini terbukti langsung saat eksperimen warm-up: begitu `Expanded` dihapus dari `Row` yang membungkus nama, dan nama diisi teks yang cukup panjang, langsung muncul peringatan *overflow* berupa garis kuning-hitam di tepi kartu. Sebaliknya, `Expanded` justru menyebabkan error ketika parent tidak memberi batas lebar yang jelas — misalnya bila `Row` ditempatkan di dalam `SingleChildScrollView` dengan `scrollDirection: Axis.horizontal`, sehingga muncul error `RenderFlex children have non-zero flex but incoming width constraints are unbounded`.

**3. Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?**

Breakpoint yang terlalu kecil membuat layout dipaksa menjadi 2 kolom bahkan pada layar yang sebenarnya masih sempit — ini sempat dibuktikan langsung dengan mengubah breakpoint dari 700 menjadi 250, di mana grid selalu tampil 2 kolom pada hampir semua ukuran layar HP, membuat tiap kartu jadi lebih sempit dari desain awal dan berisiko konten berdesakan. Untuk theme, sempat ditemukan juga bahwa kontrol tema sepenuhnya bergantung pada bagaimana `themeMode` dihubungkan ke *state* — ketika `themeMode` dipaksa menjadi `ThemeMode.dark` secara hardcode, `CupertinoSwitch` tetap bisa disentuh tapi tidak lagi berpengaruh apa pun ke tampilan, karena `themeMode` sudah tidak lagi membaca nilai `isDark`. Ini menunjukkan breakpoint dan theme yang tidak dirancang dengan tepat bisa membuat pengalaman pengguna terasa dipaksakan atau bahkan kontrol yang mereka pakai (switch) terasa tidak berfungsi.

**4. Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?**

Setelah tugas inti (dashboard *Academic Overview*) selesai dan berjalan, rekomendasi AI diverifikasi lewat tiga cara: menjalankan `flutter analyze` untuk memastikan tidak ada *error*/*warning* baru (hasilnya `No issues found!`), menjalankan `flutter test` untuk memastikan perilaku responsif benar-benar terbukti secara otomatis (hasilnya `All tests passed!`, setelah memperbaiki `find.byType(Card)` yang awalnya menemukan 4 `Card` sekaligus alih-alih 1), dan menerapkan langsung saran perbaikan `ExcludeSemantics` dari audit prompt verifikasi ke kode `DashboardPage` yang sebenarnya, bukan sekadar mencatatnya sebagai teori. Proses ini penting karena rekomendasi AI yang terdengar benar secara konsep belum tentu langsung cocok diterapkan mentah-mentah ke kode yang sudah ada — seperti kasus `find.byType(Card)` yang perlu disesuaikan lagi (`.first`) setelah diuji nyata di project ini. 