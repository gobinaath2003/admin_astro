class BhavamModel {
  final int postId;
  final int adminId;
  final int sinId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  BhavamModel({
    required this.postId,
    required this.adminId,
    required this.sinId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BhavamModel.fromJson(Map<String, dynamic> json) {
    return BhavamModel(
      postId: json['postId'],
      adminId: json['adminId'],
      sinId: json['sinId'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'adminId': adminId,
    'sinId': sinId,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
