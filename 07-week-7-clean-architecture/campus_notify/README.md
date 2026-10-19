## Jobsheet 7: Clean Architecture

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## Struktur Project
- `lib/` : kode aplikasi utama
  - `core/` : konfigurasi dasar & error handling
  - `features/auth/` : modul otentikasi (Clean Architecture)
    - `domain/` : entity, interface repository, use case (murni Dart)
    - `data/` : model JSON & implementasi repository
    - `presentation/` : halaman UI & state provider
  - `data/` : konfigurasi API client & penyimpanan token
  - `messaging/` : implementasi Firebase Cloud Messaging
  - `pages/` & `providers/` : sisa halaman dari project sebelumnya
- `test/` : kumpulan unit test
- `docs/` : dokumentasi AI Challenge
- `screenshots/` : bukti tangkapan layar

## Cara Menjalankan
```bash
flutter pub get
flutter run

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

## 1. Pemahaman SOLID pada Flutter

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
![struktur_folder bagian](<screenshots/week07/Screenshot 2026-10-18 092841.png>)

## 4. Kosakata Peran Clean Architecture
Berdasarkan hasil praktikum, saya memahami peran masing-masing komponen sebagai berikut: 
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
1. Membuat `failures.dart` menjadi `sealed class` murni Dart.
2. Memisahkan `user.dart` (Entity) dan `user_model.dart` (Model).
3. Membuat interface `auth_repository.dar`t di folder domain, dan implementasinya di folder data.
4. Memindahkan logika login ke `login.dart` (Use Case).
5. Menghubungkan `main.dart` dan halaman presentasi ke provider yang baru.

Berikut adalah kode untuk Use Case dan Interface Repository: <br>
![login_dart_clean](<screenshots/week07/Screenshot 2026-10-18 095137.png>)
![auth_repository_dart](<screenshots/week07/Screenshot 2026-10-18 095155.png>)

### Hasil Verifikasi Statis & Unit Test:
- **`flutter analyze`:**
![flutter_analyze bagian 2](<screenshots/week07/Screenshot 2026-10-18 092920.png>)

- **`flutter test`:**
![flutter_test bagian2](<screenshots/week07/Screenshot 2026-10-18 095035.png>)

  Menjalankan 28 unit test secara sukses meliputi:
  - Unit test `LoginUseCase` dengan `FakeAuthRepository` tanpa database/jaringan.
  - Unit test `UserModel` mapping (`fromMap`, `toMap`, `fromEntity`).
  - Unit test `AuthRepositoryImpl` (login valid, login error, token refresh).
  - Unit test Dio auto-refresh token interceptor, TokenStore secure storage, dan AppRoutes.

</blockquote>
</details>

<br>

<details>
<summary><h3>4. Praktikum 2: Domain dan Data per Fitur</h3></summary>
<br>
<blockquote>

Pada praktikum ini, fitur Otentikasi (`auth`) dipisahkan secara ketat menjadi layer **Domain** dan **Data**:

### 1. Entity Murni (`lib/features/auth/domain/entities/user.dart`)
Bebas dari import Flutter SDK dan bebas dari method mapping:
```dart
class User {
  const User({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}
```

### 2. Failure Hierarchy (`lib/core/failures.dart`)
Menggunakan fitur modern Dart 3 `sealed class` untuk representasi kegagalan:
```dart
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ParseFailure extends Failure {
  const ParseFailure(super.message);
}
```

### 3. Repository Interface (`lib/features/auth/domain/repositories/auth_repository.dart`)
Mengembalikan Dart Record ganda `(User?, Failure?)` agar penanganan sukses/gagal bersifat eksplisit tanpa kebocoran exception ke UI:
```dart
import '../../../../core/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<(User?, Failure?)> login({
    required String email,
    required String password,
  });

  Future<String> refresh(String refreshToken);
}
```

### 4. Model & Data Mapping (`lib/features/auth/data/models/user_model.dart`)
Model berada di layer Data, meng-extends Entity `User`, dan memiliki fungsi mapping:
```dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      accessToken: user.accessToken,
      refreshToken: user.refreshToken,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      accessToken: map['access'] as String? ?? '',
      refreshToken: map['refresh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'access': accessToken,
        'refresh': refreshToken,
      };
}
```

### 5. Repository Implementation (`lib/features/auth/data/repositories/auth_repository_impl.dart`)
Mengimplementasikan interface repository domain dengan mengembalikan data model atau failure objek:
```dart
import '../../../../core/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<(User?, Failure?)> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      return (null, const AuthFailure('Email atau kata sandi tidak valid'));
    }
    return (
      UserModel(
        accessToken: 'mock-access-for-$email',
        refreshToken: 'mock-refresh-for-$email',
      ),
      null,
    );
  }

  @override
  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

### 6. Use Cases (`lib/features/auth/domain/usecases/login.dart` & `logout.dart`)
Use Case merangkum satu operasi bisnis spesifik:
```dart
import '../../../../core/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<(User?, Failure?)> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
```

```dart
class LogoutUseCase {
  Future<void> call() async {
  }
}
```

</blockquote>
</details>

<br>

<details>
<summary><h3>5. Praktikum 3: Presentation, DI, dan Verifikasi Sterilitas</h3></summary>
<br>
<blockquote>

## 1. Wiring Dependency Injection (`lib/features/auth/presentation/providers/auth_providers.dart`)

Penyuntikan dependensi diatur terpusat menggunakan Riverpod:
```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/api_client.dart';
import '../../../../data/token_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../data/repositories/auth_repository_impl.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final apiClientProvider = Provider<Dio>(
  (ref) => buildApiClient(
    ref.watch(tokenStoreProvider),
    ref.watch(authRepositoryProvider),
  ),
);

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final (user, failure) = await ref
          .read(loginUseCaseProvider)
          .call(email: email, password: password);

      if (failure != null) {
        throw Exception(failure.message);
      }

      if (user != null) {
        await ref
            .read(tokenStoreProvider)
            .save(access: user.accessToken, refresh: user.refreshToken);
      }
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}
```

---

## 2. Pengujian Grep Sterilitas Dua Arah (Aktual pada Project Week 7)

Dua perintah grep dijalankan untuk membuktikan kepatuhan terhadap Aturan Dependensi (Dependency Rule):

### A. Sterilitas Layer Presentation
Memastikan tidak ada akses database atau client jaringan langsung di layer presentasi:
```bash
git grep -n -E "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences|getInstance|jsonDecode" -- lib/features/auth/presentation
```
**Hasil Aktual:**
```text
0 temuan (exit code 1 - No matches found)
```
> **Kesimpulan:** Layer Presentation 100% steril dari instansiasi library database dan network.

### B. Sterilitas Layer Domain & Core
Memastikan layer Domain dan Core murni Dart tanpa import platform/SDK:
```bash
git grep -n -E "^import 'package:(flutter|dio|sqflite|firebase)" -- lib/features/auth/domain lib/core
```
**Hasil Aktual:**
```text
0 temuan (exit code 1 - No matches found)
```
> **Kesimpulan:** Layer Domain dan Core 100% murni Dart tanpa dependensi external/SDK.

</blockquote>
</details>

<br>

<details>
<summary><h3>6. AI Challenge: Eksplorasi & Trade-off Arsitektur</h3></summary>
<br>
<blockquote>

Sesuai panduan AI Challenge Week 07, AI digunakan untuk merancang reorganisasi arsitektur. Hasil dari AI **tidak langsung diterapkan**, melainkan dievaluasi trade-off teknisnya terlebih dahulu.

Dokumentasi lengkap (prompt, output awal AI, tabel usulan vs keputusan final, dan hasil verifikasi tiga grep sterilitas) tersedia di:

Dokumentasi lengkap tersedia di: [docs/ai-challenge.md](docs/ai-challenge.md)

</blockquote>
</details>

<br>

<details>
<summary><h3>7. Refactoring, Testing, dan Error Umum</h3></summary>
<br>
<blockquote>

## 1. Unit Test Use Case dengan Fake Repository

Pengujian murni logika bisnis `LoginUseCase` dilakukan tanpa mock HTTP atau database sungguhan menggunakan `FakeAuthRepository` di [test/features/auth/domain/usecases/login_usecase_test.dart](file:///d:/244107020055-mobile-source/07-week-7-clean-architecture/campus_notify/test/features/auth/domain/usecases/login_usecase_test.dart):

```dart
class FakeAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastPassword;

  @override
  Future<(User?, Failure?)> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    return (
      const User(
        accessToken: 'fake-access',
        refreshToken: 'fake-refresh',
      ),
      null,
    );
  }

  @override
  Future<String> refresh(String refreshToken) async => 'fake-refreshed';
}
```

## 2. Tabel Error Umum Arsitektur dan Solusinya

| No | Error / Pelanggaran | Penyebab | Solusi Tepat |
|---|---|---|---|
| 1 | `import 'package:dio/dio.dart'` di folder `domain/` | Kebocoran layer: Domain mengetahui detail teknologi HTTP client. | Hapus import Dio dari domain; gunakan murni tipe data Dart atau Record `(data, failure)`. |
| 2 | Model digunakan langsung di parameter Use Case | Entity dilewati, Use Case langsung bergantung pada JSON Model. | Gunakan Entity pada domain kontrak interface; konversi Model ke Entity di layer Data. |
| 3 | Instansiasi manual `new RepositoryImpl()` di Widget | Pelanggaran Dependency Inversion; widget terikat erat ke implementasi konkret. | Inject instance via Riverpod Provider (`ref.watch(authRepositoryProvider)`). |
| 4 | File lama tidak dihapus setelah migrasi | Konflik import duplikat antara file lama dan file feature baru. | Hapus file lama dan arahkan seluruh import test ke namespace `features/auth/`. |
| 5 | Pattern Record Type Mismatch | Return type repository tidak sinkron dengan tipe destructuring di Presenter. | Sinkronkan tipe pengembalian ganda `Future<(User?, Failure?)>` pada Interface, Impl, dan Use Case. |

---

## 3. Checklist Mandiri Kepatuhan Arsitektur (10 Poin)

| # | Item Checklist | Status | Catatan Verifikasi |
|---|---|---|---|
| 1 | Struktur Feature-First | ✅ | Folder `lib/features/auth/{domain, data, presentation}` dan `lib/core/` lengkap. |
| 2 | Sterilitas Presentation | ✅ | Grep 1 menghasilkan 0 temuan (bersih dari Dio/SQLite langsung). |
| 3 | Sterilitas Domain & Core | ✅ | Grep 2 menghasilkan 0 temuan (murni Dart tanpa import Flutter SDK/Dio). |
| 4 | Interface di Domain, Impl di Data | ✅ | `AuthRepository` abstract class di domain; `AuthRepositoryImpl` di data. |
| 5 | Entity Bebas Mapping | ✅ | `User` murni POJO tanpa `toMap`/`fromMap`/`toJson`. |
| 6 | Use Case + Record Pattern | ✅ | `LoginUseCase` mengembalikan Record `(User?, Failure?)`. |
| 7 | DI Terpusat | ✅ | Wiring provider terpusat di `auth_providers.dart`; widget bebas instansiasi manual. |
| 8 | File Lama Dihapus | ✅ | 4 file legacy berhasil dihapus; seluruh import test dialihkan. |
| 9 | `flutter analyze` | ✅ | Lolos 0 warning dan 0 error (`No issues found!`). |
| 10 | `flutter test` | ✅ | Seluruh 28 unit test lulus 100%. |

</blockquote>
</details>

<br>

<details open>
<summary><h3>8. Tugas, Refleksi, dan Referensi</h3></summary>
<br>
<blockquote>

---

## 3. Bukti Visual — Behavior Identik Before/After

Refactor ke Clean Architecture **tidak mengubah perilaku aplikasi**. Screenshot "before" diambil dari aplikasi Week 6 (kode sebelum refactor), "after" diambil dari aplikasi Week 7 (kode hasil refactor). **Keduanya identik** — membuktikan refactor murni arsitektural.

### A. Login Page

| Before (Week 6) | After (Week 7) |
| :---: | :---: |
| <img src="![alt text](<screenshots/week06/WhatsApp Image 2026-10-12 at 13.55.00 (1).jpeg>)" width="250"> | <img src="![alt text](<screenshots/week07/WhatsApp Image 2026-10-19 at 23.26.35.jpeg>)" width="250"> |
| Form login — email + password | Form login — email + password (identik) |

### B. Home Page

| Before (Week 6) | After (Week 7) |
| :---: | :---: |
| <img src="![alt text](<screenshots/week06/WhatsApp Image 2026-10-12 at 20.10.55 (2).jpeg>)" width="250"> | <img src="![alt text](screenshots/week07/dff6a0a4-7af7-47db-b8c4-b952dda282fc.jpeg)" width="250"> |
| Sesi aktif + daftar pengumuman | Sesi aktif + daftar pengumuman (identik) |

### C. Struktur Folder & Verifikasi Arsitektur

| Bukti | Deskripsi |
| :---: | :--- |
| <img src="![alt text](<screenshots/week07/Screenshot 2026-10-19 233909.png>)" width="500"> | Struktur folder `lib/features/auth/` — Clean Architecture feature-first |
| <img src="![alt text](<screenshots/week07/Screenshot 2026-10-19 222606.png>) " width="500"> | `flutter analyze` — No issues found! |
| <img src="![alt text](<screenshots/week07/Screenshot 2026-10-19 222612.png>)" width="500"> | `flutter test` — +28: All tests passed! | 

## 2. Refleksi Kritis Mahasiswa

### Pertanyaan 1: Mengapa interface repository harus tinggal di domain, bukan di data? Apa yang rusak bila dibalik?
> **Jawaban:** <br>
> Berdasarkan prinsip **Dependency Inversion**, modul tingkat tinggi (Domain/Business Logic) tidak boleh bergantung pada modul tingkat rendah (Data/Infrastructure); keduanya harus bergantung pada abstraksi. <br>
> Jika interface ditaruh di layer Data, maka layer Domain terpaksa mengimpor layer Data untuk memanggil repository. Hal ini membalik arah panah dependensi (`Domain -> Data`), sehingga Domain tidak lagi independen. Akibatnya, setiap perubahan infrastruktur data (misalnya migrasi dari Dio ke Firebase Auth, atau perubahan struktur cache) akan memaksa domain dan unit test bisnis ikut diubah dan di-recompile. Menaruh interface di domain memastikan domain mendikte kontrak data yang ia butuhkan, bukan sebaliknya.

### Pertanyaan 2: Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?
> **Jawaban:** <br>
> - **Use Case benar-benar dibutuhkan** saat operasi bisnis melibatkan aturan validasi yang kompleks, orkestrasi lebih dari satu repository (misalnya `SyncDataUseCase` yang menggabungkan Local SQLite dan Remote REST API), atau logika bisnis yang dipanggil berulang kali dari berbagai presenter/background worker berbeda.
> - **Repository langsung ke Notifier sudah cukup** untuk operasi CRUD satu baris yang sangat sederhana (misalnya sekadar mengambil detail item by ID tanpa transformasi bisnis tambahan) pada aplikasi berskala kecil atau prototype, guna menghindari boilerplate yang berlebihan (over-engineering).

### Pertanyaan 3: Apa biaya over-engineering (use case per CRUD satu-baris) bagi tim kecil? Kapan biayanya sepadan?
> **Jawaban:** <br>
> - **Biayanya:** Tim kecil harus membuat dan memelihara banyak file boilerplate (interface, use case class, wrapper call, mock test usecase). Hal ini memperlambat kecepatan rilis awal (time-to-market) dan menambah cognitive load bagi developer baru yang membaca kode.
> - **Kapan sepadan:** Biaya tersebut menjadi sangat sepadan saat aplikasi mulai berkembang menjadi skala enterprise dengan banyak modul, ketika aturan bisnis terus berkembang, atau ketika aplikasi wajib memiliki coverage unit test murni yang tinggi tanpa bergantung pada emulator atau mock jaringan yang lambat dan rapuh.

### Pertanyaan 4: Bagian mana dari usulan AI yang Anda tolak atau sederhanakan, dan mengapa?
> **Jawaban:** <br>
> Dari usulan AI, saya menolak pendekatan **Layer-First** (`lib/data`, `lib/domain`, `lib/presentation` secara global) karena pendekatan tersebut mencampuradukkan entitas otentikasi dengan modul lain sehingga sulit di-maintain saat fitur kampus bertambah banyak. Saya juga menyederhanakan penggunaan third-party package fungsional (`fpdart` / `dartz`) dengan memanfaatkan fitur bawaan **Dart 3 Records** `(User?, Failure?)` yang jauh lebih ringan, native, dan mudah dipahami tanpa menambah beban dependensi eksternal.

---

## 3. Referensi Pendukung

- Martin, Robert C. (Uncle Bob). *The Clean Architecture*. Clean Coder Blog.
- Flutter Official Documentation. *Flutter App Architecture Guide*.
- Reso Coder. *Flutter Clean Architecture Tutorial*.
- Riverpod Documentation. *Providers and Dependency Injection*.
- Dart Language Tour. *Records, Pattern Matching, and Sealed Classes in Dart 3*.
- GoRouter Documentation. *Declarative Routing and Deep Linking*.

</blockquote>
</details>