# AI Challenge: Verifikasi Review AI vs Keputusan Mahasiswa

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Tool AI:** Gemini 3.8 Flash <br>

## 1. Prompt yang Digunakan

> "Review PR Flutter ini sebagai senior Flutter dev. Konteks: feature-first Clean Architecture (presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio. Fokus: kebenaran, arsitektur, dan test. Abaikan style. Berikan 5 temuan dengan level (blocker/saran) + alasan + usulan potongan kode perbaikan."

## 2. Tabel Verifikasi (Sesuai Checklist Bab 6.3)

| No | Temuan AI | Level | Apakah Benar? (Bukti) | Keputusan Saya | Alasan |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | Validasi input bisnis berada di Data Layer (Repository), bukan di Domain (Use Case). | Blocker | **Benar.** Saya cek di `auth_repository_impl.dart` baris 14, memang ada pengecekan `email.contains('@')`. | **Terima** | Memindahkannya ke `LoginUseCase` sesuai prinsip *Clean Architecture* agar domain tidak *anemic*. |
| 2 | Penggunaan Record `(User?, Failure?)` rawan *null bug* (tidak *exhaustive*). | Blocker | **Salah (Konteks).** Meskipun secara teori benar, project ini menggunakan Dart 3 Record dan tim sudah menyepakati ini demi kesederhanaan tanpa *library* tambahan. | **Tolak** | Mengganti ke `sealed class Result` akan menambah *boilerplate* dan mengubah kontrak repository secara masif, tidak sepadan untuk skala *mock project* ini. |
| 3 | Inkonsistensi *Error Handling*: `login` pakai *return Failure*, `refresh` pakai *throw Exception*. | Blocker | **Benar.** Saya cek `auth_repository_impl.dart` baris 29, memang `throw Exception('Refresh token hilang')`. | **Terima** | Saya ubah `throw` menjadi `return (null, AuthFailure(...))` agar konsisten dan aman dari *unhandled exception*. |
| 4 | Edge Case *Unsanitized Email Input* (spasi). | Saran | **Benar.** Jika user mengetik spasi di akhir email (`test@mail.com `), validasi `contains('@')` tetap lolos. | **Terima** | Saya tambahkan `.trim()` pada input email sebelum divalidasi. |
| 5 | Ketiadaan *Unit Test* untuk *edge cases* dan simulasi *error network*. | Saran | **Benar.** Di folder `test/`, baru ada test untuk *happy path*. | **Terima (Sebagian)** | Saya tambahkan 1 *test case* untuk memastikan *password* < 6 karakter gagal, sesuai saran AI. |

## 3. Tindak Lanjut Implementasi (Refactoring)
Berdasarkan keputusan di atas, saya melakukan perbaikan pada kode:
1. Memindahkan validasi email & password ke `LoginUseCase` (Temuan 1).
2. Mengubah `throw Exception` menjadi `return Failure` pada method `refresh` (Temuan 3).
3. Menambahkan `.trim()` pada input email (Temuan 4).
4. Menambahkan *unit test* untuk kasus *password* kurang dari 6 karakter (Temuan 5).

![alt text](<../../../08-week-8-mid-project-review/screenshoot/Screenshot 2026-11-14 173537.png>) <br>
![alt text](<../../../08-week-8-mid-project-review/screenshoot/Screenshot 2026-11-14 173545.png>) <br>