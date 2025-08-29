class GirahamModel {
  final int id;
  final int girahamId;
  final int adminId;
  final String description;
  final String? type; // New field
  final DateTime createdAt;
  final DateTime updatedAt;

  GirahamModel({
    required this.id,
    required this.girahamId,
    required this.adminId,
    required this.description,
    this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GirahamModel.fromJson(Map<String, dynamic> json) {
    return GirahamModel(
      id: json['id'],
      girahamId: json['girahamId'],
      adminId: json['adminId'],
      description: json['description'],
      type: json['type'], // Assign type from JSON (may be null)
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'girahamId': girahamId,
    'adminId': adminId,
    'description': description,
    'type': type, // Include type
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
