class Course {
  final int id;
  final String title;       // Changed from 'name' to match backend
  final String? content;    // Changed from 'description' to match backend
  final String? videoUrl;
  final String? pdfUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.title,     // Updated parameter name
    this.content,           // Updated parameter name
    this.videoUrl,
    this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],              // Map from backend 'title' field
      content: json['content'],          // Map from backend 'content' field
      videoUrl: json['video_url'],
      pdfUrl: json['pdf_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Optional: Add backward compatibility getters if needed
  String get name => title;
  String? get description => content;
}