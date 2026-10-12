## Jobsheet 6: Authentication, Security, dan FCM

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

----

## Struktur Project
- `lib/` : kode aplikasi
- `lib/data/` : token store, repository auth, dan API client
- `lib/providers/` : state authentication dengan Riverpod
- `lib/pages/` : halaman login, home, dan pengumuman
- `test/` : unit test token, auth provider, dan refresh token
- `docs/` : dokumentasi tambahan
- `screenshots/` : tangkapan layar hasil praktikum

## Cara Menjalankan
```bash
flutter pub get
flutter run
```
----

## LAPORAN PRAKTIKUM WEEK06

<details>
<summary><h3>2. Konsep Authentication, Security, dan FCM</h3></summary>
<br>
<blockquote>

## 1. Model Authentication yang Dipakai

Ada tiga pola authentication yang umum digunakan pada aplikasi mobile:

| Pola | Cara kerja singkat | Kapan dipakai |
|---|---|---|
| Firebase Auth | Firebase mengelola credential dan menghasilkan ID token yang diverifikasi backend | Login email, Google, atau provider lain tanpa membangun auth server sendiri |
| JWT + refresh token | Server menerbitkan access token berumur pendek dan refresh token berumur panjang | Backend kampus atau REST API milik sendiri |
| OAuth | Aplikasi menerima authorization code dari provider lalu menukarnya menjadi token | Login sosial atau SSO kampus |

Implementasi codelab ini memakai mock auth provider dan JWT simulasi agar dapat berjalan tanpa backend. Pola repository dan token dibuat menyerupai pola production sehingga provider dapat dimigrasikan ke Firebase Auth atau backend kampus.

---

## 2. ID Token, Access Token, dan Refresh Token

- **ID token** adalah bukti identitas pengguna. Backend memverifikasinya untuk request yang membutuhkan identitas.
- **Access token** adalah izin akses berumur pendek dan biasanya dikirim sebagai `Authorization: Bearer <token>`.
- **Refresh token** adalah tiket berumur panjang untuk meminta access token baru tanpa login ulang. Token ini hanya disimpan di secure storage.

Alur token yang digunakan dalam konsep ini:

```text
Login -> access token berumur pendek + refresh token berumur panjang
Request API -> Authorization: Bearer access-token
401 expired -> refresh token -> access token baru -> ulangi request satu kali
Refresh gagal -> hapus token -> kembali ke halaman login
```

---

## 3. Arsitektur Firebase Cloud Messaging

Arsitektur FCM terdiri dari:

```text
App Server (backend) -> Firebase Cloud Messaging
FCM -> perangkat Android / iOS
Aplikasi -> mendaftarkan token perangkat dan mengirimkannya ke backend
```

Alur wajibnya adalah aplikasi meminta izin notifikasi, aplikasi mengambil registration token melalui `FirebaseMessaging.instance.getToken()`, token disimpan di backend per user, lalu backend memanggil FCM API untuk mengirim pesan ke token atau topic tertentu.

Bagian FCM ini menjadi konsep untuk praktikum berikutnya. Implementasi pada proyek saat ini masih berfokus pada authentication dan secure token storage.

---

## 4. Notification Payload dan Data Payload

| Jenis | Isi | Perilaku sistem |
|---|---|---|
| `notification` | `title` dan `body` untuk tampilan | Android dapat menampilkan otomatis saat background atau terminated; saat foreground biasanya ditampilkan manual |
| `data` | Key-value bebas, misalnya `route: /pengumuman/3` | Diteruskan ke handler aplikasi dan tidak otomatis ditampilkan sebagai notifikasi |

Prinsip praktis Campus Notification App adalah mengirim gabungan `notification + data`: `notification` untuk teks yang dibaca pengguna dan `data.route` untuk tujuan deeplink saat notifikasi diklik.

---

## 5. Tiga State Aplikasi yang Wajib Diuji

| State | Arti | Handler yang bekerja |
|---|---|---|
| Foreground | Aplikasi sedang terbuka | `FirebaseMessaging.onMessage`, lalu tampilkan local notification secara manual |
| Background | Aplikasi diminimalkan | Banner sistem otomatis dan `onMessageOpenedApp` saat banner diklik |
| Terminated | Aplikasi tidak aktif | `getInitialMessage()` saat aplikasi dibuka dari notifikasi |

</blockquote>
</details>


<details>
<summary><h3>3. Praktikum 1: Login, Secure Storage, dan Token Refresh</h3></summary>
<br>
<blockquote>

## Tujuan Praktikum

Praktikum ini membangun fondasi authentication aplikasi mobile menggunakan:

- login dengan mock auth provider yang dapat diganti dengan Firebase Auth;
- penyimpanan access token dan refresh token menggunakan `flutter_secure_storage`;
- state authentication menggunakan `flutter_riverpod`;
- route guard menggunakan `go_router`;
- interceptor Dio untuk mengirim access token dan melakukan refresh otomatis saat menerima HTTP 401.

Implementasi ini baru menggunakan repository mock agar dapat dijalankan tanpa backend. Struktur repository dan token tetap dibuat menyerupai pola yang akan dipakai ketika Firebase Auth atau backend kampus ditambahkan.

---

## Langkah Praktikum beserta Bukti Screenshot

### 1. Setup Project

Dependency yang digunakan:

```powershell
flutter pub add flutter_riverpod go_router dio flutter_secure_storage
flutter pub add firebase_core firebase_messaging flutter_local_notifications
```

Struktur folder yang digunakan:

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

Konfigurasi `flutter_local_notifications` membutuhkan core library desugaring pada Android. Konfigurasi tersebut berada di `android/app/build.gradle.kts`.

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

`TokenStore` menjadi satu-satunya pintu untuk menyimpan dan membaca token. Access token disimpan dengan key `access_token`, sedangkan refresh token disimpan dengan key `refresh_token`.

Token tidak disimpan di `SharedPreferences`, tidak ditulis langsung ke source code, dan tidak dicetak ke log. Package `flutter_secure_storage` menggunakan secure storage platform, yaitu Keystore pada Android dan Keychain pada iOS.

Operasi yang tersedia:

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

---

### 3. Repository Authentication Mock (`lib/data/auth_repository.dart`)

`AuthRepository` menyediakan simulasi login dan refresh token:

- login berhasil jika email memiliki karakter `@` dan password minimal 6 karakter;
- login mengembalikan pasangan access token dan refresh token mock;
- refresh token menghasilkan access token baru;
- refresh token kosong menghasilkan error.

Pada implementasi nyata, method `login` dapat diganti dengan Firebase Auth tanpa mengubah kontrak provider dan token store.

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

---

### 4. Provider Authentication dan Route Guard (`lib/providers/auth_provider.dart`)

`AuthNotifier` mengelola status login sebagai `AsyncValue<bool>`:

- saat aplikasi dibuka, provider membaca access token dari secure storage;
- `login` memanggil repository lalu menyimpan token;
- `logout` menghapus token dan menginvalidasi state;
- error login diteruskan ke UI sebagai error state.

File: `lib/main.dart`

GoRouter melindungi route aplikasi:

| Kondisi | Perilaku |
|---|---|
| Belum login membuka route selain `/login` | Diarahkan ke `/login` |
| Sudah login membuka `/login` | Diarahkan ke `/` |
| Sudah login membuka `/` | Menampilkan `HomePage` |
| Belum login saat aplikasi dimulai | Sesi dipulihkan sebelum UI tampil |

```dart
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final authRepositoryProvider = Provider<AuthRepository>(
	(ref) => AuthRepository(),
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
			final session = await ref.read(authRepositoryProvider).login(
						email: email,
						password: password,
					);
			await ref.read(tokenStoreProvider).save(
						access: session.access,
						refresh: session.refresh,
					);
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

### 5. Dio dengan Refresh Token Otomatis (`lib/data/api_client.dart`)

Interceptor Dio menjalankan alur berikut:

1. Membaca access token dari `TokenStore` sebelum request.
2. Menambahkan header `Authorization: Bearer <access-token>`.
3. Jika response berstatus 401, membaca refresh token.
4. Meminta access token baru melalui `AuthRepository.refresh`.
5. Menyimpan token baru dan mengulangi request satu kali.
6. Jika refresh gagal, menghapus token agar pengguna login ulang.

Flag `retried` pada `RequestOptions.extra` mencegah request berulang tanpa batas ketika token baru tetap ditolak server.

Base URL saat ini adalah URL placeholder `https://example-campus-api.test`. URL tersebut hanya digunakan untuk menunjukkan konfigurasi client. Login pada Praktikum 1 tetap berjalan melalui mock repository.

Bagian inti interceptor menandai request yang sudah diulang agar tidak terjadi infinite loop:

```dart
onError: (e, handler) async {
	final is401 = e.response?.statusCode == 401;
	final alreadyRetried = e.requestOptions.extra['retried'] == true;
	if (!is401 || alreadyRetried) return handler.next(e);

	final refresh = await store.readRefresh();
	if (refresh == null) return handler.next(e);

	try {
		final renewed = await auth.refresh(refresh);
		await store.save(access: renewed, refresh: refresh);
		final request = e.requestOptions
			..headers['Authorization'] = 'Bearer $renewed'
			..extra['retried'] = true;
		return handler.resolve(await dio.fetch<dynamic>(request));
	} catch (_) {
		await store.clear();
		return handler.next(e);
	}
}
```

---

### 6. Tampilan dan Pengujian Manual pada HP

Halaman yang tersedia:

- `LoginPage`: input email, password, loading state, dan pesan error.
- `HomePage`: menampilkan status sesi aktif, tombol logout, dan daftar pengumuman contoh.
- `AnnouncementPage`: halaman tujuan deeplink pengumuman dengan parameter id.

Skenario manual yang diuji pada perangkat Android:

#### Bukti yang Dicantumkan dari `flutter run` pada HP

| Bukti Tampilan | Deskripsi |
| :---: | :--- |
| ![Hasil flutter analyze](<screenshots/Screenshot 2026-10-12 144612.png>) | **`flutter analyze`** — No issues found! |
| ![Hasil flutter test](<screenshots/Screenshot 2026-10-12 144642.png>) | **`flutter test`** — +9: All tests passed! |
| ![Login gagal](<screenshots/WhatsApp Image 2026-10-12 at 13.55.00.jpeg>) | Login dengan data tidak valid menampilkan pesan error. |
| ![Form login](<screenshots/WhatsApp Image 2026-10-12 at 13.55.01.jpeg>) | Halaman login sebelum pengguna memasukkan data. |
| ![Halaman utama](<screenshots/WhatsApp Image 2026-10-12 at 15.31.13.jpeg>) | Login valid menampilkan halaman utama Campus Notify dan status sesi aktif. |
| ![Halaman pengumuman](<screenshots/WhatsApp Image 2026-10-12 at 15.34.32.jpeg>) | Menekan item pengumuman membuka halaman detail **Pengumuman 1**. |
| ![Logout kembali ke login](<screenshots/WhatsApp Image 2026-10-12 at 15.31.13 - Copy.jpeg>) | Setelah menekan ikon panah kanan atas, logout menghapus sesi dan kembali ke halaman login. |

---

### 7. Pengujian Otomatis

File: `test/auth_test.dart`

Test mencakup penyimpanan token, empat skenario refresh 401, kondisi awal belum login, login berhasil, login gagal, dan logout.

Perintah verifikasi:

```bash
flutter analyze
flutter test
```

Hasil verifikasi:

```text
flutter analyze
No issues found!

flutter test
00:18 +9: All tests passed!
```

---

</blockquote>
</details>

<br>

<details>
<summary><h3>4. Praktikum 2: FCM, permission, dan token lifecycle</h3></summary>
<br>
<blockquote>

## Tujuan Praktikum

Praktikum 2 menambahkan Firebase Cloud Messaging (FCM) untuk menerima pengumuman kampus melalui permission notifikasi, token perangkat, notifikasi foreground, background handler, dan deeplink `data.route`.

## Perintah Terminal dan Waktu Menjalankannya

Jalankan perintah dari folder project, bukan dari root repository:

```powershell
Set-Location '06-week-6-authentication-security-fcm/campus_notify'
```

Urutan validasi laporan:

```powershell
Set-Location '06-week-6-authentication-security-fcm/campus_notify'
flutter pub get
flutter analyze
flutter test
flutter run
```

Jalankan `flutter pub get` setiap kali dependency berubah. Jalankan `flutter analyze` dan `flutter test` setelah setiap tahap kode selesai. Jalankan `flutter run` ketika mengambil bukti tampilan di HP.

## 1. Daftarkan Aplikasi ke Firebase

1. Buat project di [Firebase Console](https://console.firebase.google.com/).
2. Tambahkan aplikasi Android dengan package name sesuai `applicationId`.
3. Unduh `google-services.json` ke `android/app/`.
4. Untuk iOS, tambahkan `GoogleService-Info.plist` ke Runner.
5. Jalankan `flutter pub get` setelah dependency siap.

---

## 2. Permission, Token, dan Notification Service

Implementasi berada di `lib/messaging/push_service.dart`, `lib/providers/push_provider.dart`, dan `lib/pages/debug_page.dart`. Service ini memanggil `requestPermission()`, mengambil token dengan `getToken()`, memantau `onTokenRefresh`, berlangganan topik `pengumuman-kampus`, menampilkan pesan foreground sebagai local notification, memproses `data.route`, dan menangani pesan background atau terminated.

Inisialisasi service dilakukan di `lib/main.dart` setelah sesi login dipulihkan. Callback `onToken` dapat digunakan untuk mengirim token ke backend kampus melalui HTTPS. Token tidak dicetak ke log.

---

## 3. Token Lifecycle

```text
FirebaseMessaging.getToken() -> kirim token ke backend kampus
onTokenRefresh -> perbarui token di backend
reinstall / hapus data / rotasi keamanan -> token baru
```

Contoh pengiriman token ke backend, dengan URL disesuaikan dengan API kampus:

```dart
await dio.post('/devices', data: {
	'fcm_token': token,
	'platform': 'android',
});
```

Jangan menampilkan token penuh dalam screenshot. Tampilkan bentuk tersamarkan seperti `abc123...xyz789`.

### Uji Reinstall/Clear Data Membuktikan Token Berubah

Pengujian dilakukan dengan membuka halaman **Debug FCM**, mencatat token yang sudah tersamarkan, menghapus data aplikasi atau melakukan reinstall, lalu membuka aplikasi kembali dan mencatat token baru.

| ![Token sebelum clear data](<screenshots/WhatsApp Image 2026-10-12 at 20.10.55.jpeg>) | Token tersamarkan sebelum data aplikasi dihapus. |
| ![Token setelah clear data](<screenshots/WhatsApp Image 2026-10-12 at 20.45.52 (1).jpeg>) | Token tersamarkan setelah data aplikasi dihapus dan berubah. |

---

## 4. Uji Kirim dari Firebase Console

1. Buka Firebase Console > Messaging dan buat campaign notifikasi percobaan.
2. Masukkan `title` dan `body`, lalu pilih aplikasi Android.
3. **Uji foreground:** biarkan halaman Campus Notify tetap terbuka, kirim pesan, lalu pastikan popup local notification muncul di HP.
4. **Uji background:** tekan tombol Home tanpa menutup aplikasi dari recent apps, kirim pesan, lalu pastikan banner muncul di panel notifikasi Android.
5. Ketuk banner untuk menguji pembukaan aplikasi dan deeplink.

Popup foreground berasal dari `showForegroundNotification()` dan `flutter_local_notifications`. Banner background berasal dari Firebase Messaging Android. Keduanya harus dibuktikan dengan screenshot terpisah.

----

## Bukti Tampilan

| Nama file bukti | Keterangan |
|---|---|
| ![Project Firebase](<screenshots/Screenshot 2026-10-12 163918.png>) | Project Firebase dan aplikasi Android sudah terdaftar. |
| ![Izin notifikasi](<screenshots/WhatsApp Image 2026-10-12 at 20.04.57.jpeg>) | Dialog izin notifikasi Android 13+ atau iOS. |
| ![Token sebelum clear data](<screenshots/WhatsApp Image 2026-10-12 at 20.10.55.jpeg>) | Token perangkat tersamarkan sebelum data aplikasi dihapus. |
| ![Token setelah clear data](<screenshots/WhatsApp Image 2026-10-12 at 20.45.52 (1).jpeg>) | Token perangkat tersamarkan setelah data aplikasi dihapus dan berubah. |
| ![Clear data aplikasi](<screenshots/WhatsApp Image 2026-10-12 at 20.45.52.jpeg>) | Halaman pengaturan Android untuk menghapus data aplikasi. |
| ![Campaign Firebase](<screenshots/Screenshot 2026-10-12 192529.png>) | Form campaign Firebase Console berisi title dan body. |
| ![Popup foreground](<screenshots/WhatsApp Image 2026-10-12 at 20.10.55 (1).jpeg>) | Popup local notification tampil saat aplikasi terbuka. |
| ![Deeplink pengumuman](<screenshots/WhatsApp Image 2026-10-12 at 20.10.55 (2).jpeg>) | Notifikasi membuka halaman pengumuman sesuai `data.route`. |

---

### 7. Pengujian Otomatis

File: `test/auth_test.dart`

Test mencakup penyimpanan token, empat skenario refresh 401, kondisi awal belum login, login berhasil, login gagal, dan logout.

Perintah verifikasi:

```bash
flutter analyze
flutter test
```

Hasil verifikasi:

```text
flutter analyze
No issues found!

flutter test
00:18 +9: All tests passed!
```

---

</blockquote>
</details>

<br>

<details>
<summary><h3>5. Praktikum 3: Payload, tiga app state, klik dan topik</h3></summary>
<br>
<blockquote>

