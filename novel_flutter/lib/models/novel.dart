import 'genre.dart';

class Novel {
  final int id;
  final String title;
  final String author;
  final String cover;
  final String description;
  
  final int likesCount;
  final int viewCount;
  final String status;
  final bool isFavorited;
  final List<Genre> genres;
  

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.description,
    required this.genres,
    required this.likesCount,
    required this.viewCount,
    required this.isFavorited,
    required this.status,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',

      author: json['author'] is Map
          ? json['author']['name'] ?? ''
          : json['author'] ?? '',

      cover: json['cover'] ?? '',
      description: json['description'] ?? '',

      genres: (json['genres'] as List?)
              ?.map((e) => Genre.fromJson(e))
              .toList() ??
          [],


      likesCount: json['likes_count'] ?? 0,
      viewCount: json['views'] ?? 0,

      status: json['status'] is Map
          ? (json['status']['name'] ?? 'draft')
              .toString()
              .toLowerCase()
          : (json['status'] ?? 'draft')
              .toString()
              .toLowerCase(),

      // 🔥 INI YANG KAMU KETINGGALAN
      isFavorited: json['is_favorited'] ?? false,
    );
  }
}