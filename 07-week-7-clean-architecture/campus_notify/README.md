## Jobsheet 7: Clean Architecture

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## Struktur Project
- `lib/` : kode aplikasi
  - `lib/core/` : domain core & failures (murni Dart)
  - `lib/features/auth/` : modul fitur otentikasi (Clean Architecture Feature-First)
    - `domain/` : entities, repository interfaces, use cases
    - `data/` : models (serialization) & repository implementations
    - `presentation/` : UI pages (Login, Home) & Riverpod state providers
  - `lib/data/` : token store, device repository, API client
  - `lib/messaging/` : layanan FCM & push notification
  - `lib/pages/` : halaman pengumuman & debug
  - `lib/routes.dart` : deklarasi rute GoRouter
- `test/` : unit dan widget test
  - `test/features/auth/domain/usecases/` : unit test use case dengan fake repository
  - `test/features/auth/data/models/` : unit test model mapping
  - `test/features/auth/data/repositories/` : unit test implementasi repository
  - `test/auth_test.dart` & `test/auth_push_test.dart` : unit test integrasi token & interceptor
- `docs/` : dokumentasi AI Challenge (`docs/ai-challenge.md`)
- `screenshots/` : tangkapan layar hasil

## Cara Menjalankan
```bash
flutter pub get
flutter run
```

Untuk menjalankan seluruh unit test pengujian arsitektur:
```bash
flutter test
```

----

## LAPORAN PRAKTIKUM WEEK07

<details>
<summary><h3>2. Konsep SOLID dan Clean Architecture</h3></summary>
<br>
<blockquote>

## 1. SOLID dalam Satu Contoh Flutter

| Prinsip | Arti Praktis | Gejala Pelanggaran di Flutter |
|---|---|---|
| **S**ingle Responsibility | Satu kelas punya satu alasan berubah | Widget 400 baris yang sekaligus fetch API, parsing JSON, dan formatting tanggal. |
| **O**pen/Closed | Tambah perilaku lewat ekstensi, bukan edit kode lama | Setiap sumber data baru memaksa edit widget atau notifier yang sudah berjalan stabil. |
| **L**iskov Substitution | Pengganti harus bisa menggantikan aslinya tanpa merusak sistem | Repository palsu untuk unit test melempar exception atau error yang tidak pernah dilempar repository asli. |
| **I**nterface Segregation | Jangan paksa klien bergantung pada yang tidak dipakai | Satu interface raksasa `AppRepository` untuk auth + notes + push notification sekaligus. |
| **D**ependency Inversion | Bergantung pada abstraksi, bukan concretion | State Notifier memanggil `Dio` atau `sqflite` secara langsung alih-alih melalui abstraksi repository interface. |

---

## 2. Tiga Layer dan Aturan Dependensi (Dependency Rule)

Arsitektur Clean Architecture membagi kode ke dalam tiga layer utama:

```text
┌────────────────────────────────────────────────────────┐
│             PRESENTATION (Widget, Notifier, Router)    │
│  - Halaman UI (LoginPage, HomePage)                    │
│  - State Management & DI (Riverpod Provider)           │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ bergantung ke (imports)
                            ▼
┌────────────────────────────────────────────────────────┐
│                        DOMAIN                          │
│  - Entity (User)                                       │
│  - Repository Interface (AuthRepository)               │
│  - Use Cases (LoginUseCase, LogoutUseCase)             │
│  - Failures (Failure, AuthFailure)                     │
│  * Murni Dart (tanpa Flutter SDK / Dio / SQLite)       │
└───────────────────────────▲────────────────────────────┘
                            │
                            │ diimplementasikan oleh
                            │
┌───────────────────────────┴────────────────────────────┐
│                         DATA                           │
│  - Model (UserModel - extends User + toMap/fromMap)    │
│  - Repository Impl (AuthRepositoryImpl)                │
│  - Data Sources (Dio, SQLite, FlutterSecureStorage)    │
└────────────────────────────────────────────────────────┘
```

> **Aturan Emas (Dependency Rule):** Dependensi hanya mengarah ke dalam menuju **Domain**. Lapisan `domain` tidak boleh mengimpor atau mengetahui apa pun tentang Flutter SDK, Dio, atau SQLite — sehingga logika bisnis murni dapat diuji secara independen melalui unit test murni tanpa mock jaringan atau emulator.

---

## 3. Feature-First vs Layer-First

| Struktur | Bentuk Folder | Kapan Dipakai & Trade-off |
|---|---|---|
| **Feature-First** | `lib/features/<nama_fitur>/{data, domain, presentation}` | **Pilihan Utama pada Codelab ini.** Sangat cocok untuk aplikasi multi-fitur modular. Setiap fitur terisolasi mandiri dan dapat dikembangkan/dihapus tanpa mempengaruhi fitur lain. |
| **Layer-First** | `lib/{data, domain, presentation}` (global) | Cocok untuk proyek kecil satu fitur dengan tim tunggal. Cepat di awal, namun berantakan dan sulit di-maintain saat fitur aplikasi berkembang banyak. |

</blockquote>
</details>

<br>

<details open>
<summary><h3>3. Praktikum 1: Audit Layer Project Lama</h3></summary>
<br>
<blockquote>

## 1. Pemetaan File ke Layer (Audit Project `campus_notify`)

Hasil pemetaan file project `campus_notify` dari Minggu 6 ke dalam layer arsitektur serta identifikasi masalah arsitekturnya:

| File | Layer Saat Ini | Masalah / Analisis Arsitektur |
|---|---|---|
| `lib/pages/home_page.dart` | presentation | Menginisialisasi service push secara manual di `initState` via microtask; perlu dipisahkan menjadi UI presenter murni. |
| `lib/pages/login_page.dart` | presentation | Widget berinteraksi langsung dengan notifier state; perlu dipastikan tidak ada parsing data mentah di dalam build. |
| `lib/data/api_client.dart` | data | Mengonfigurasi instance `Dio` dengan auth interceptor. Aman bila hanya disuntikkan ke repository impl, bukan dipanggil langsung oleh widget. |
| `lib/providers/auth_provider.dart` | presentation (state) | Instansiasi `AuthRepository` konkret secara langsung; belum menggunakan abstraksi interface domain. |
| `lib/providers/push_provider.dart` | presentation (state) | Terdapat kebocoran DI: instansiasi `final DeviceRepository _deviceRepository = DeviceRepository();` langsung di notifier. |
| `lib/data/auth_repository.dart` | data (+kontrak tercampur) | Interface dan implementasi masih tergabung dalam satu kelas konkret, belum ada pemisahan domain interface dan model terpisah dari entity. |
| `lib/data/token_store.dart` | data | Menyimpan token ke `FlutterSecureStorage`. Perlu diinjeksi via DI provider. |

---

## 2. Menandai Tiga Pelanggaran Klasik (Audit Grep)

Sesuai instruksi jobsheet, dilakukan pencarian tiga pelanggaran arsitektur klasik menggunakan perintah grep/ripgrep:

### A. Widget yang menyentuh jaringan atau database langsung
```bash
rg "Dio\(|http\.|openDatabase|SharedPreferences\.getInstance|FlutterSecureStorage" lib/pages lib/widgets
```
**Hasil:**
`0 hasil ditemukan.`
> Widget UI (`LoginPage`, `HomePage`, `AnnouncementPage`, `DebugPage`) bersih dari pemanggilan Dio, SQLite, atau SharedPreferences langsung. Semua akses didelegasikan melalui provider Riverpod.

### B. Logika bisnis di dalam `build()`
```bash
rg "DateFormat|jsonDecode|\.toIso8601String" lib/pages lib/widgets
```
**Hasil:**
`0 hasil ditemukan.`
> Tidak ada proses parsing JSON mentah, serialisasi ISO string, maupun formatting tanggal berat di dalam fungsi `build()` pada widget presentasi.

### C. Instansiasi manual (Dependency Injection Bocor)
```bash
rg "Repository\(|Dio\(BaseOptions" lib/pages lib/providers
```
**Hasil Temuan:**
```text
lib/providers/push_provider.dart:43:  final DeviceRepository _deviceRepository = DeviceRepository();
lib/providers/auth_provider.dart:10:  Provider<AuthRepository>((ref) => AuthRepository());
```
> **Analisis:** Ditemukan pelanggaran Dependency Inversion (DI leak) di mana `push_provider.dart` menginstansiasi `DeviceRepository` secara langsung di dalam kelas Notifier, serta `auth_provider.dart` yang menginstansiasi kelas konkret `AuthRepository` alih-alih mengikat interface ke implementasi konkret.

---

## 3. Gambar Struktur Target (Clean Architecture Feature-First)

Struktur target yang diimplementasikan pada fitur otentikasi (`auth`) dan inti (`core`):

```text
lib/
├── core/
│   └── failures.dart                            # Failure domain (murni Dart)
├── features/
│   └── auth/
│       ├── domain/                              # LAYER DOMAIN (Murni Dart)
│       │   ├── entities/
│       │   │   └── user.dart                    # Entity bisnis murni
│       │   ├── repositories/
│       │   │   └── auth_repository.dart         # Interface / Kontrak repository
│       │   └── usecases/
│       │       ├── login.dart                   # Use case Login
│       │       └── logout.dart                  # Use case Logout
│       ├── data/                                # LAYER DATA
│       │   ├── models/
│       │   │   └── user_model.dart              # Model dengan serialisasi Map/JSON
│       │   └── repositories/
│       │       └── auth_repository_impl.dart    # Implementasi konkret AuthRepository
│       └── presentation/                        # LAYER PRESENTATION
│           ├── providers/
│           │   └── auth_providers.dart          # Riverpod StateNotifier + DI
│           └── pages/
│               ├── home_page.dart               # Tampilan Home setelah login
│               └── login_page.dart              # Form Login pengguna
├── data/
│   ├── api_client.dart                          # Dio client dengan interceptor
│   ├── api_errors.dart                          # Formatting error ramah pengguna
│   ├── device_repository.dart                   # Registrasi token FCM
│   └── token_store.dart                         # Enkripsi secure storage
├── messaging/
│   └── push_service.dart                        # Handler notifikasi FCM & lokal
├── pages/
│   ├── announcement_page.dart                   # Detail pengumuman
│   └── debug_page.dart                          # Halaman debugging token FCM
├── routes.dart                                  # Konstanta rute & parser payload
└── main.dart                                    # Titik masuk aplikasi & GoRouter
```

---

## 4. Kosakata Peran Clean Architecture

- **Entity (`lib/features/auth/domain/entities/user.dart`):** Objek bisnis murni tanpa dependensi luar (tidak memiliki method `toMap`, `fromMap`, atau `toJson`). Hidup di layer **Domain**.
- **Model (`lib/features/auth/data/models/user_model.dart`):** Representasi data sumber luar (JSON/SQLite/Map) yang merupakan turunan dari Entity, dilengkapi mapping (`fromMap`, `toMap`, `fromEntity`). Hidup di layer **Data**.
- **Repository Interface (`lib/features/auth/domain/repositories/auth_repository.dart`):** Kontrak abstrak yang dibutuhkan domain untuk operasi data (misal: `login()`, `refresh()`). Domain tidak tahu apakah data berasal dari Dio, SQLite, atau Memory. Hidup di layer **Domain**.
- **Repository Impl (`lib/features/auth/data/repositories/auth_repository_impl.dart`):** Implementasi konkret yang memenuhi kontrak interface menggunakan client jaringan (Dio) atau storage. Hidup di layer **Data**.
- **Use Case (`lib/features/auth/domain/usecases/login.dart`):** Satu operasi bisnis spesifik (misal: `LoginUseCase`, `LogoutUseCase`). Menghubungkan presentation dengan repository interface. Hidup di layer **Domain**, dipanggil oleh Presentation.
- **Dependency Injection (DI):** Penyuntikan dependensi konkret ke abstraksi menggunakan provider Riverpod (`authRepositoryProvider`, `loginUseCaseProvider`). Widget tidak pernah melakukan `new Repository()` sendiri.

> **Catatan Penting:** Clean Architecture bukan sekadar memindahkan file ke dalam folder berbeda. Yang dinilai adalah **arah panah dependensi** (Presentation -> Domain <- Data).

---

## 5. Implementasi Kode dan Pengujian

Seluruh file layer Clean Architecture telah diperbaiki dan diverifikasi:
1. `failures.dart` murni Dart dengan sealed class `Failure`.
2. `user.dart` murni Dart tanpa dependensi eksternal.
3. `auth_repository.dart` merupakan interface abstrak murni Dart.
4. `login.dart` use case murni menerima interface `AuthRepository`.
5. `user_model.dart` melakukan mapping aman JSON/Map.
6. `auth_repository_impl.dart` mengimplementasikan interface `AuthRepository` secara lengkap.
7. `auth_providers.dart` menyuntikkan dependensi secara deklaratif via Riverpod.
8. `main.dart` mengonsumsi provider dan halaman presentasi Clean Architecture.

### Hasil Verifikasi Statis & Unit Test:
- **`flutter analyze`:**
  ```text
  Analyzing campus_notify...
  No issues found!
  ```
- **`flutter test`:**
  ```text
  00:05 +28: All tests passed!
  ```
  Menjalankan 28 unit test secara sukses meliputi:
  - Unit test `LoginUseCase` dengan `FakeAuthRepository` tanpa database/jaringan.
  - Unit test `UserModel` mapping (`fromMap`, `toMap`, `fromEntity`).
  - Unit test `AuthRepositoryImpl` (login valid, login error, token refresh).
  - Unit test Dio auto-refresh token interceptor, TokenStore secure storage, dan AppRoutes.

</blockquote>
</details>