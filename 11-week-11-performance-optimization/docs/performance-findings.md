# Audit Temuan Performa — Week 11 (`campus_notify`)

Audit statis dilakukan terhadap seluruh kode di `11-week-11-performance-optimization/lib/` untuk mengidentifikasi *bottleneck* performa sebelum dilakukan optimasi.

---

## Ringkasan Temuan

| No | Kategori | Lokasi File & Baris | Masalah yang Ditemukan | Rencana Optimasi |
|---|---|---|---|---|
| 1 | **Widget Rebuild Berlebih** | `lib/features/notes/presentation/pages/notes_page.dart:31, 67, 76` | `build()` memanggil `ref.watch(notesListProvider)` pada root `Scaffold`, dan `TextField` memanggil `setState(() {})` di `onChanged` & tombol clear hanya untuk mengubah `suffixIcon`. Sub-widget juga belum diekstrak dengan `const`. | Gunakan `ValueListenableBuilder` untuk `suffixIcon`, lokalisasi `Consumer` pada daftar catatan, dan ekstrak `_NotesSearchBar`, `_NotesEmptyState`, `_NotesListView`, `_NoteTile` dengan `const`. |
| 2 | **Riverpod Rebuild Tanpa `.select()`** | `lib/features/auth/presentation/pages/login_page.dart:32-36` | `ref.watch(authStateProvider)` dipanggil di root `build()`, menyebabkan seluruh form dan kedua `TextField` ikut rebuild saat `isLoading` atau `error` berubah. | Gunakan `Consumer` dengan `ref.watch(authStateProvider.select(...))` khusus untuk pesan error dan tombol submit. |
| 3 | **Repaint & Rebuild pada Animasi** | `lib/features/chat_screen.dart:239, 265, 280, 352-540` | `_SecurityBanner()` belum `const`; `ref.watch(_chatProvider)` memicu rebuild seluruh `Scaffold`; serta animasi `_TypingIndicator` (`_DotsLoader`) dan `_MessageBubble` belum diisolasi dengan `RepaintBoundary`. | Tambahkan `const` pada `_SecurityBanner`, gunakan `select()` untuk `messages` & `isLoading`, dan bungkus `_TypingIndicator` serta `_MessageBubble` dengan `RepaintBoundary`. |
| 4 | **Lazy Loading & Item `const`** | `lib/features/auth/presentation/pages/home_page.dart:44-82` | Menggunakan `ListView(children: [...])` dengan loop `for` inline dan `Navigator.push(..., NotesPage())` tanpa `const`. | Gunakan `ListView.builder` untuk daftar pengumuman, ekstrak `_AnnouncementTile` dengan `const` constructor, dan gunakan `const NotesPage()`. |
| 5 | **Caching Jaringan, Repository & Gambar** | `lib/features/notes/data/repositories/notes_repository_impl.dart:30-46`, `lib/data/api_client.dart:15-51`, `lib/pages/announcement_page.dart:3-15` | Pencarian catatan mengulang filter untuk query yang sama; `Dio` belum memiliki cache respons `GET`; dan `AnnouncementPage` belum menggunakan `CachedNetworkImage` dengan `memCacheWidth`/`memCacheHeight`. | Tambahkan cache hasil pencarian in-memory di `NotesRepositoryImpl`, interceptor cache TTL untuk `GET` di `api_client.dart`, dan `CachedNetworkImage` dengan batasan `memCacheWidth`/`memCacheHeight` di `AnnouncementPage`. |

