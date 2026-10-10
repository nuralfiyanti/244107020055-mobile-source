# Jobsheet 5: Local Storage & Offline-First

**Nama:** Nur Alfiyanti <br>
**NIM:** 244107020055 - 17 <br>
**Kelas:** TI-3E <br>

---

## Struktur Project

- `lib/` : kode aplikasi (`data/`, `pages/`)
- `test/` : unit dan widget test
- `docs/` : dokumentasi AI Challenge
- `screenshots/` : tangkapan layar hasil

## Cara Menjalankan

```bash
flutter pub get
flutter run
```

---

## LAPORAN PRAKTIKUM WEEK05

<details>
<summary><h3>2. Konsep Local Storage dan Offline-First</h3></summary>
<br>
<blockquote>

## Ringkasan

**Local storage** adalah mekanisme menyimpan data **di perangkat** (bukan di server). Untuk aplikasi mobile, ada beberapa pilihan:

| Kebutuhan | Pilihan | Contoh |
|---|---|---|
| Pengaturan kecil key-value | `SharedPreferences` | tema gelap/terang, bahasa, waktu terakhir dibuka |
| Data terstruktur relasional | SQLite via `sqflite` | catatan, tugas, transaksi |
| NoSQL ringan embedded | Hive | cache objek, kotak (box) sederhana |
| Relasional reaktif & type-safe | Drift | aplikasi besar dengan query kompleks + stream |

Codelab ini memakai **`SharedPreferences` + SQLite (`sqflite`)** - kombinasi paling umum di industri untuk aplikasi offline notes.

### Offline-first, bukan offline-only

Offline-first berarti aplikasi **selalu bisa dibaca dan ditulis** meski tanpa internet, lalu **disinkronkan** saat koneksi kembali. Tiga mekanisme intinya:

1. **Cache-first read** - tampilkan data lokal seketika, lalu refresh dari jaringan di background dan simpan hasilnya.
2. **Dirty flag** - setiap perubahan lokal yang belum terkirim ditandai (`dirty = 1`) agar bisa di-sync belakangan.
3. **Antrean sinkronisasi** - operasi tertunda diproses berurutan saat online; konflik diselesaikan dengan aturan eksplisit (misalnya last-write-wins berdasarkan `updated_at`).

### Repository untuk data lokal

Aturan arsitektur yang sama seperti Minggu 4 tetap berlaku, hanya sumber datanya berubah:

- UI **tidak boleh** memanggil SQLite/SharedPreferences secara langsung.
- **Repository** adalah satu-satunya pintu ke database dan preferensi.
- **Provider Riverpod** mengekspos `AsyncValue` (loading/error/data) dan fungsi `invalidate` untuk refresh.

<br>

</blockquote>
</details>

<br>

<details>
<summary><h3>3. Praktikum 1: SharedPreferences</h3></summary>
<br>
<blockquote>

## Ringkasan

Praktikum ini membangun **repository preferences** menggunakan `SharedPreferences` untuk menyimpan pengaturan sederhana (dark mode, terakhir dibuka). Setiap key terpusat di `PrefsRepository`, tidak tersebar di widget.

---

## Langkah Praktikum beserta Bukti Screenshot

### 1. Setup Project

```powershell
flutter create 05-week-5-local-storage-offline-first --project-name week5_offline_notes
cd week5_offline_notes
flutter pub add flutter_riverpod shared_preferences sqflite path
```

**Hasil:** 32 dependency ter-install, termasuk `flutter_riverpod 3.4.3`, `shared_preferences 2.5.6`, `sqflite 2.4.4+1`, `path 1.9.1`.

Struktur folder: <br>
```text
lib/
├── main.dart
├── data/
│   ├── local/
│   │   ├── db.dart
│   │   └── note.dart
│   ├── prefs.dart
│   └── repositories/
│       └── note_repository.dart
└── pages/
    ├── settings_page.dart
    └── notes_page.dart
  ```

### 2. Repository Preferences (`lib/data/prefs.dart`)

Menyimpan key SharedPreferences terpusat di satu repository:

```dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsRepository {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> markOpenedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
  }

  Future<String?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastOpenedKey);
  }
}
```

### 3. Provider dan Halaman Pengaturan

`lib/data/providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}
```
`lib/pages/settings_page.dart` 

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: darkMode.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (isDark) => SwitchListTile(
          title: const Text('Dark Mode'),
          value: isDark,
          onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
        ),
      ),
    );
  }
}
```

Update `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/settings_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 5 - Offline Notes',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const SettingsPage(),
    );
  }
}
```

### 5. Verifikasi

| Bukti Tampilan | Deskripsi Antarmuka |
| :---: | :--- |
| ![flutter analyze](<screenshots/Screenshot 2026-10-10 025850.png>) | **`flutter analyze`** — No issues found! |
| ![flutter test](<screenshots/Screenshot 2026-10-10 025835.png>) | **`flutter test`** — +1: All tests passed! |

</blockquote>
</details>


<br>

<details>
<summary><h3>4. Praktikum 2: SQLite dan Repository Catatan</h3></summary>
<br>
<blockquote>

## Ringkasan

Praktikum ini membangun **model catatan** dan **repository SQLite** untuk operasi CRUD (Create, Read, Update, Delete). Setiap catatan memiliki flag `dirty` yang menandai apakah catatan sudah tersinkron dengan server.

Komponen utama:

1. **Model `Note`** - representasi catatan dengan konversi `toMap`/`fromMap`.
2. **Pembuka database** - fungsi `openNotesDb()` yang membuat 2 tabel: `notes` dan `cached_posts`.
3. **Repository `NoteRepository`** - satu-satunya pintu akses database, dengan constructor yang bisa menerima `openDb` untuk testing.

---

## Langkah Praktikum beserta Bukti Screenshot

### 1. Model Catatan (`lib/data/local/note.dart`)

```dart
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'updated_at': updatedAt.toIso8601String(),
        'dirty': dirty ? 1 : 0,
      };

  factory Note.fromMap(Map<String, Object?> map) {
    return Note(
      id: (map['id'] as num?)?.toInt(),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      dirty: ((map['dirty'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

```

Pembuka Database `lib/data/local/db.dart` <br>

```dart
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<Database> openNotesDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'offline_notes.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL DEFAULT '',
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE cached_posts(
          id INTEGER PRIMARY KEY,
          payload TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
    },
  );
}

```

Repository CRUD `lib/data/repositories/note_repository.dart` <br>

```dart
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}

```

 `lib/data/repositories/providers.dart` <br>

 ```dart
 import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'prefs.dart';
import 'local/note.dart';
import 'repositories/note_repository.dart';

// PREFERENCES
final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.watch(prefsRepositoryProvider).getDarkMode();
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

// NOTES
final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.fetchNotes();
});

final dirtyCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.countDirty();
});

```

 `lib/pages/notes_page.dart` <br>

 ``` dart
 import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyAsync = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(notesProvider);
              ref.invalidate(dirtyCountProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner dirty
          dirtyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (count) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: count > 0
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              child: Row(
                children: [
                  Icon(
                    count > 0 ? Icons.cloud_off : Icons.cloud_done,
                    color: count > 0 ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      count > 0
                          ? '$count catatan belum tersinkron'
                          : 'Semua catatan sudah tersinkron',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Daftar catatan
          Expanded(
            child: notesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(child: Text('Belum ada catatan.'));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final note = notes[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(note.id.toString()),
                        ),
                        title: Text(note.title),
                        subtitle: Row(
                          children: [
                            Icon(
                              note.dirty
                                  ? Icons.cloud_off
                                  : Icons.cloud_done,
                              size: 14,
                              color: note.dirty
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.dirty
                                  ? 'Belum tersinkron'
                                  : 'Sudah tersinkron',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final repo =
                                ref.read(noteRepositoryProvider);
                            await repo.deleteNote(note.id!);
                            ref.invalidate(notesProvider);
                            ref.invalidate(dirtyCountProvider);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final repo = ref.read(noteRepositoryProvider);
          await repo.addNote(
            title: 'Catatan ${DateTime.now().second}',
            body: 'deadline 1 minggu',
          );
          ref.invalidate(notesProvider);
          ref.invalidate(dirtyCountProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

```

`lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/providers.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Week 5 - Offline Notes',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: darkMode.value == true ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    NotesPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note),
            label: 'Catatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

```

### 5. Verifikasi dan Hasil

| Bukti Tampilan | Deskripsi Antarmuka |
| :---: | :--- |
| ![flutter analyze](<screenshots/Screenshot 2026-10-10 212301.png>) | **`flutter analyze`** — No issues found! |
| ![flutter test](<screenshots/Screenshot 2026-10-10 212311.png>) | **`flutter test`** — +1: All tests passed! |
| ![Dark Mode OFF](<screenshots/WhatsApp Image 2026-10-10 at 03.30.55.jpeg>) | **Pengaturan — Light**: toggle Dark Mode OFF, tema terang. |
| ![Dark Mode ON](<screenshots/WhatsApp Image 2026-10-10 at 21.12.59.jpeg>) | **Pengaturan — Dark**: toggle Dark Mode ON, tema gelap. |
| ![Catatan Offline](<screenshots/WhatsApp Image 2026-10-10 at 21.13.00.jpeg>) | **Catatan Offline**: daftar catatan dengan badge dirty, tombol hapus, dan FAB (+). |

</blockquote>
</details>

<br>

<details>
<summary><h3>5. Praktikum 3: Cache-first dan antrean sync</h3></summary>
<br>
<blockquote>

## Ringkasan

Praktikum ini menerapkan pola **offline-first**: data dari API ditampilkan **dari cache lokal dulu** (cache-first read), lalu refresh dari jaringan di background. Ditambah **antrean sinkronisasi** catatan dirty dengan simulasi server (delay), dan **toggle simulasi offline** untuk demo deterministik tanpa bergantung pada Wi-Fi.

Komponen utama:

1. **Dio client** (`lib/data/api_client.dart`) - konfigurasi base URL JSONPlaceholder, timeout, interceptor logging.
2. **Model `Post`** (`lib/data/models/post.dart`) - dipakai ulang dari Minggu 4.
3. **Sync logic** (`lib/data/sync.dart`) - `readCachedPosts`, `saveCachedPosts`, `PostsCacheNotifier`, `syncNotes`, dan `forceOfflineProvider`.
4. **Halaman Posts Cache** (`lib/pages/posts_page.dart`) - menampilkan cache posts + toggle offline.

### Tambah dio
![alt text](<screenshots/Screenshot 2026-10-10 214119.png>)

Buat file `lib/data/api_client.dart`

```dart
import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    LogInterceptor(requestBody: true, responseBody: false),
  );
  return dio;
}

```

Buat file `lib/data/models/post.dar`

```dart
class Post {
  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  final int userId;
  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'id': id,
        'title': title,
        'body': body,
      };
}

```
Buat file `lib/data/sync.dart`

```dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'api_client.dart';
import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';

// Dio Provider 
final dioProvider = Provider<Dio>((ref) => createDio());

// Cache Posts 
Future<List<Post>> readCachedPosts() async {
  final db = await openNotesDb();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows.map((row) {
    final payload = row['payload'] as String? ?? '{}';
    final json = Map<String, dynamic>.from(
      (payload.isEmpty ? {} : jsonDecode(payload)) as Map,
    );
    return Post.fromJson(json);
  }).toList();
}

Future<void> saveCachedPosts(List<Post> posts) async {
  final db = await openNotesDb();
  final batch = db.batch();
  for (final post in posts) {
    batch.insert(
      'cached_posts',
      {
        'id': post.id,
        'payload': jsonEncode(post.toJson()),
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  await batch.commit(noResult: true);
}

// Posts Cache Notifier 
class PostsCacheNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    return _loadCacheFirst();
  }

  Future<List<Post>> _loadCacheFirst() async {
    final cached = await readCachedPosts();
    unawaited(refreshPostsInBackground());
    return cached;
  }

  Future<void> refreshPostsInBackground() async {
    if (ref.read(forceOfflineProvider)) return;
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get<List>('/posts');
      final data = response.data ?? [];
      final posts = data
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList();
      await saveCachedPosts(posts);
      state = AsyncData(posts);
    } catch (_) {}
  }
}

final postsCacheProvider =
    AsyncNotifierProvider<PostsCacheNotifier, List<Post>>(
  PostsCacheNotifier.new,
  retry: (retryCount, error) => null,
);

// Sync Notes
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

// Force Offline Toggle 
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

```

Buat file `lib/pages/posts_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sync.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postsCacheProvider);
    final isOffline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts Cache'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(postsCacheProvider.notifier)
                  .refreshPostsInBackground();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle simulasi offline
          SwitchListTile(
            title: const Text('Simulasi Offline'),
            subtitle: Text(
              isOffline ? 'Aktif — tidak fetch jaringan' : 'Nonaktif',
            ),
            value: isOffline,
            onChanged: (_) =>
                ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          const Divider(height: 1),
          Expanded(
            child: postsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(
                    child: Text('Belum ada cache. Tekan refresh.'),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(post.id.toString()),
                      ),
                      title: Text(
                        post.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

```

Ganti isi `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/providers.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      title: 'Week 5 - Offline Notes',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: darkMode.value == true ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    NotesPage(),
    PostsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.note),
            label: 'Catatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'Posts Cache',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

```
tambhkan dan modifikasi `lib/pages/notes_page.dart`

```dart
import '../data/sync.dart';

                  if (count > 0)
                    TextButton(
                      onPressed: () async {
                        final repo = ref.read(noteRepositoryProvider);
                        final syncedCount = await syncNotes(repo);
                        ref.invalidate(notesProvider);
                        ref.invalidate(dirtyCountProvider);
                        if (context.mounted && syncedCount > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Semua catatan berhasil disinkronkan',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Sync'),
                    ),


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final title = await showDialog<String>(
            context: context,
            builder: (ctx) => const _AddNoteDialog(),
          );

          if (title != null && title.isNotEmpty && context.mounted) {
            final repo = ref.read(noteRepositoryProvider);
            await repo.addNote(title: title, body: 'deadline 1 minggu');
            ref.invalidate(notesProvider);
            ref.invalidate(dirtyCountProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
  
  class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan Baru'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Judul catatan'),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

```

### Verifikasi

| Bukti Tampilan | Deskripsi Antarmuka |
| :---: | :--- |
| ![alt text](<screenshots/Screenshot 2026-10-10 225547.png>) | **`flutter analyze`** — No issues found! |
| ![alt text](<screenshots/Screenshot 2026-10-10 225742.png>) | **`flutter test`** — +1: All tests passed! |

### Hasil

| Bukti Tampilan | Deskripsi Antarmuka |
| :---: | :--- |
| <img src="screenshots/WhatsApp Image 2026-10-10 at 23.03.48.jpeg" width="250"> | **Tambah Catatan** — dialog input judul catatan baru. |
| <img src="screenshots/WhatsApp Image 2026-10-10 at 23.03.46.jpeg" width="250"> | **Sebelum Sync** — badge dirty menampilkan jumlah catatan belum tersinkron. |
| <img src="screenshots/WhatsApp Image 2026-10-10 at 23.03.46 (1).jpeg" width="250"> | **Sesudah Sync** — badge kembali 0 (semua tersinkron), SnackBar muncul. |
| <img src="screenshots/WhatsApp Image 2026-10-10 at 23.03.44.jpeg" width="250"> | **Posts Cache (Offline OFF)** — daftar post dari cache/jaringan. |
| <img src="screenshots/WhatsApp Image 2026-10-10 at 23.03.45.jpeg" width="250"> | **Posts Cache (Offline ON)** — toggle "Simulasi Offline" aktif, posts tetap tampil dari cache (tidak fetch jaringan). |

</blockquote>
</details>

<br>

<details>
<summary><h3>6. AI Challenge</h3></summary>
<br>
<blockquote>








