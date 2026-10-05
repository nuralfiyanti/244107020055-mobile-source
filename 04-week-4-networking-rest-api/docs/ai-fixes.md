# Perbaikan yang Saya Lakukan

1. **Nama package di import test salah.** AI memakai `week4_api`, padahal nama package di `pubspec.yaml` adalah `week4_networking`. Saya ganti importnya. `flutter analyze` sebelumnya menampilkan 6 error, semuanya turunan dari import ini.
2. **Menghapus `test/widget_test.dart` bawaan template.** Test itu menguji aplikasi counter yang sudah tidak ada dan memicu request jaringan sungguhan, sehingga gagal.
3. **Edge case tambahan (buatan sendiri):** test untuk field bernilai `null` dan JSON kosong `{}`.

## Temuan dari verifikasi
- Timeout 10 detik ditulis di dua tempat: default di `createDio()` dan per-request di `fetchComments`. Sebaiknya terpusat di satu tempat.
- `fromJson` aman terhadap null/field hilang, tapi masih bisa crash kalau tipe salah (misalnya `id` berupa string `"5"`).
- `CommentRepository` dan `commentsProvider` belum dipakai UI, hanya diuji lewat unit test.