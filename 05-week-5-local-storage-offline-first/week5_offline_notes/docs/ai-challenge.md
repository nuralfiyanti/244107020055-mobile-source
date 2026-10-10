# AI Challenge: Pilihan Storage untuk Offline Notes (Week 5)

## 1. Tujuan

AI digunakan untuk mengusulkan pilihan storage pada aplikasi Offline Notes (CRUD catatan + preferensi tema). Keputusan akhir tetap ditentukan sendiri berdasarkan perbandingan trade-off dan hasil praktikum 1 sampai 3.

## 2. Prompt yang Digunakan

```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## 3. Output Awal AI

### 3.1 Tabel perbandingan

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada query, hanya ambil per key | Terbatas, filter dan sort di memori | Penuh (`WHERE`, `ORDER BY`, `JOIN`) | Penuh (SQL), ditulis dengan API Dart |
| Kebutuhan relasi | Tidak mendukung | Tidak ada relasi native | `FOREIGN KEY` dan `JOIN` | Relasi dan join type-safe |
| Reaktivitas (stream) | Tidak ada | Ada (`box.watch()`) | Tidak ada, dibuat sendiri | Ada (`select(...).watch()`) |
| Type-safety | Hanya tipe primitif dan `List<String>` | Baik, dengan `TypeAdapter` | Rendah, hasil query berupa `Map` | Tinggi, kode di-generate |
| Boilerplate | Sangat kecil | Sedang | Sedang (SQL manual, mapping, migrasi manual) | Terbesar (`build_runner`, file `.g.dart`) |
| Kemudahan testing | Mudah | Cukup | Cukup, lewat repository palsu atau database in-memory | Mudah, ada database in-memory |

### 3.2 Rekomendasi final AI

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Preferensi tema | SharedPreferences | Satu nilai kecil (`dark_mode`), tanpa query dan tanpa skema, boilerplate hampir nol. |
| Catatan (CRUD) | sqflite (SQLite) | Koleksi yang tumbuh. Butuh `ORDER BY updated_at`, filter `dirty = 1` untuk antrean sync, dan update parsial. Drift unggul di stream dan type-safety, tetapi `build_runner` belum sebanding untuk aplikasi sekecil ini. |

### 3.3 Skema untuk 1000+ catatan

SQLite:

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty ON notes(dirty) WHERE dirty = 1;
```

Hive: satu `Box<Note>` bernama `notes` dengan kunci `id`, dan `Box` terpisah untuk pengaturan. Hive memuat isi box ke memori saat dibuka, jadi untuk koleksi besar sebaiknya memakai `LazyBox`.

SharedPreferences ditolak untuk catatan: 1000 catatan harus disimpan sebagai satu string JSON besar atau 1000 key, setiap perubahan membaca dan menulis ulang datanya, dan tidak ada query.

### 3.4 Trade-off ringkas

- SharedPreferences: paling sederhana, hanya cocok untuk pengaturan kecil.
- Hive: cepat dan tanpa SQL, tetapi tidak punya relasi dan query kuat.
- sqflite: fleksibel dan ringan, tetapi mapping, migrasi, dan reaktivitas ditangani manual.
- Drift: paling aman secara tipe dan reaktif, tetapi paling banyak setup.

## 4. Verifikasi (AI Verification Checklist)

| Poin checklist | Hasil | Temuan |
|---|---|---|
| AI menempatkan daftar catatan di SharedPreferences? | Lulus | Catatan diarahkan ke SQLite. SharedPreferences ditolak untuk koleksi. |
| Skema mendukung antrean sync, bukan hanya CRUD? | Sebagian | Kolom `dirty` dan `updated_at` cukup untuk upload create/update dan aturan last-write-wins. Penghapusan belum tertangani: `deleteNote` memakai `DELETE` langsung, sehingga baris hilang sebelum server tahu. Perlu soft delete (kolom `deleted`) atau tabel penghapusan tertunda. |
| Klaim "real-time" didukung stream? | Sebagian | Stream ada di Drift (`watch()`) dan Hive (`box.watch()`), tidak ada di sqflite. Pada praktikum ini tampilan diperbarui lewat `invalidate` provider (manual), bukan reaktif dari database. |
| Estimasi boilerplate masuk akal? | Belum terbukti | Perbandingan AI bersifat kualitatif. Yang sudah dicoba langsung hanya sqflite (`db.dart`, `note.dart`, repository) dan SharedPreferences (`prefs.dart`). Hive dan Drift belum dicoba, jadi tidak ada klaim ukuran boilerplate untuk keduanya. |
| Keputusan final | Lihat bagian 5 | |

## 5. Keputusan Final dan Perbaikan

**Keputusan:** SharedPreferences untuk preferensi tema, sqflite (SQLite) untuk catatan.

**Alasan teknis:**
- Preferensi hanya satu nilai boolean, jadi database relasional berlebihan.
- Catatan butuh urutan `updated_at`, filter `dirty = 1`, dan `UPDATE` massal (`markAllSynced`), semuanya wajar di SQL.
- Dibanding Drift, sqflite cukup untuk skala aplikasi ini dan tidak butuh `build_runner`. Konsekuensinya mapping `fromMap`/`toMap` dan refresh UI ditulis manual.

**Perbaikan dari hasil verifikasi:**
- Celah penghapusan pada antrean sync dicatat sebagai keterbatasan: `deleteNote` menghapus baris langsung. Usulan perbaikan: tambah kolom `deleted INTEGER NOT NULL DEFAULT 0`, ubah `deleteNote` menjadi `UPDATE ... SET deleted = 1, dirty = 1`, dan saring `deleted = 0` pada `fetchNotes`.
- Klaim "real-time" dikoreksi: refresh UI pada project ini lewat `invalidate`, bukan stream database.

**Aturan konflik:** last-write-wins berdasarkan `updated_at` (sesuai catatan pada Praktikum 3).

## 6. Hasil Testing

```powershell
flutter analyze
flutter test
```

Hasil `flutter analyze`:
No issues found! (ran in 5.2s)
![alt text](<../screenshots/Screenshot 2026-10-11 000421.png>)

Hasil `flutter test`:
+1: All tests passed!
![alt text](<../screenshots/Screenshot 2026-10-11 000513.png>)

## 7. Refleksi

AI membantu menyusun perbandingan dengan cepat, tetapi beberapa klaimnya belum bisa diterima begitu saja: soal stream di sqflite, celah penghapusan pada antrean sync, dan estimasi boilerplate yang tidak diuji. Nilai tugas ini ada pada verifikasi terhadap kode praktikum yang benar-benar dijalankan, bukan pada tabel yang dihasilkan AI.