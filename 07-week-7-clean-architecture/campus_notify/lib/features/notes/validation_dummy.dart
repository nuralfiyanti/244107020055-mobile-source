// validation_dummy.dart
// Contoh kode “dummy” untuk men‑demonstrasikan proses commit.

class NoteValidator {
  // Mengembalikan true bila judul tidak kosong dan panjangnya ≤ 50 karakter.
  bool isValidTitle(String title) {
    return title.isNotEmpty && title.length <= 50;
  }

  // Mengembalikan true bila isi tidak kosong.
  bool isValidContent(String content) {
    return content.isNotEmpty;
  }
}