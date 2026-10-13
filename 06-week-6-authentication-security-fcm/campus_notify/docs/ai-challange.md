# AI Challenge — Week 6 Authentication, Security & FCM

## 1. Prompt yang Digunakan

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.

Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

**Catatan kebijakan:** sesuai kebijakan AI Minggu 6, AI diizinkan membuat implementasi awal FCM, **dengan syarat** token lifecycle, jenis payload, dan perilaku tiga app state **wajib diverifikasi manual**.

---

## 2. Output Awal AI

### 2.1 Struktur `PushService` yang Diusulkan AI

```dart
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  PushService(this._dio);
  final Dio _dio;
  final _local = FlutterLocalNotificationsPlugin();

  Future<void> backgroundHandler(RemoteMessage message) async {
    print('Background message: ${message.data}');
  }

  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> init() async {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
    await _dio.post('/devices', data: {'fcm_token': token});

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToRoute(message.data['route']);
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateToRoute(initialMessage.data['route']);
    }
  }

  void _navigateToRoute(String? route) {
    // Navigasi ditangani oleh GoRouter di main.dart.
  }

  Future<void> subscribeTopic() async {
    await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
  }

  Future<void> unsubscribeTopic() async {
    await FirebaseMessaging.instance.unsubscribeFromTopic('pengumuman-kampus');
  }
}
```

### 2.2 Catatan Output Awal AI

- `backgroundHandler` ditulis sebagai **method kelas**, bukan fungsi top-level.
- Tidak ada `@pragma('vm:entry-point')`.
- Tidak ada handler `FirebaseMessaging.onMessage` untuk foreground.
- `onTokenRefresh` hanya `print()`, tidak dikirim ke backend.
- `_navigateToRoute()` **kosong** — hanya komentar.
- Token FCM **dicetak penuh** ke log.

---

## 3. Verifikasi Menggunakan AI Verification Checklist

| Poin Checklist | Hasil Verifikasi |
|---|---|
| Background handler berupa fungsi top-level dengan `@pragma('vm:entry-point')`? | ❌ **Gagal di output AI** — method kelas, tanpa `@pragma`. ✅ **Diperbaiki** di `push_service.dart` menjadi fungsi top-level + `@pragma('vm:entry-point')`. |
| `onTokenRefresh` benar-benar mengirim token baru ke backend? | ❌ **Gagal di output AI** — hanya `print()`. ✅ **Diperbaiki** — `initFcmToken()` meneruskan token baru ke callback `onToken` yang sama. |
| Foreground memakai local notification manual? | ❌ **Gagal di output AI** — tidak ada handler `onMessage`. ✅ **Diperbaiki** — `showForegroundNotification()` menampilkan local notification via `flutter_local_notifications`. Terbukti di Praktikum 3. |
| Klik dari ketiga state masuk ke rute yang benar? | ❌ **Tidak dapat dibuktikan di output AI** — `_navigateToRoute()` kosong. ✅ **Diperbaiki** — `onRoute` callback memanggil `router.go(route)` di `main.dart`. Terbukti di 3 state. |
| Token/secret tidak di-hardcode dan tidak di-log penuh? | ❌ **Gagal di output AI** — `print('FCM Token: $token')`. ✅ **Diperbaiki** — `maskToken()` memotong token jadi 12 karakter + `...`. |
| Penanda perbedaan Android 13+ vs iOS, dan larangan akses BuildContext? | ❌ **Tidak dipenuhi di output AI**. ✅ **Diperbaiki** — komentar eksplisit di `firebaseMessagingBackgroundHandler`. |

**Ringkasan:** dari 6 poin checklist, **5 poin gagal total** dan **1 poin tidak dapat dibuktikan** pada output awal AI. Semua poin **diperbaiki** di implementasi manual.

---

## 4. Perbandingan dengan Implementasi Manual

| Masalah pada Draf AI | Implementasi Manual yang Benar |
|---|---|
| `backgroundHandler` method kelas, tanpa `@pragma` | `firebaseMessagingBackgroundHandler` di `lib/messaging/push_service.dart` adalah **fungsi top-level** dengan `@pragma('vm:entry-point')`, didaftarkan lewat `FirebaseMessaging.onBackgroundMessage()`. |
| `onTokenRefresh` hanya `print()` | `initFcmToken()` meneruskan token baru ke callback `onToken` yang sama dengan token awal, dipotong 12 karakter, siap diteruskan ke endpoint backend (ditandai komentar TODO di `main.dart`). |
| Tidak ada `onMessage` / local notification manual | `showForegroundNotification()` menangani `FirebaseMessaging.onMessage` dan menampilkan local notification lewat `_localNotifications.show(...)`. Terbukti bekerja pada uji foreground (Praktikum 3). |
| `_navigateToRoute()` kosong | `onRoute` callback di `initializeMessageHandlers` memakai `router.go(route)` secara nyata — dipakai konsisten oleh `onMessageOpenedApp`, `getInitialMessage`, maupun `onDidReceiveNotificationResponse`. Terbukti berhasil di ketiga uji app state. |
| `print('FCM Token: $token')` mencetak token penuh | Token dipotong (`substring(0, 12)`) sebelum disimpan ke state, sehingga token penuh tidak pernah ada di memori aplikasi maupun log. Dibuktikan lewat DebugPage pada Praktikum 2. |
| Tidak ada penanda Android 13+ vs iOS / larangan BuildContext | Komentar eksplisit `// Jangan akses BuildContext / Riverpod di sini` disertakan pada `firebaseMessagingBackgroundHandler`. |

---

## 5. Keputusan Final

**Diterima dari AI:**
- Struktur `PushService` dengan constructor injection (`messaging`, `notifications`) — memudahkan testing.
- `firebaseMessagingBackgroundHandler` — dipakai sebagai fungsi top-level.
- Tiga handler (`onMessage`, `onMessageOpenedApp`, `getInitialMessage`) — dipakai konsepnya.

**Dikoreksi dari AI:**
- **Token tidak disimpan di SharedPreferences** — pakai `flutter_secure_storage` (terenkripsi).
- **`LogInterceptor` dihapus** — mencetak `Authorization` header (token) ke log.
- **Urutan init Firebase diubah** — handler FCM diinit **setelah** `runApp`, agar GoRouter sudah aktif saat navigasi dipanggil.

---

## 6. Hasil Testing

```text
flutter analyze → No issues found!
flutter test    → +9: All tests passed!
```
**Bukti screenshot:**

| Bukti Tampilan | Deskripsi |
| :---: | :--- |
| <img src="../screenshots/image 2.png" width="400"> | `flutter analyze` — No issues found! & `flutter test` — +9: All tests passed! |

---

## 7. Refleksi

Sekilas draf `PushService` dari AI terlihat masuk akal karena semua nama method yang diminta prompt ada: `requestPermission`, `init`, `subscribeTopic`, dan seterusnya. Tapi begitu **isi tiap method diperiksa satu per satu** pakai checklist, ternyata banyak yang **kosong**, **salah pola** (dibuat method kelas, padahal seharusnya fungsi top-level), atau **melanggar prinsip keamanan** dasar seperti mencetak token penuh ke log.

Ini membuktikan apa yang sudah diingatkan di modul: **bug FCM yang paling merepotkan** (token basi, klik yang nyasar, notifikasi dobel) **tidak akan ketahuan hanya dengan membaca kode**. Draf ini kemungkinan besar akan lolos kalau cuma dicek sekilas, karena struktur dan nama methodnya meyakinkan, padahal begitu diuji langsung perilakunya di tiga app state, hasilnya jauh dari yang diharapkan.

**Pelajaran utama:**

1. **AI tidak tahu konteks project** — versi library, urutan init, constraint isolasi.
2. **Verifikasi lewat checklist wajib** — jangan cuma percaya struktur method.
3. **Prinsip keamanan** — token tidak boleh di-log penuh, tidak boleh di SharedPreferences.
4. **Uji manual di 3 state** (foreground, background, terminated) adalah **satu-satunya cara** membuktikan FCM bekerja.