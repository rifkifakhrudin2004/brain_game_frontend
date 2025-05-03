class Materi {
  final int id;
  final String title;
  final String content;

  Materi({
    required this.id,
    required this.title,
    required this.content,
  });

  factory Materi.fromJson(Map<String, dynamic> json) {
    return Materi(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }
}
