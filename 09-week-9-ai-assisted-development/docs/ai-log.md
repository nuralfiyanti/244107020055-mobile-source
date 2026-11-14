# AI-Assisted Development Log (Week 9)

Dokumen ini mencatat seluruh interaksi penggunaan AI coding assistant selama pengembangan fitur pada project `campus_notify`. 
Sesuai panduan Jobsheet 9, setiap prompt disusun menggunakan **Formula 5 Slot** dan setiap output wajib melalui proses verifikasi kritis (baca, grep, test, refactor) sebelum diterima ke dalam codebase.

---

## Aturan Main & Siklus Workflow
1. **Prompt** : Instruksi spesifik + konteks proyek (Formula 5 Slot, tanpa menempel secret/token).
2. **Generate** : AI mengusulkan potongan kode/solusi.
3. **Verify** : Memeriksa kode terhadap halusinasi (method fiktif, package kadaluarsa, logika yakin tapi salah).
4. **Test** : Validasi dengan `flutter analyze` dan `flutter test`.
5. **Refactor** : Sesuaikan dengan batasan arsitektur (Clean Architecture & Riverpod).
6. **Explain** : Memahami dan mampu menjelaskan kode secara mandiri tanpa bantuan AI.

---

## Log Interaksi AI

| No | Tanggal & Waktu | Prompt yang Digunakan (Formula 5 Slot) | Output AI (Ringkasan) | Verifikasi / Tindakan | Bukti (Test / Grep / Screenshot) |
|:--:|:---|:---|:---|:---|:---|
| **1** | *Contoh Format*<br>2026-11-15<br>09:30 WIB | **Peran**: Senior Flutter dev<br>**Konteks**: Feature-first Clean Architecture, Riverpod, SQLite + Dio<br>**Tugas**: Tambah usecase dan repository untuk filter pencarian judul catatan<br>**Batas**: Maksimal 60 baris, dilarang impor Flutter/UI di domain, jangan ubah entity User<br>**Output**: Kode UseCase + unit test | Mengusulkan class `SearchNotesUseCase` dan mock test sederhana. Menggunakan method `contains()` case-sensitive. | **Direfactor**<br>- Kode usecase diterima.<br>- Logika query diperbaiki menjadi *case-insensitive* (`toLowerCase()`).<br>- Dependensi layer tetap steril. | - `flutter analyze` clean<br>- Unit test: `test/features/notes/search_notes_test.dart`<br>- Screenshot: `screenshots/01-search-test.png` |
| **2** | 2026-11-15<br>10:00 WIB | **Peran**: Senior Flutter dev<br>**Konteks**: Feature-first Clean Architecture, Riverpod, SQLite<br>**Tugas**: Buatkan unit test untuk fitur search notes<br>**Batas**: Uji skenario sukses, gagal, dan edge case (trim spasi)<br>**Output**: Kode unit test | Membuat 4 skenario test. Namun, AI salah menaruh file di folder `lib/` dan ada *typo* path `usecase`. | **Direfactor & Diterima**<br>- File test dipindahkan ke folder `test/features/notes/`.<br>- Path import diperbaiki.<br>- File `validation_dummy.dart` yang rusak diperbaiki. | - `flutter test` -> **+4: All tests passed!**<br>- `flutter analyze` -> **No issues found!**<br>- Screenshot: `screenshots/02-search-test-hijau.png` |
| **3** | 2026-11-15<br>11:00 WIB | **Peran**: Senior Flutter dev<br>**Konteks**: Fitur Notes UI & Riverpod<br>**Tugas**: Membuat Widget Test untuk UI Pencarian dan Empty State<br>**Batas**: Uji skenario sukses dan empty state<br>**Output**: Kode `notes_page.dart` dan `notes_page_test.dart` | AI memberikan kode UI dan Test. Namun, ada 3 error: file test salah tempat di `lib/`, `StateProvider` tidak dikenali, dan *linter warning* `_`. | **Direfactor (Debug)**<br>- File test dipindah ke folder `test/`.<br>- `StateProvider` dihapus, diganti logika `Notifier.search()`.<br>- Linter diperbaiki. | - `flutter test` -> **+6: All tests passed!**<br>- `flutter analyze` -> **No issues found!**<br>- Screenshot: `screenshots/03-widget-test-hijau.png` |
---

## Checklist Deteksi Halusinasi AI
Gunakan checklist ini setiap kali memvalidasi usulan kode dari AI:
- [ ] **Method Fiktif**: Memastikan seluruh fungsi/API yang disarankan benar-benar ada di SDK Dart/Flutter atau library terkait (bukan halusinasi autocomplete).
- [ ] **Package / API Kadaluarsa**: Memastikan kode kompatibel dengan versi dependencies yang tertera di `pubspec.yaml` & `pubspec.lock`.
- [ ] **Logika Yakin tapi Salah**: Memverifikasi penanganan edge cases (null safety, empty string, filter case sensitivity, regex).
- [ ] **Sterilitas Arsitektur**: Memastikan layer `domain` tidak tercemar impor `flutter/material.dart`, `dio`, atau `sqflite`.
- [ ] **Privasi & Keamanan**: Memastikan tidak ada token rahasia, JWT, atau endpoint internal yang dibocorkan ke prompt.

