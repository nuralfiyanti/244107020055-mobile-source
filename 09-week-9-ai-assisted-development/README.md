## Jobsheet 9: AI-Assisted Development

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## Struktur Project
- `07-week-7-clean-architecture/campus_notify/` : basis kode aplikasi utama
  - `lib/features/notes/` : modul catatan kuliah hasil kolaborasi AI (Clean Architecture)
    - `domain/` : entity `Note`, interface `NotesRepository`, dan `SearchNotesUseCase` (murni Dart)
    - `data/` : `NotesRepositoryImpl` dengan in-memory/SQLite mock filter
    - `presentation/` : halaman UI `NotesPage` (search bar + empty state) & state provider `NotesNotifier`
  - `test/features/notes/` : kumpulan unit test usecase & widget test UI
- `09-week-9-ai-assisted-development/` : modul laporan portofolio Week 9
  - `docs/ai-log.md` : catatan log Formula 5 Slot, hasil output AI, dan audit verifikasi
  - `screenshots/` : bukti tangkapan layar pengujian mesin & antarmuka

## Cara Menjalankan
```bash
cd 07-week-7-clean-architecture/campus_notify
flutter pub get
flutter run
```

Untuk menjalankan seluruh pengujian unit & widget test fitur notes:
```bash
flutter test test/features/notes/
flutter analyze
```

----

## LAPORAN PRAKTIKUM WEEK 09

<details>
<summary><h3>1. Konsep Workflow AI, Halusinasi, dan Formula 5 Slot</h3></summary>
<br>
<blockquote>

## 1. Siklus Workflow AI-Assisted Development
Dalam pengembangan fitur pencarian catatan ini, diterapkan 6 siklus disiplin kolaborasi dengan AI:
1. **Prompt** : Menyusun instruksi dengan konteks dan batasan arsitektur menggunakan Formula 5 Slot (tanpa token/secret).
2. **Generate** : AI mengusulkan potongan kode/solusi awal.
3. **Verify** : Membaca baris per baris, memeriksa halusinasi API, dan memastikan tidak ada ketergantungan liar.
4. **Test** : Validasi dengan menjalankan `flutter analyze` dan `flutter test`.
5. **Refactor** : Memecah fungsi panjang (< 40 baris) dan memastikan kepatuhan Clean Architecture.
6. **Explain** : Memahami dan mampu menjelaskan alur kode secara mandiri tanpa membuka AI.

---

## 2. Formula 5 Slot Prompting
Setiap instruksi disusun terstruktur agar menghasilkan kode yang presisi:
- **Peran** : Senior Flutter Developer
- **Konteks** : Feature-first Clean Architecture (`presentation -> domain <- data`), Riverpod 2, SQLite mock.
- **Tugas** : Menambahkan fitur pencarian judul catatan (*notes search*) dan UI Empty State.
- **Batas** : Maksimal 80 baris, dilarang meletakkan filter/query di dalam widget UI, layer domain steril dari import Flutter/Dio/SQLite.
- **Output** : Kode Use Case, Repository, State Notifier, Widget Page, dan pengujian unit/widget test.

---

## 3. Tiga Pola Halusinasi AI yang Diantisipasi

| Pola Halusinasi | Gejala di Flutter | Cara Membuktikan & Menolak |
|---|---|---|
| **Method Fiktif** | AI mengusulkan method helper yang tidak ada di SDK Dart/Flutter. | Cek autocomplete IDE dan dokumentasi resmi `pub.dev`. |
| **Package / API Kadaluarsa** | AI menggunakan API usang atau mengusulkan dependensi yang tidak terdaftar di `pubspec.yaml` (misal: `StateProvider` lama). | Dibuktikan melalui compiler error saat `flutter analyze`. |
| **Logika Yakin tapi Salah** | Filter query sensitif huruf besar/kecil (*case-sensitive*) atau gagal menangani spasi berlebih (*whitespace*). | Dibuktikan dengan unit test skenario kegagalan (*edge case*). |

</blockquote>
</details>

<br>

<details>
<summary><h3>2. Praktikum 1 & 2: Domain, Data, dan Unit Testing</h3></summary>
<br>
<blockquote>

## 1. Implementasi Domain & Data Layer
- **`Note` (Entity)**: Entitas bisnis murni (`id`, `title`, `content`, `updatedAt`) tanpa dependensi framework.
- **`NotesRepository` (Contract)**: Interface penentu fungsi `searchNotesByTitle(String query)`.
- **`SearchNotesUseCase`**: Menangani aturan sanitasi query `query.trim()` sebelum diteruskan ke repository.
- **`NotesRepositoryImpl`**: Mengimplementasikan pencarian *case-insensitive* menggunakan `toLowerCase().contains()`.

---

## 2. Hasil Verifikasi Unit Test
Seluruh skenario pengujian Use Case dan Repository dinyatakan lulus 100%:

```text
00:00 +0: SearchNotesUseCase: Pencarian cocok secara case-insensitive
00:00 +1: SearchNotesUseCase: Pencarian tidak ada mengembalikan list kosong
00:00 +2: SearchNotesUseCase: Query kosong mengembalikan seluruh catatan
00:00 +3: SearchNotesUseCase: Query dengan spasi berlebih ditangani dengan baik (sanitized trim)
00:00 +4: All tests passed!
```



</blockquote>
</details>

<br>

<details>
<summary><h3>3. Praktikum 3: Presentation Layer & Widget Testing</h3></summary>
<br>
<blockquote>

## 1. Arsitektur State & UI
- **`notes_provider.dart`**: Menggunakan `AsyncNotifier<List<Note>>` standar Riverpod 2 yang murni mendelegasikan tugas query ke `SearchNotesUseCase`.
- **`notes_page.dart`**: Widget UI yang terdiri dari Search Bar, ListView, dan penanganan **Empty State** (`Key('notes_empty_state')`) saat pencarian tidak ditemukan.
- **Aturan Emas**: Tidak ada logika string filter (`.contains`) atau pemanggilan database di dalam file UI.

---

## 2. Hasil Verifikasi Widget Test
Memverifikasi interaksi render UI dan transisi menuju Empty State saat query kosong:

```text
00:00 +4: NotesPage: Menampilkan daftar catatan saat halaman pertama kali dibuka
00:02 +5: NotesPage: Menampilkan pesan kosong (Empty State) saat query tidak cocok
00:03 +6: All tests passed!
```

</blockquote>
</details>

<br>

<details open>
<summary><h3>4. Bab 6 & 7: AI Challenge & Refactoring</h3></summary>
<br>
<blockquote>

## 1. Tabel Verifikasi Saran AI (Terima vs Tolak)

Dokumentasi detail prompt dan interaksi tersimpan di [`docs/ai-log.md`](./docs/ai-log.md).

| No | Komponen / Usulan AI | Status Keputusan | Alasan Teknis & Bukti |
|:--:|:---|:---:|:---|
| 1 | Sanitasi input query (`trim()`) dan pencarian *case-insensitive* | **Diterima** | Mencegah *false negative* akibat spasi otomatis keyboard mobile. Dibuktikan lulus pada 4 skenario unit test. |
| 2 | Pemecahan method `build()` menjadi fungsi kecil (< 40 baris) | **Diterima** | Method `build()` yang panjangnya 100+ baris dipecah menjadi `_buildSearchBar()`, `_buildEmptyState()`, dan `_buildNotesList()` agar mudah diuji. |
| 3 | Usulan mengganti tuple `(List<Note>?, Failure?)` dengan package luar (`fpdart` / `Either`) | **Ditolak** | Menambah beban dependensi (*bloat*) tanpa alasan fungsional mendesak. Arsitektur tim menyepakati penggunaan fitur bawaan **Dart 3 Record Tuple**. |
| 4 | Penempatan file test di dalam folder source code `lib/` | **Direfactor** | Halusinasi direktori dari AI. File test segera dipindahkan ke direktori `test/features/notes/` yang benar agar tidak merusak analisis paket rilis. |

---

## 2. Bukti Sterilitas Layer (Audit Grep)
Memverifikasi bahwa layer domain tidak tercemar library luar:

```powershell
Select-String -Path "lib\features\notes\domain\**\*.dart" -Pattern "import 'package:flutter", "import 'package:dio", "import 'package:sqflite"
```
> **Hasil:** Kosong (*No matches found*) — Terbukti layer domain 100% steril.

---

## 3. Bukti Mesin Hijau Final
Hasil eksekusi statis dan testing akhir:

```text
Analyzing campus_notify...
No issues found! (ran in 10.5s)
```
```text
00:03 +6: All tests passed!
```

</blockquote>
</details>

<br>

<details>
<summary><h3>5. Bab 8: Refleksi dan Referensi Pendukung</h3></summary>
<br>
<blockquote>

## 1. Refleksi Individu

### a. Satu halusinasi AI apa yang Anda temukan dan bagaimana membuktikannya?
- **Temuan Halusinasi:** AI menyarankan penggunaan class `StateProvider` yang sudah usang dan meletakkan file test `notes_page_test.dart` langsung di dalam folder produksi `lib/features/notes/`.
- **Cara Membuktikan:** Saat menjalankan `flutter analyze`, mesin memunculkan error `The function 'StateProvider' isn't defined` dan `The imported package 'flutter_test' isn't a dependency of the importing package`. Hal ini membuktikan bahwa saran struktur file dari AI tidak boleh langsung diterima tanpa validasi linter.

### b. Prompt mana yang paling membantu dan apa yang Anda ubah?
- **Prompt Paling Membantu:** Prompt yang menyertakan batas (*constraint*) arsitektur eksplisit: *"Dilarang menaruh logika filter di dalam widget UI, logika harus memanggil UseCase, dan sediakan Empty State"*.
- **Yang Diubah:** Beralih dari prompt umum (*"buatkan halaman search notes"*) menjadi prompt berbasis Formula 5 Slot yang menyertakan batas baris kode serta arsitektur target (`presentation -> domain <- data`).

### c. Satu refactor apa yang Anda lakukan pada kode AI?
- **Refactoring Dilakukan:** Memecah fungsi `build()` pada `notes_page.dart` yang awalnya digenerate lebih dari 100 baris menjadi fungsi helper terisolasi (`_buildSearchBar()`, `_buildEmptyState()`, dan `_buildNotesList()`) yang masing-masing berukuran di bawah 25 baris kode sehingga memenuhi batas Clean Code (< 40 baris).

### d. Keputusan terima/tolak mana yang paling sulit?
- **Keputusan Tersulit:** Menolak saran AI untuk mengadopsi library fungsional eksternal `fpdart` untuk tipe data `Either<Failure, List<Note>>`.
- **Alasan Teknis:** Pendekatan AI secara teori type-safe, namun menambahkan library pihak ketiga hanya untuk satu fitur melanggar prinsip *KISS* (*Keep It Simple, Stupid*). Keputusan akhir adalah mempertahankan **Dart 3 Record Tuple** bawaan bahasa.

---

## 2. Referensi Pendukung
1. [Slide Week 9: AI-Assisted Development / Vibe Coding](https://docs.google.com)
2. [Flutter Documentation: Static Analysis & Linter Rules](https://docs.flutter.dev/tools/analysis)
3. [Dart Official: Records and Patterns in Dart 3](https://dart.dev/language/records)
4. [Riverpod 2 Official Documentation](https://riverpod.dev/docs/introduction/getting_started)
5. [GitHub Copilot: Best Practices for Prompt Engineering](https://docs.github.com/en/copilot/using-github-copilot/best-practices-for-using-github-copilot)
6. [Learn Dart in Y Minutes](https://learnxinyminutes.com/docs/dart/)

</blockquote>
</details>

Gambar 1: Bukti Test & Analyze Hijau
(Terminal menunjukkan +6: All tests passed! dan No issues found!)
![alt text](<screenshots/Screenshot 2026-11-15 015653.png>)

Gambar 2: Bukti Halaman Notes (Daftar Catatan)
(UI menampilkan Search Bar dan daftar catatan)
![alt text](<screenshots/WhatsApp Image 2026-11-15 at 11.02.21.jpeg>)

Gambar 3: Bukti Empty State (Pencarian Kosong)
(UI menampilkan tulisan "Catatan tidak ditemukan" saat mencari "zzz")
![alt text](<screenshots/Screenshot 2026-11-15 020212.png>) 
(Ganti nama file di atas dengan nama file screenshot Empty State yang baru kamu ambil)

Gambar 4: Bukti Sterilitas Layer Domain (Grep)
(Terminal menunjukkan perintah grep tanpa output/error)
https://./screenshots/WhatsApp%20Image%202026-11-15%20at%2011.02.21.jpeg
(Ganti nama file di atas dengan nama file screenshot grep yang kamu punya)
![alt text](<screenshots/WhatsApp Image 2026-11-15 at 11.02.21 (1).jpeg>)
