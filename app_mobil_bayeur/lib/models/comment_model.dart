class Comment {
  final String id;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String content;
  final int rating; // Optional star rating for the property
  final int likes;
  final int dislikes;
  final String? parentId; // For threaded replies
  final List<Comment> replies;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.content,
    required this.rating,
    this.likes = 0,
    this.dislikes = 0,
    this.parentId,
    this.replies = const [],
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      username: json['username'] ?? 'Utilisateur',
      avatarUrl: json['avatar_url'],
      content: json['content'],
      rating: json['rating'] ?? 0,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      parentId: json['parent_id'],
      replies: json['replies'] != null 
          ? (json['replies'] as List).map((r) => Comment.fromJson(r)).toList() 
          : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
