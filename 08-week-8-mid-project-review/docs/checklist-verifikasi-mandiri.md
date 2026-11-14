# Checklist Verifikasi Mandiri - Refactoring & Hygiene

Dokumen ini memverifikasi standar hygiene branch, proses review sejawat, pengujian otomatis, dan keputusan kritis terhadap saran AI pada Jobsheet 8 (Mid Project Review).

---

## 1. Branching & PR Hygiene
- [x] **Branch dibuat dari `develop`**: Branch fitur (`feat/notes-validation`, `feat/static-analysis-ci`, `feat/ai-challenge`) selalu di-branch dari base branch `develop`.
- [x] **PR Kecil (< 300 baris)**: PR difokuskan pada satu tanggung jawab logis per PR (tidak mencampur banyak fitur ke dalam satu PR raksasa).
- [x] **Issue Closing**: PR dikonfigurasi dengan kata kunci penutup issue (misal `Closes #12`).

## 2. Peer Review & Tindak Lanjut
- [x] **Minimal 3 Komentar Review Bermakna Ditindaklanjuti:**
  - **Komentar Kebenaran/Logic:** Sanitasi input email pada domain layer sebelum dikirim ke repository.
  - **Komentar Arsitektur:** Pemindahan aturan validasi judul dan format input keluar dari Data Layer ke Domain Use Case.
  - **Komentar Testing:** Penambahan skenario unit test untuk kasus gagal/edge case pada `login_usecase_test.dart`.
- [x] **Status Persetujuan**: Semua catatan review telah direvisi dan mendapatkan status *Approved* sebelum merge.

## 3. Otomasi & Kualitas Mesin
- [x] **`flutter analyze` Bersih**: Menghasilkan *No issues found!* tanpa warning, unused import, atau pelanggaran immutability.
- [x] **`dart format` Rapi**: Seluruh kode pada folder `lib/` dan `test/` telah diformat secara otomatis dengan standar resmi Dart (*0 changed*).
- [x] **`flutter test` Hijau**: Seluruh 28 unit test lulus (*All tests passed!*).
- [x] **CI GitHub Actions Aktif**: Workflow `.github/workflows/ci.yml` otomatis memverifikasi format, static analysis, dan test pada setiap Pull Request ke `develop`.

## 4. Evaluasi AI Challenge (Saran AI vs Keputusan Final)
Evaluasi mendalam didokumentasikan pada file `docs/ai-review-vs-keputusan.md`.

| No | Temuan AI | Kategori / Level | Keputusan Final | Alasan & Bukti Teknis |
|:---|:---|:---|:---|:---|
| 1 | Validasi bisnis bocor di Data Layer | Blocker | **Diterima** | Sesuai kaidah Clean Architecture, validasi format email/password adalah *domain logic*, bukan urusan *repository implementation*. |
| 2 | Rawan bug state akibat tuple `(User?, Failure?)` | Blocker | **Ditolak** | Record tuple Dart 3 sudah disepakati dalam arsitektur dasar project untuk menjaga kesederhanaan tanpa menambahkan dependensi pihak ketiga (*fpdart*/*sealed boilerplate* berlebih). |
| 3 | Inkonsistensi error handling pada `refresh()` | Blocker | **Diterima** | Melempar *exception* mentah membahayakan Dio interceptor. Harus dikembalikan sebagai *Failure* konsisten. |
| 4 | Edge case *unsanitized whitespace* pada input email | Saran | **Diterima** | *Whitespace* di akhir email sering terjadi pada *autofill* mobile dan menyebabkan *false negative* autentikasi. |
| 5 | Kurangnya unit test edge case | Saran | **Diterima** | *Test coverage* ditingkatkan dengan menambahkan pengujian *boundary password* (< 6 karakter). |
