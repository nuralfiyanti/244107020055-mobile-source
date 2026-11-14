# AI Challenge — Week 7 Clean Architecture

- **Nama:** Nur Alfiyanti
- **NIM:** 244107020055 - 17
- **Kelas:** TI-3E
- **Tool AI:** Antigravity / Claude
- **Tanggal:** 18 Oktober 2026

---

## 1. Prompt yang Digunakan

```text
Saya memiliki project Flutter "campus_notify" dari Minggu 6.
Bantu saya melakukan audit arsitektur (Praktikum 1) dan refactor ke Clean Architecture:
1. Audit layer project lama: petakan file ke layer dan deteksi pelanggaran klasik (akses network di widget, business logic di build, DI bocor).
2. Usulkan struktur target Clean Architecture (Feature-first vs Layer-first).
3. Pisahkan arsitektur fitur Auth menjadi Tiga Layer:
   - Domain (Entity, Repository Interface, Use Cases, Failures) murni Dart tanpa dependensi Flutter/Dio/SQLite.
   - Data (Model yang extend Entity dengan JSON/Map serialization, Repository Implementation).
   - Presentation (State Notifier dengan Riverpod DI, Pages).
4. Buatkan unit test use case menggunakan repository palsu (fake repository) tanpa jaringan sungguhan.
Berikan analisis trade-off mengenai keputusan arsitektur ini.
```

**Catatan Kebijakan AI Minggu 7:**
> Sesuai kebijakan AI Minggu 7, AI diizinkan mengusulkan reorganisasi project, tetapi mahasiswa wajib menilai trade-off-nya (misalnya over-engineering untuk fitur kecil), memutuskan struktur final sendiri, dan menjelaskan setiap keputusan. Nilai ada pada justifikasi arsitektur, bukan pada kerapian folder semata.

---

## 2. Output & Usulan Reorganisasi AI

AI mengusulkan dua alternatif arsitektur:

### Opsi A: Layer-First
```text
lib/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    └── providers/
```

### Opsi B: Feature-First (Dipilih)
```text
lib/
├── core/
│   └── failures.dart
├── features/
│   └── auth/
│       ├── domain/
│       │   ├── entities/user.dart
│       │   ├── repositories/auth_repository.dart
│       │   └── usecases/
│       │       ├── login.dart
│       │       └── logout.dart
│       ├── data/
│       │   ├── models/user_model.dart
│       │   └── repositories/auth_repository_impl.dart
│       └── presentation/
│           ├── providers/auth_providers.dart
│           └── pages/
│               ├── login_page.dart
│               └── home_page.dart
```

---

## 3. Penilaian Trade-Off & Justifikasi Keputusan

| Aspek | Layer-First | Feature-First (Keputusan Akhir) |
|---|---|---|
| **Skalabilitas Fitur** | Sulit di-scale saat bertambah fitur (misal pengumuman, profil). File tersebar di folder global. | Sangat modular. Fitur dapat dikembangkan/dihapus secara independen tanpa menyentuh modul lain. |
| **Separation of Concerns** | Terjaga di level modul besar, namun mudah bocor antar fitur. | Terjaga sangat ketat di tiap fitur dengan aturan dependensi: Presentation -> Domain <- Data. |
| **Kompleksitas / Overhead** | Jumlah folder lebih sedikit. | Lebih banyak file dan folder boilerplate (entity, model, use case terpisah). |
| **Testability** | Unit test domain butuh mock global. | Murni Dart unit test; use case dapat diuji dengan mudah menggunakan `FakeAuthRepository`. |

### Justifikasi Arsitektur:
1. **Mengapa memilih Feature-First?** Aplikasi kampus ke depannya akan memiliki banyak fitur modular (Auth, Pengumuman, Profil, Jadwal, Nilai). Pendekatan feature-first memastikan tim dapat bekerja paralel per fitur tanpa conflict di layer global.
2. **Apakah over-engineering untuk Auth sederhana?** Meskipun terlihat memerlukan lebih banyak boilerplate untuk sekadar login mock, pemisahan Use Case (`LoginUseCase`, `LogoutUseCase`) dan Repository Interface (`AuthRepository`) memutus ketergantungan langsung ke SDK (misal Firebase Auth atau REST API), sehingga jika backend diganti dari mock ke JWT server atau Firebase, lapisan domain dan presentasi tidak perlu diubah sama sekali (memenuhi prinsip Open/Closed dan Dependency Inversion).