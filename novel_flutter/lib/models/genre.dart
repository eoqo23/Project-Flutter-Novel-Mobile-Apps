class Genre {
  final int id;
  final String name;
  final int novelId;

  Genre({required this.id, required this.name, required this.novelId});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      novelId: json['novel_id'],
    );
  }
}