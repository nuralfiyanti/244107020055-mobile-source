# AI-Assisted Development Log (Week 9)

Dokumen ini mencatat seluruh interaksi penggunaan AI coding assistant selama pengembangan fitur pencarian catatan pada project `campus_notify`. 
Sesuai panduan Jobsheet 9, setiap prompt disusun menggunakan **Formula 5 Slot** dan setiap output melalui proses verifikasi kritis (baca, grep, test, refactor) sebelum diterima ke dalam codebase.

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
| **1** | 2026-11-14<br>23:04 WIB | **Peran**: Senior Flutter Developer<br>**Konteks**: Feature-first Clean Architecture, Riverpod, SQLite<br>**Tugas**: Tambah usecase dan repository untuk filter pencarian judul catatan<br>**Batas**: Maksimal 80 baris, dilarang impor Flutter/UI di domain, jangan ubah entity User<br>**Output**: Kode Use Case + Repository + Entity | Mengusulkan `Note` entity, `NotesRepository` contract, `SearchNotesUseCase` (sanitasi trim), dan `NotesRepositoryImpl` dengan filter case-insensitive. | **Direfactor**<br>- Kode arsitektur diterima.<br>- Disesuaikan path folder ke `domain/usecase/search_notes.dart` agar konsisten dengan struktur monorepo.<br>- Dipastikan layer domain steril tanpa import material. | - `flutter test test/features/notes/search_notes_test.dart` (4 passed)<br>- `flutter analyze` clean |
| **2** | 2026-11-14<br>23:32 WIB | **Peran**: Senior Flutter Developer<br>**Konteks**: Feature-first Clean Architecture, flutter_test<br>**Tugas**: Buat unit test untuk pencarian catatan (sukses, gagal/empty, edge case spasi)<br>**Batas**: Gunakan Dart test matchers standar<br>**Output**: File `search_notes_test.dart` | Mengusulkan 4 skenario unit test lengkap (case-insensitive, empty query, not found, trimmed spaces). | **Direfactor**<br>- Awalnya file diletakkan di `lib/`, lalu direfactor dipindahkan ke direktori `test/features/notes/` yang sah.<br>- Import disesuaikan dari `usecases` ke `usecase`. | - Terminal output: `00:03 +4: All tests passed!` |
| **3** | 2026-11-15<br>00:19 WIB | **Peran**: Senior Flutter Developer<br>**Konteks**: Clean Architecture Presentation Layer, Riverpod<br>**Tugas**: Buat UI pencarian catatan dan Riverpod state provider<br>**Batas**: Dilarang ada logika filter/database di UI Widget, sediakan Empty State<br>**Output**: `notes_provider.dart` & `notes_page.dart` + widget test | Mengusulkan `AsyncNotifier` untuk `notesListProvider`, `TextField` search bar, `ListView`, dan widget `notes_empty_state`. | **Direfactor**<br>- Menghapus ketergantungan `StateProvider` yang tidak dikenali linter menjadi pure state pada notifier.<br>- Memperbaiki linter `unnecessary_underscores` pada separator builder. | - `flutter test test/features/notes/notes_page_test.dart` (2 passed)<br>- Total: 6 tests passed |
| **4** | 2026-11-15<br>01:11 WIB | **Peran**: Senior Flutter Developer (Reviewer)<br>**Konteks**: Review kritis fitur pencarian catatan<br>**Tugas**: 3 temuan dengan level blocker/saran + alasan teknis<br>**Batas**: Fokus kebenaran logika, arsitektur, dan test<br>**Output**: 3 temuan review kritis | 1. Saran: Debounce input search.<br>2. Saran: Scope pencarian ke konten.<br>3. Blocker: Usulan migrasi tuple ke package Either eksternal. | **Keputusan Seimbang**:<br>- **Temuan 1 Diterima**: Disepakati sebagai backlog refactoring berikutnya.<br>- **Temuan 3 Ditolak**: Tetap menggunakan Dart 3 Record tuple `(T?, Failure?)` demi kesederhanaan tanpa bloating package pihak ketiga. | - Tabel keputusan terdokumentasi di `ai-log.md`<br>- Kode tetap mematuhi standard Dart 3 tuple |

---

## AI Verification Checklist (Bab 6)
- [x] **Minimal 1 temuan AI terbukti benar & diperbaiki**:  
  Temuan sanitasi input query (`trim()` dan case-insensitive `toLowerCase()`) terbukti benar mencegah false negative pencarian dan sudah diuji di unit test.
- [x] **Minimal 1 temuan AI ditolak dengan alasan teknis tertulis**:  
  Usulan mengganti Dart 3 record tuple menjadi package eksternal `fpdart` / `Either` ditolak karena tim memprioritaskan arsitektur standar tanpa dependensi berlebih.
- [x] **Keputusan tiap file terdokumentasi jelas**:  
  - `note.dart`: Diterima murni.
  - `search_notes.dart`: Diterima + refactor path.
  - `notes_repository_impl.dart`: Diterima + refactor query filtering.
  - `notes_provider.dart`: Diterima + refactor notifier state.
  - `notes_page.dart`: Diterima + refactor linter.
  - `notes_page_test.dart`: Diterima + refactor direktori ke `test/`.
- [x] **Mampu menjelaskan tiap keputusan mandiri**:  
  Seluruh alur data dari `UI -> Notifier -> UseCase -> Repository` dipahami dan terbukti steril melalui static analysis.
