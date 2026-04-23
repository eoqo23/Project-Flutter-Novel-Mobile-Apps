class Chapter {
  final int id;
  final int number;
  final String title;
  final String content;
  final int? likesCount;
  final int? viewCount;
  final int? commentCount;
  final int? nextId;
  final int? prevId;
  final int novelId;


  Chapter({
    required this.id,
    required this.number,
    required this.title,
    required this.content,
    required this.novelId,
    this.likesCount,
    this.viewCount,
    this.commentCount,
    this.nextId,
    this.prevId,
    
  });


  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] ?? 0,
      number: json['chapter_number'] ?? json['number'],
      novelId: json['novel_id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      likesCount: json['likes_count'],
      viewCount: json['view_count'],
      commentCount: json['comment_count'],
      nextId: json['next_id'],
      prevId: json['prev_id'],
    );
  }
}