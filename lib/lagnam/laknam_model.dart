class LaknamPost {
  final int postId;
  final int laknamId;
  final String type;
  final String content;
  final int adminId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LaknamPost({
    required this.postId,
    required this.laknamId,
    required this.type,
    required this.content,
    required this.adminId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LaknamPost.fromJson(Map<String, dynamic> json) {
    return LaknamPost(
      postId: json['postId'],
      laknamId:
          json['LaknamId'], // JSON uses uppercase, your model uses lowercase
      type: json['type'],
      content: json['content'],
      adminId: json['adminId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
