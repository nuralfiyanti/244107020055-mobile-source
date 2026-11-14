# Jobsheet 8 Mid Project Review & Code Review

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## LAPORAN PRAKTIKUM MINGGU 8

<details open>
<summary><h3>1. Praktikum 1: Hygiene Branch dan Commit</h3></summary>
<br>
<blockquote>

- **Audit & Branching:** Berhasil melakukan audit riwayat Git pada project `07-week-7-clean-architecture`. Membuat branch baru `feat/notes-validation` dari `develop`.
- **Simulasi Amend:** Membuat file dummy `campus_notify/lib/features/notes/validation_dummy.dart`. Melakukan simulasi *commit* salah (`fix bug`), lalu memperbaikinya dengan `git commit --amend -m "fix(notes): cegah simpan judul kosong + test"`.
- **Dokumentasi:** Menambahkan file `docs/review-checklist.md` berisi tabel perbandingan *commit* salah vs benar.

**Bukti (Screenshot):**
![alt text](<screenshoot/Screenshot 2026-11-08 033145.png>) <br>
![alt text](<screenshoot/Screenshot 2026-11-09 125103.png>) <br>

</blockquote>
</details>

<details open>
<summary><h3>2. Praktikum 2: PR dan Peer Review</h3></summary>
<br>
<blockquote>

- **Pull Request:** Membuat PR dari branch `feat/notes-validation` ke `develop`. Mengisi deskripsi PR sesuai template (Masalah, Solusi, Cara Uji, Closes #Issue).
- **Peer Review:** Melakukan *Peer Review* pada PR dengan pola **Observasi → Dampak → Usulan**. Memberikan status *Request changes* lalu melakukan revisi kecil sebelum akhirnya di-*Merge*.

**Bukti (Screenshot):**
![alt text](<screenshoot/Screenshot 2026-11-09 125547.png>)

</blockquote>
</details>

<details open>
<summary><h3>3. Praktikum 3: Static Analysis dan Mid Review</h3></summary>
<br>
<blockquote>

- **Pengecekan Lokal:** Menjalankan `flutter analyze`, `dart format . --set-exit-if-changed .`, dan `flutter test` hingga bersih (hijau) di folder `campus_notify`.
- **CI/CD Pipeline:** Membuat file `.github/workflows/ci.yml` untuk otomasi CI di GitHub Actions.
- **Perbaikan Error:** Memperbaiki error CI terkait *working-directory* (memindahkan `.github` ke dalam folder `07-week-7-clean-architecture`) agar runner dapat menemukan `pubspec.yaml`.
- **Update Checklist:** Meng-*update* `review-checklist.md` dengan status Mid Review (struktur feature-first, hasil test, dan bukti CI hijau).

**Bukti (Screenshot):**
![alt text](<screenshoot/Screenshot 2026-11-09 170453.png>)
![alt text](<screenshoot/Screenshot 2026-11-09 131646.png>)

</blockquote>
</details>

<details open>
<summary><h3>4. AI Challenge</h3></summary>
<br>
<blockquote>

- **Review AI:** Meminta AI mereview file `login.dart` dan `auth_repository_impl.dart` dengan prompt khusus untuk mencari 5 temuan (blocker/saran).
- **Verifikasi & Keputusan:** Membuat file `docs/ai-review-vs-keputusan.md`. Dari 5 temuan AI, saya **menerima 4 temuan** dan **menolak 1 temuan** (usulan mengganti Record Tuple menjadi *sealed class* karena menambah kompleksitas yang tidak perlu).
- **Refactoring:** Menerapkan saran yang diterima ke dalam kode `LoginUseCase` dan `AuthRepositoryImpl`, lalu memastikan `flutter test` tetap hijau.

**Dokumentasi Lengkap:** [ai-review-vs-keputusan.md](docs/ai-review-vs-keputusan.md)

</blockquote>
</details>

<details open>
<summary><h3>5. Refleksi Individu (Bab 8)</h3></summary>
<br>
<blockquote>

- **LGTM Buta vs Approve Bertanggung Jawab:** LGTM buta hanya melihat judul PR tanpa mengecek kode, berisiko meloloskan *bug* ke `develop`. Approve bertanggung jawab berarti memverifikasi arsitektur, *edge case*, dan menjalankan test sebelum menyetujui.
- **Kapan Request Changes?** Wajib *Request Changes* jika ada pelanggaran arsitektur (domain mengimpor Flutter/Dio), *bug* logika fatal, atau *test* gagal. Cukup saran jika hanya optimasi mikro atau penamaan variabel.
- **Review AI yang Ditolak:** Saya menolak usulan AI mengganti `(User?, Failure?)` menjadi `Result<S, E>`. Alasannya, Record Tuple Dart 3 sudah cukup aman dan sesuai kesepakatan tim untuk menjaga kesederhanaan (KISS) tanpa *library* tambahan.
- **Perbaikan Konkret:** Memindahkan validasi email/password dari Data Layer ke Domain Use Case. Dampaknya, *business logic* menjadi murni, terisolasi, dan mudah di-*test* tanpa bergantung pada *repository*.

</blockquote>
</details>

<details open>
<summary><h3>6. Referensi Pendukung</h3></summary>
<br>
<blockquote>

- [Slide Week 8: Mid Project Review & Code Review](#)
- [Atlassian: GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [GitHub Docs: About Pull Request Reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Flutter Static Analysis](https://docs.flutter.dev/testing/static-analysis)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

</blockquote>
</details>

