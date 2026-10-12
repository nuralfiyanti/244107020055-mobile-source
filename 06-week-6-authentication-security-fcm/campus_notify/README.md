## Jobsheet 6: Authentication, Security, dan FCM

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## Struktur Project

- `lib/` : kode aplikasi
  - `lib/data/` : token store, repository auth, dan API client
  - `lib/providers/` : state authentication dan push dengan Riverpod
  - `lib/messaging/` : layanan FCM dan notifikasi lokal
  - `lib/pages/` : halaman login, home, pengumuman, dan debug FCM
- `test/` : unit test token, auth provider, dan refresh token
- `docs/` : dokumentasi tambahan
- `screenshots/` : tangkapan layar hasil praktikum

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

Login mock: email harus memuat `@`, kata sandi minimal 6 karakter.

> **Penting:** Praktikum 2 membutuhkan konfigurasi Firebase yang **tidak disertakan di repositori** (`android/` dan `google-services.json` diabaikan git). Langkah menyiapkannya ada di bagian Praktikum 2.

----

## LAPORAN PRAKTIKUM WEEK06

<details>
<summary><h3>2. Konsep Authentication, Security, dan FCM</h3></summary>
<br>
<blockquote>

## 1. Model Authentication yang Dipakai

| Pola | Cara kerja singkat | Kapan dipakai |
|---|---|---|
| Firebase Auth | Firebase mengelola credential dan menghasilkan ID token yang diverifikasi backend | Login email, Google, atau provider lain tanpa membangun auth server sendiri |
| JWT + refresh token | Server menerbitkan access token berumur pendek dan refresh token berumur panjang | Backend kampus atau REST API milik sendiri |
| OAuth | Aplikasi menerima authorization code dari provider lalu menukarnya menjadi token | Login sosial atau SSO kampus |

Codelab ini memakai **mock auth provider + JWT simulasi** agar berjalan tanpa backend. Pola repository dan token dibuat menyerupai produksi, sehingga migrasi ke Firebase Auth atau backend kampus hanya mengganti sumber token.

---

## 2. ID Token, Access Token, dan Refresh Token

- **ID token**: bukti identitas pengguna, diverifikasi backend.
- **Access token**: izin akses berumur pendek, dikirim sebagai `Authorization: Bearer <token>`.
- **Refresh token**: tiket berumur panjang untuk meminta access token baru tanpa login ulang. Hanya disimpan di secure storage, tidak pernah di SharedPreferences.

```text
Login -> access token berumur pendek + refresh token berumur panjang
Request API -> Authorization: Bearer access-token
401 expired -> refresh token -> access token baru -> ulangi request satu kali
Refresh gagal -> hapus token -> kembali ke halaman login
```

---

## 3. Arsitektur Firebase Cloud Messaging

```text
App Server (backend) -> Firebase Cloud Messaging
FCM -> perangkat Android / iOS
Aplikasi -> mendaftarkan token perangkat dan mengirimkannya ke backend
```

Alur wajib: (1) aplikasi meminta izin notifikasi, (2) mengambil registration token lewat `FirebaseMessaging.instance.getToken()`, (3) token dikirim ke backend dan disimpan per user, (4) backend memanggil FCM API untuk mengirim pesan ke token atau topik tertentu.

---

## 4. Notification Payload dan Data Payload

| Jenis | Isi | Perilaku sistem |
|---|---|---|
| `notification` | `title` dan `body` untuk tampilan | Android menampilkan otomatis saat background atau terminated; saat foreground harus ditampilkan manual |
| `data` | Key-value bebas, misalnya `route: /pengumuman/3` | Selalu diteruskan ke handler aplikasi, tidak ditampilkan otomatis |

Aturan praktis Campus Notification App: kirim gabungan `notification + data`. `notification` untuk teks yang dibaca pengguna, `data.route` untuk tujuan deeplink saat diklik.

---

## 5. Tiga State Aplikasi yang Wajib Diuji

| State | Arti | Handler yang bekerja |
|---|---|---|
| Foreground | Aplikasi sedang terbuka | `FirebaseMessaging.onMessage`, lalu tampilkan local notification secara manual |
| Background | Aplikasi diminimalkan | Banner sistem otomatis dan `onMessageOpenedApp` saat banner diklik |
| Terminated | Aplikasi tidak aktif | `getInitialMessage()` saat aplikasi dibuka dari notifikasi |

---

## 6. Prinsip Keamanan Dasar

Jangan menyimpan token atau secret di SharedPreferences atau meng-hardcode di Dart, jangan mencetak token ke log, dan jangan mengirim refresh token lewat query URL. Refresh token hanya lewat body POST HTTPS dan disimpan di `flutter_secure_storage`.

</blockquote>
</details>

<br>

<details>
<summary><h3>3. Praktikum 1: Login, Secure Storage, dan Token Refresh</h3></summary>
<br>
<blockquote>

## Tujuan Praktikum

- login dengan mock auth provider yang dapat diganti Firebase Auth;
- penyimpanan access token dan refresh token dengan `flutter_secure_storage`;
- state authentication dengan `flutter_riverpod`;
- route guard dengan `go_router`;
- interceptor Dio yang mengirim access token dan me-refresh otomatis saat menerima HTTP 401.

**File:** `lib/data/token_store.dart`, `lib/data/auth_repository.dart`, `lib/data/api_client.dart`, `lib/providers/auth_provider.dart`, `lib/pages/login_page.dart`, `lib/pages/home_page.dart`, `lib/pages/announcement_page.dart`, `lib/main.dart`

---

## Langkah Praktikum beserta Bukti Screenshot

### 1. Setup Project

```powershell
flutter create campus_notify
cd campus_notify
flutter pub add flutter_riverpod go_router dio flutter_secure_storage
flutter pub add firebase_core firebase_messaging flutter_local_notifications
```

Struktur folder:

```text
lib/
├── main.dart
├── data/
│   ├── api_client.dart
│   ├── auth_repository.dart
│   └── token_store.dart
├── providers/
│   └── auth_provider.dart
├── messaging/
└── pages/
    ├── announcement_page.dart
    ├── home_page.dart
    └── login_page.dart
test/
├── auth_test.dart
└── helpers/
    └── fake_secure_storage.dart
```

`flutter_local_notifications` membutuhkan core library desugaring di `android/app/build.gradle.kts`:

```kotlin
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
```

### 2. Token Store (`lib/data/token_store.dart`)

`TokenStore` adalah satu-satunya pintu untuk menyimpan dan membaca token. Token tidak disimpan di `SharedPreferences`, tidak ditulis di source code, dan tidak dicetak ke log. `flutter_secure_storage` memakai Keystore (Android) dan Keychain (iOS).

| Method | Fungsi |
|---|---|
| `save` | Menyimpan access token dan refresh token |
| `readAccess` | Membaca access token |
| `readRefresh` | Membaca refresh token |
| `clear` | Menghapus seluruh token saat logout atau refresh gagal |

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  Future<String?> readAccess() => _storage.read(key: _accessKey);
  Future<String?> readRefresh() => _storage.read(key: _refreshKey);
  Future<void> clear() => _storage.deleteAll();
}
```

### 3. Repository Authentication Mock (`lib/data/auth_repository.dart`)

- Login berhasil jika email memuat `@` dan kata sandi minimal 6 karakter.
- Login mengembalikan pasangan access token dan refresh token mock.
- `refresh` menghasilkan access token baru; refresh token kosong menghasilkan error.

Pada implementasi nyata, `login` diganti `FirebaseAuth.instance.signInWithEmailAndPassword` tanpa mengubah kontrak provider dan token store.

```dart
class AuthSession {
  const AuthSession({required this.access, required this.refresh});

  final String access;
  final String refresh;
}

class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      throw Exception('Email atau kata sandi tidak valid');
    }
    return AuthSession(
      access: 'mock-access-for-$email',
      refresh: 'mock-refresh-for-$email',
    );
  }

  Future<String> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
    return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

### 4. Provider Authentication dan Route Guard (`lib/providers/auth_provider.dart`, `lib/main.dart`)

`AuthNotifier` mengelola status login sebagai `AsyncValue<bool>`: saat aplikasi dibuka ia membaca access token dari secure storage, `login` memanggil repository lalu menyimpan token, dan `logout` menghapus token lalu menginvalidasi state.

| Kondisi | Perilaku GoRouter |
|---|---|
| Belum login membuka route selain `/login` | Diarahkan ke `/login` |
| Sudah login membuka `/login` | Diarahkan ke `/` |
| Aplikasi dimulai | Sesi dipulihkan dari secure storage sebelum UI tampil |

```dart
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

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
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      return true;
    });
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    ref.invalidateSelf();
  }
}
```

### 5. Dio dengan Refresh Token Otomatis (`lib/data/api_client.dart`)

Alur interceptor:

1. Sebelum request, access token dibaca dari `TokenStore` dan dipasang sebagai `Authorization: Bearer ...`.
2. Jika response 401, refresh token dibaca lalu `AuthRepository.refresh` dipanggil.
3. Token baru disimpan dan request diulang **satu kali**. Penanda `retried` pada `RequestOptions.extra` mencegah pengulangan tanpa batas bila server tetap menolak.
4. Jika **refresh** gagal, token dihapus agar pengguna login ulang.
5. Jika **pengulangan** gagal karena hal lain (misalnya server 500), error diteruskan tanpa menghapus sesi.

Base URL `https://example-campus-api.test` hanya placeholder. Login Praktikum 1 berjalan lewat repository mock.

```dart
onError: (e, handler) async {
  final is401 = e.response?.statusCode == 401;
  final alreadyRetried = e.requestOptions.extra['retried'] == true;
  if (!is401 || alreadyRetried) return handler.next(e);

  final refresh = await store.readRefresh();
  if (refresh == null) return handler.next(e);

  final String renewed;
  try {
    renewed = await auth.refresh(refresh);
    await store.save(access: renewed, refresh: refresh);
  } catch (_) {
    await store.clear(); // refresh ikut mati -> paksa login ulang
    return handler.next(e);
  }

  try {
    final options = e.requestOptions
      ..headers['Authorization'] = 'Bearer $renewed'
      ..extra['retried'] = true;
    return handler.resolve(await dio.fetch<dynamic>(options));
  } on DioException catch (retryError) {
    return handler.next(retryError); // gagal bukan karena sesi: jangan logout
  }
},
```

Interceptor sengaja tidak memakai `LogInterceptor`, karena akan mencetak header `Authorization` (token) ke log.

### 6. Halaman dan Pengujian Manual di HP

- `LoginPage`: input email dan kata sandi, indikator loading, dan pesan error.
- `HomePage`: status sesi aktif, tombol keluar, dan daftar pengumuman contoh.
- `AnnouncementPage`: halaman tujuan deeplink dengan parameter `id`.

<table>
  <tr>
    <th align="center">Form login</th>
    <th align="center">Login gagal</th>
    <th align="center">Login berhasil (Home)</th>
    <th align="center">Detail pengumuman</th>
    <th align="center">Setelah keluar</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2013.55.01.jpeg" width="170"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2013.55.00.jpeg" width="170"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2015.31.13.jpeg" width="170"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2015.34.32.jpeg" width="170"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2015.31.13%20-%20Copy.jpeg" width="170"></td>
  </tr>
</table>

| Skenario | Hasil |
|---|---|
| Login dengan email tanpa `@` atau sandi kurang dari 6 karakter | Pesan error tampil, tetap di halaman login |
| Login valid | Masuk ke Home, status "Sesi aktif" |
| Membuka pengumuman | Halaman detail terbuka, tombol back kembali ke Home |
| Menekan ikon keluar | Token dihapus, kembali ke halaman login |

### 7. Pengujian Otomatis

File: `test/auth_test.dart` dan `test/helpers/fake_secure_storage.dart`. Refresh token diuji dengan server palsu (`HttpClientAdapter`) karena belum ada backend:

| Pengujian | Yang dibuktikan |
|---|---|
| `TokenStore` | Menyimpan, membaca, dan menghapus token |
| 401 lalu refresh | Request diulang dan berhasil, token baru tersimpan |
| Refresh gagal | Token dihapus (paksa login ulang) |
| Tetap 401 setelah refresh | Berhenti setelah satu kali percobaan ulang |
| Tanpa refresh token | Error diteruskan, tidak ada percobaan ulang |
| `AuthNotifier` | Awalnya belum login, login berhasil, login gagal, logout |

<table>
  <tr>
    <th align="center">flutter analyze</th>
    <th align="center">flutter test</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/Screenshot%202026-10-12%20144612.png" width="400"></td>
    <td align="center"><img src="screenshots/Screenshot%202026-10-12%20144642.png" width="400"></td>
  </tr>
</table>

```text
flutter analyze  ->  No issues found!
flutter test     ->  +9: All tests passed!
```

### 8. Analisis Praktikum 1

**Apa yang dicapai.** Sesi login bertahan setelah aplikasi ditutup karena token dibaca ulang dari secure storage saat aplikasi dibuka. GoRouter memakai status itu untuk mengarahkan pengguna, dan pemulihan sesi dilakukan sebelum UI tampil sehingga halaman login tidak berkedip bagi pengguna yang sudah masuk.

**Keputusan teknis.**

- **Secure storage, bukan SharedPreferences.** SharedPreferences tidak terenkripsi, sedangkan token adalah kredensial. Seluruh akses dipusatkan di `TokenStore` agar mudah diuji dengan penyimpanan palsu.
- **Penjaga `retried` pada interceptor.** Tanpa penjaga, request yang tetap 401 setelah refresh akan memicu refresh lagi tanpa henti. Ini dibuktikan dengan test "tetap 401 setelah refresh" yang memastikan hanya ada dua panggilan (awal dan satu ulang).
- **Gagal refresh dan gagal ulang diperlakukan berbeda.** Versi jobsheet memakai satu `catch` untuk keduanya, sehingga server yang sedang error (500) ikut menghapus sesi padahal refresh berhasil. Pada implementasi ini hanya kegagalan refresh yang menghapus token.
- **Tidak memakai `LogInterceptor`**, karena header `Authorization` akan tercetak ke log.

**Kendala.** Build Android gagal dengan pesan `Unexpected lock protocol found in lock file` pada proyek `:jni` serta peringatan AGP 9. Masalah teratasi dengan menambahkan `android.newDsl=false` dan `android.builtInKotlin=false` pada `android/gradle.properties`.

**Keterbatasan.** Backend belum ada, sehingga login memakai repository mock dan refresh token diuji lewat server palsu, bukan server nyata. Token mock bukan JWT sungguhan, dan pada produksi verifikasinya dilakukan server.

</blockquote>
</details>

<br>

<details>
<summary><h3>4. Praktikum 2: FCM, Permission, dan Token Lifecycle</h3></summary>
<br>
<blockquote>

## Tujuan Praktikum

Menambahkan Firebase Cloud Messaging: mendaftarkan aplikasi ke Firebase, meminta izin notifikasi runtime, mengambil FCM registration token, memantau `onTokenRefresh`, lalu menguji pengiriman dari Firebase Console.

**File:** `lib/messaging/push_service.dart`, `lib/providers/push_provider.dart`, `lib/pages/debug_page.dart`, `lib/main.dart`

## Menyiapkan Firebase (tidak disertakan di repositori)

Folder `android/` dan `google-services.json` diabaikan git, jadi langkah berikut perlu diulang untuk menjalankan Praktikum 2:

1. Buat project di [Firebase Console](https://console.firebase.google.com/) (Analytics boleh dimatikan).
2. Tambahkan aplikasi Android dengan package name sama persis dengan `applicationId` (`com.example.campus_notify`).
3. Unduh `google-services.json` dan letakkan di `android/app/`.
4. `android/settings.gradle.kts`, di blok `plugins`:

```kotlin
   id("com.google.gms.google-services") version "4.4.2" apply false
```

5. `android/app/build.gradle.kts`, di blok `plugins` setelah `com.android.application`:

```kotlin
   id("com.google.gms.google-services")
```

6. `android/app/src/main/AndroidManifest.xml`, di dalam `<manifest>` sebelum `<application`:

```xml
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

7. Pastikan `await Firebase.initializeApp()` dipanggil sebelum `runApp` di `main.dart`.

Tanpa langkah 3 sampai 7, aplikasi akan berhenti saat dibuka karena Firebase belum terinisialisasi.

## 1. Pendaftaran Aplikasi ke Firebase

<p align="center">
  <img src="screenshots/Screenshot%202026-10-12%20163918.png" width="600"><br>
  <em>Project Firebase dan aplikasi Android terdaftar</em>
</p>

## 2. Permission, Token, dan Notification Service

`lib/messaging/push_service.dart` memanggil `requestPermission()`, mengambil token dengan `getToken()`, dan memantau `onTokenRefresh`. Callback `onToken` adalah titik sambung untuk mengirim token ke backend kampus lewat HTTPS. Backend belum tersedia pada codelab ini, sehingga token ditampilkan di halaman **Debug FCM** dalam bentuk tersamarkan. Token penuh tidak dicetak ke log dan tidak ditampilkan di layar.

<p align="center">
  <img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2020.04.57.jpeg" width="220"><br>
  <em>Dialog izin notifikasi (Android 13+)</em>
</p>

## 3. Token Lifecycle

```text
getToken()       -> token awal, dikirim ke backend lewat onToken
onTokenRefresh   -> token baru, perbarui di backend
reinstall / hapus data / rotasi keamanan -> token berubah
```

Contoh pengiriman ke backend (URL disesuaikan dengan API kampus):

```dart
await dio.post('/devices', data: {
  'fcm_token': token,
  'platform': 'android',
});
```

**Uji: hapus data aplikasi membuktikan token berubah.** Halaman Debug FCM dibuka dan token tersamarkan dicatat. Data aplikasi dihapus lewat pengaturan Android, aplikasi dibuka lagi, lalu token tersamarkan dicatat kembali.

<table>
  <tr>
    <th align="center">Token sebelum</th>
    <th align="center">Hapus data aplikasi</th>
    <th align="center">Token sesudah</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2020.10.55.jpeg" width="200"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2020.45.52.jpeg" width="200"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2020.45.52%20(1).jpeg" width="200"></td>
  </tr>
</table>

Token tersamarkan sebelum dan sesudah berbeda, sehingga token memang berganti setelah data dihapus dan aplikasi wajib mengirim token baru ke backend.

## 4. Uji Kirim dari Firebase Console

1. Firebase Console, **Messaging**, buat campaign notifikasi percobaan, isi `title` dan `body`.
2. **Foreground:** aplikasi terbuka, kirim pesan, lalu popup local notification muncul.
3. **Background:** tekan Home tanpa menutup aplikasi, kirim pesan, lalu banner sistem muncul di panel notifikasi.
4. Ketuk banner untuk menguji pembukaan aplikasi.

<table>
  <tr>
    <th align="center">Campaign Firebase Console</th>
    <th align="center">Popup foreground</th>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/Screenshot%202026-10-12%20192529.png" width="380"></td>
    <td align="center"><img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2020.10.55%20(1).jpeg" width="200"></td>
  </tr>
</table>

Popup foreground berasal dari `flutter_local_notifications`, karena FCM tidak menampilkan notifikasi otomatis saat aplikasi terbuka. Banner background ditampilkan Android langsung dari FCM.

### Tambahan: deeplink dari notifikasi (mendahului Praktikum 3)

Kode juga sudah menangani `data.route`, sehingga mengetuk notifikasi membuka halaman pengumuman. Ini bagian Praktikum 3, dan pengujian tiga state (foreground, background, terminated) akan dilaporkan lengkap di sana.

<p align="center">
  <img src="screenshots/WhatsApp%20Image%202026-10-12%20at%2020.10.55%20(2).jpeg" width="220"><br>
  <em>Notifikasi membuka halaman pengumuman sesuai <code>data.route</code></em>
</p>

## 5. Pengujian dan Verifikasi

Praktikum 2 bergantung pada Firebase dan perangkat fisik, sehingga diverifikasi lewat uji manual (screenshot di atas). Pengujian otomatis tetap lulus (`+9`, hasil sama dengan Praktikum 1) dan `flutter analyze` tetap `No issues found!`.

## 6. Analisis Praktikum 2

**Apa yang dicapai.** Aplikasi meminta izin notifikasi, mengambil registration token, dan menerima pesan dari Firebase Console baik saat terbuka maupun saat di background.

**Keputusan teknis dan temuan.**

- **Izin diminta saat runtime.** Android 13 ke atas mewajibkan izin `POST_NOTIFICATIONS`. Tanpa persetujuan pengguna, notifikasi tidak tampil.
- **Listener `onTokenRefresh` wajib ada.** Token berubah setelah hapus data atau instal ulang, dan screenshot sebelum dan sesudah membuktikannya. Tanpa listener, backend akan menyimpan token basi.
- **Foreground berbeda dari background.** Saat aplikasi terbuka, FCM tidak menampilkan banner, jadi aplikasi menampilkannya lewat notifikasi lokal. Saat background, Android menampilkannya otomatis.
- **Token tidak dibocorkan.** Layar hanya menampilkan token tersamarkan, dan tidak ada pencetakan token ke log.
- **Package name harus identik** dengan `applicationId` yang didaftarkan di Firebase, kalau tidak `google-services.json` tidak dikenali.

**Kendala.** Aplikasi tidak bisa dijalankan sampai plugin `google-services` dipasang di dua file Gradle dan `google-services.json` ditaruh di `android/app/`. Berkas itu berisi konfigurasi proyek Firebase, sehingga sengaja tidak di-push ke repositori publik.

**Keterbatasan.** Backend belum ada, jadi token tidak dikirim ke server nyata dan pengiriman pesan memakai Firebase Console. Pengujian dilakukan pada satu perangkat Android. iOS belum diuji karena membutuhkan `GoogleService-Info.plist` dan akun pengembang Apple.

</blockquote>
</details>
<br>

<details>
<summary><h3>5. Praktikum 3: Payload, Tiga App State, Klik, dan Topik</h3></summary>
<br>
<blockquote>

## Ringkasan

Praktikum ini menguji perilaku notifikasi Firebase Cloud Messaging (FCM) pada **tiga state aplikasi** (foreground, background, terminated), menerapkan **background handler top-level**, dan memproses **payload gabungan** (`notification` + `data`) untuk navigasi deep link via GoRouter.

## Konsep Payload

Payload yang dikirim backend (contoh JSON via FCM HTTP v1):

```json
{
  "message": {
    "topic": "pengumuman-kampus",
    "notification": {
      "title": "Judul kuliah berubah",
      "body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
    },
    "data": {
      "route": "/pengumuman/3",
      "id": "3"
    }
  }
}
```

**Perbedaan `notification` vs `data`:**

| Jenis | Isi | Perilaku Sistem |
|---|---|---|
| `notification` | title + body tampilan | Android menampilkan otomatis saat background/terminated; foreground butuh tampil manual |
| `data` | key-value bebas (mis. `route`, `id`) | Selalu diteruskan ke handler aplikasi; tidak ditampilkan otomatis |

**Aturan praktis:** gunakan `notification` untuk teks yang dibaca manusia, `data.route` untuk deep link tujuan klik.

## Implementasi

### 1. Background Handler Top-Level

Background handler **wajib fungsi top-level** (bukan method kelas) karena berjalan di isolate terpisah:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
```

### 2. Tiga Handler + Payload Gabungan

Kode utama di `lib/messaging/push_service.dart`:

- **`firebaseMessagingBackgroundHandler`** — handler background/terminated.
- **`initLocalNotifications`** — setup `flutter_local_notifications`.
- **`initializeMessageHandlers`** — daftar `onMessage`, `onMessageOpenedApp`, `getInitialMessage`.
- **`_routeFromMessage`** — ekstrak `data.route` dari payload.

Contoh handler foreground:

```dart
FirebaseMessaging.onMessage.listen((message) async {

  final route = message.data['route'] ?? '/';
  await _localNotifications.show(
    message.hashCode,
    message.notification?.title ?? 'Pengumuman',
    message.notification?.body ?? '',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'pengumuman',
        'Pengumuman Kampus',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    payload: route,
  );
});

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  go(message.data['route'] ?? '/');
});
```

### 3. Topic Messaging

```dart
await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
```

Berlangganan/berhenti dari kode:

```dart
await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
```

**Aturan topik:** nama tanpa spasi, gunakan untuk broadcast (semua mahasiswa, satu kelas, satu UKM). Untuk pesan personal (nilai, tagihan), gunakan **token perangkat**, bukan topik.

## Matriks Pengujian Wajib

Uji ketiga state dengan payload yang sama:

| State | Yang diharapkan | Cara Uji |
|---|---|---|
| **Foreground** | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari console/backend |
| **Background** | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik banner |
| **Terminated** | Aplikasi terbuka ke rute yang benar via `getInitialMessage` | Swipe-close aplikasi, kirim, klik banner |

## Hasil Pengujian

| Bukti Tampilan | Deskripsi |
| :---: | :--- |
| <img src="screenshots/WhatsApp Image 2026-10-13 at 05.44.58.jpeg" width="250"> | **Foreground** — notif lokal muncul di atas app, klik → halaman Pengumuman #3. |
| <img src="screenshots/WhatsApp Image 2026-10-13 at 05.45.19.jpeg" width="250"> | **Background** — banner sistem muncul di homescreen, klik → halaman Pengumuman #3. |
| <img src="screenshots/WhatsApp Image 2026-10-13 at 05.45.27.jpeg" width="250"> | **Terminated** — app terbuka dari notif, langsung ke halaman Pengumuman #3. |
| <img src="screenshots/image (1).png" width="250"> | **Notifikasi diterima dari Firebase Console** — payload dengan `data.route=/pengumuman/3`. |

## Verifikasi

```text
flutter analyze → No issues found!
flutter test    → +5: All tests passed!
```

**Kesimpulan:** ketiga state (foreground, background, terminated) berhasil diuji dengan payload gabungan (`notification` + `data.route`). Klik notifikasi mengarahkan ke `/pengumuman/3` sesuai payload.

</blockquote>
</details>

<br>

<details>
<summary><h3>6. AI Challenge</h3></summary>
<br>
<blockquote>


</blockquote>
</details>