# Review Checklist – Commit Message Hygiene

| Pesan Commit Sebelum (Salah) | Pesan Commit Sesudah (Benar) |
|------------------------------|------------------------------|
| `fix bug`                    | `fix(notes): cegah simpan judul kosong + test` |
| Tidak menyertakan *scope*    | Menyertakan scope `(notes)` untuk memperjelas area yang terdampak |
| Tidak mengikuti *Conventional Commits* | Menggunakan pola `<type>(<scope>): <description>` |
| Deskripsi singkat tidak informatif | Deskripsi singkat, jelas, dan ≤ 72 karakter |
| (Opsional) Tidak ada referensi issue/JIRA | (Opsional) Tambahkan `#<issue-number>` di akhir baris bila ada tiket terkait |

---

## Mid Review – Kesiapan Tengah Semester

| Kriteria | Status | Bukti |
|----------|--------|-------|
| Struktur *feature-first* terbukti | ✅ | `lib/features/auth/` terdiri dari `data/`, `domain/`, `presentation/` |
| `flutter analyze` bersih | ✅ | `No issues found` |
| `flutter test` hijau | ✅ | `28 tests passed` |
| PR kecil sudah di-merge via review | ✅ | PR `feat/notes-validation` → `develop` sudah di-merge |
| Commit mengikuti *Conventional Commits* | ✅ | Semua commit menggunakan format `<type>(<scope>): <desc>` |
| README + screenshot + cara menjalankan | ✅ | Tersedia di `campus_notify/README.md` |
| CI/CD otomatis aktif | ✅ | `.github/workflows/ci.yml` dijalankan pada setiap PR |
| Semua komentar review ditindaklanjuti | ✅ | Perbaikan format kode selesai via `dart format` |

### Peta Branch & PR

```
main
└── develop
    ├── feat/notes-validation        → PR #5  (merged) – validasi judul kosong
    ├── feat/pr-peer-review          → PR #6  (merged) – peer review workflow
    └── feat/static-analysis-ci      → PR aktif – static analysis + CI workflow
```


---

## Mid Review – Kesiapan Tengah Semester

| Kriteria | Status | Bukti |
|----------|--------|-------|
| Struktur *feature-first* terbukti | ✅ | `lib/features/auth/` terdiri dari `data/`, `domain/`, `presentation/` |
| `flutter analyze` bersih | ✅ | `No issues found` |
| `flutter test` hijau | ✅ | `28 tests passed` |
| PR kecil sudah di-merge via review | ✅ | PR `feat/notes-validation` → `develop` sudah di-merge |
| Commit mengikuti *Conventional Commits* | ✅ | Semua commit menggunakan format `<type>(<scope>): <desc>` |
| README + screenshot + cara menjalankan | ✅ | Tersedia di `campus_notify/README.md` |
| CI/CD otomatis aktif | ✅ | `.github/workflows/ci.yml` dijalankan pada setiap PR |
| Semua komentar review ditindaklanjuti | ✅ | Perbaikan format kode selesai via `dart format` |

### Peta Branch & PR

```
main
└── develop
    ├── feat/notes-validation        → PR #5  (merged) – validasi judul kosong
    ├── feat/pr-peer-review          → PR #6  (merged) – peer review workflow
    └── feat/static-analysis-ci      → PR aktif – static analysis + CI workflow
```