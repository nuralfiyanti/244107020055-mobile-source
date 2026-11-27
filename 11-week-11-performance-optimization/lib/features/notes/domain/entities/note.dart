/// Entity bisnis murni untuk Note — bebas dari framework Flutter/UI/database.
class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
}