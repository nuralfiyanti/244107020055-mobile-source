# Log Pengujian & Evaluasi Prompt AI — Week 10

> **Catatan Keamanan:** Tidak ada API Key atau token rahasia asli yang disimpan di dalam dokumen ini. Seluruh kredensial dikelola secara lokal di perangkat menggunakan `FlutterSecureStorage` (`ai_api_key`).

---

## 1. System Prompt

```text
Kamu asisten kampus ramah, jawab dalam Bahasa Indonesia, maksimal 2 kalimat.
```

---

## 2. Skenario Pengujian Prompt & Output AI

### Skenario 1 — Pertanyaan Akademik / Jadwal Kampus

- **User Prompt:**
  `Jadwal kuliah hari Senin dan info KRS dapat dilihat di mana?`
- **Output Awal AI:**
  `Jadwal kuliah hari Senin dan informasi pengisian KRS dapat Anda lihat melalui portal akademik mahasiswa. Jika mengalami kendala akses, silakan hubungi bagian administrasi akademik kampus.`
- **Catatan Validasi Output Sebelum Ditampilkan:**
  - Bahasa: Bahasa Indonesia yang sopan dan ramah (sesuai system prompt).
  - Panjang respons: 2 kalimat (memenuhi batas maksimal 2 kalimat).
  - Akurasi & keamanan: Tidak menyebut data fiktif/pribadi pengguna; aman untuk langsung ditampilkan dengan efek streaming di `ChatScreen`.

---

### Skenario 2 — Pertanyaan Umum Seputar Kampus

- **User Prompt:**
  `Jam operasional perpustakaan kampus biasanya buka jam berapa?`
- **Output Awal AI:**
  `Perpustakaan kampus umumnya beroperasi pada hari kerja mulai pukul 08.00 hingga 16.00 WIB. Untuk jadwal khusus saat minggu ujian, silakan cek pengumuman resmi di papan informasi atau portal kampus.`
- **Catatan Validasi Output Sebelum Ditampilkan:**
  - Bahasa & nada: Sesuai persona asisten kampus yang ramah.
  - Panjang respons: 2 kalimat.
  - Catatan aplikasi: Pertanyaan yang sama akan disimpan di cache in-memory (`Map<String, String>`) sehingga pemanggilan ulang tidak menghabiskan kuota token.

---

### Skenario 3 — Uji Coba Input Data Sensitif (Diblokir Validasi Privasi)

- **User Prompt:**
  `Tolong cek status saya dengan NIK 3507123456789012 dan nomor HP 081234567890.`
- **Output Awal AI:**
  *(Tidak dikirim ke Gemini API — diblokir di sisi klien oleh `_validatePrivacy()` pada `AiService`)*
  `Exception: Input mengandung nomor NIK. Jangan kirim data pribadi ke AI.`
- **Catatan Validasi Output Sebelum Ditampilkan:**
  - Permintaan dihentikan sebelum memanggil `http.post` sehingga data sensitif (NIK, nomor telepon, email, kata kunci `password`/`alamat`) tidak pernah keluar dari perangkat.
  - UI `ChatScreen` menangkap `Exception` melalui blok `try/catch` dan menampilkan `AlertDialog` ramah dengan opsi **Tutup** atau **Gunakan Jawaban Offline** (`addFallback()`).

