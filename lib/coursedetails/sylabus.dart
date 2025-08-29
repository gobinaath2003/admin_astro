import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:testadm/model/course.dart';
import 'package:testadm/services/courseapiservice.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Course> courses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => isLoading = true);
    try {
      courses = await ApiService.getCourses();
      print("✅ Loaded ${courses.length} courses");
    } catch (e) {
      print("❌ Error loading courses: $e");
      _showSnackBar('Failed to load syllabus: $e', Colors.red);
    }
    setState(() => isLoading = false);
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color, duration: Duration(seconds: 3)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Syllabus Management'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            onPressed: () => _showCourseDialog(),
            icon: Icon(Icons.add),
            tooltip: 'Add Syllabus',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) => _buildCourseCard(courses[index]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadCourses,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No syllabus available', style: TextStyle(fontSize: 18)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showCourseDialog(),
            child: Text('Add Syllabus'),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    course.title ?? 'Untitled',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Row(
                  children: [
                    // UPDATE BUTTON
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _showCourseDialog(course: course),
                        icon: Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Update Syllabus',
                      ),
                    ),
                    SizedBox(width: 8),
                    // DELETE BUTTON
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: () => _confirmDelete(course),
                        icon: Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Syllabus',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            if (course.content != null && course.content!.isNotEmpty) ...[
              Text(
                course.content!,
                style: TextStyle(color: Colors.grey[600]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
            ],
            Row(
              children: [
                if (course.videoUrl != null && course.videoUrl!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_circle, size: 16, color: Colors.green[700]),
                        SizedBox(width: 4),
                        Text('Video', style: TextStyle(color: Colors.green[700], fontSize: 12)),
                      ],
                    ),
                  ),
                if (course.videoUrl != null && course.videoUrl!.isNotEmpty &&
                    course.pdfUrl != null && course.pdfUrl!.isNotEmpty)
                  SizedBox(width: 8),
                if (course.pdfUrl != null && course.pdfUrl!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 16, color: Colors.red[700]),
                        SizedBox(width: 4),
                        Text('PDF', style: TextStyle(color: Colors.red[700], fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            if (course.createdAt != null)
              Text(
                'Created: ${course.createdAt!.day}/${course.createdAt!.month}/${course.createdAt!.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _showCourseDialog({Course? course}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CourseDialog(
        course: course,
        onSaved: () {
          _loadCourses();
          _showSnackBar(
            course == null ? '✅ Syllabus created!' : '✅ Syllabus updated!',
            Colors.green,
          );
        },
      ),
    );
  }

  void _confirmDelete(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Syllabus'),
          ],
        ),
        content: Text(
            'Are you sure you want to delete "${course.title ?? 'this syllabus'}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Deleting...'),
                      ],
                    ),
                  ),
                ),
              );
              try {
                bool success = await ApiService.deleteCourse(course.id);
                if (mounted) Navigator.pop(context);
                if (success) {
                  _loadCourses();
                  _showSnackBar('✅ Syllabus deleted successfully!', Colors.green);
                } else {
                  _showSnackBar('❌ Failed to delete syllabus', Colors.red);
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                _showSnackBar('❌ Error: $e', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('DELETE'),
          ),
        ],
      ),
    );
  }
}

class CourseDialog extends StatefulWidget {
  final Course? course;
  final VoidCallback onSaved;

  CourseDialog({this.course, required this.onSaved});

  @override
  _CourseDialogState createState() => _CourseDialogState();
}

class _CourseDialogState extends State<CourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // For mobile/desktop
  File? _videoFile;
  File? _pdfFile;

  // For web - store bytes and names
  Uint8List? _videoBytes;
  Uint8List? _pdfBytes;
  String? _videoFileName;
  String? _pdfFileName;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      _titleController.text = widget.course!.title ?? '';
      _contentController.text = widget.course!.content ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == 'video' ? FileType.video : FileType.custom,
        allowedExtensions: type == 'video' ? null : ['pdf'],
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result != null) {
        final file = result.files.single;
        if (kIsWeb) {
          if (file.bytes != null) {
            setState(() {
              if (type == 'video') {
                _videoBytes = file.bytes!;
                _videoFileName = file.name;
                _videoFile = null;
              } else {
                _pdfBytes = file.bytes!;
                _pdfFileName = file.name;
                _pdfFile = null;
              }
            });
            print("📎 ${type.toUpperCase()} file selected (Web): ${file.name} (${file.bytes!.length} bytes)");
          }
        } else {
          if (file.path != null) {
            setState(() {
              if (type == 'video') {
                _videoFile = File(file.path!);
                _videoBytes = null;
                _videoFileName = null;
              } else {
                _pdfFile = File(file.path!);
                _pdfBytes = null;
                _pdfFileName = null;
              }
            });
            print("📎 ${type.toUpperCase()} file selected (Mobile/Desktop): ${file.name}");
          }
        }
      }
    } catch (e) {
      print("❌ Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success;

      if (widget.course == null) {
        // CREATE
        success = await ApiService.createCourse(
          title: _titleController.text.trim(),
          content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
          videoFile: kIsWeb ? null : _videoFile,
          pdfFile: kIsWeb ? null : _pdfFile,
          videoBytes: kIsWeb ? _videoBytes : null,
          pdfBytes: kIsWeb ? _pdfBytes : null,
          videoFileName: kIsWeb ? _videoFileName : null,
          pdfFileName: kIsWeb ? _pdfFileName : null,
        );
      } else {
        // UPDATE
        success = await ApiService.updateCourse(
          id: widget.course!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
          videoFile: kIsWeb ? null : _videoFile,
          pdfFile: kIsWeb ? null : _pdfFile,
          videoBytes: kIsWeb ? _videoBytes : null,
          pdfBytes: kIsWeb ? _pdfBytes : null,
          videoFileName: kIsWeb ? _videoFileName : null,
          pdfFileName: kIsWeb ? _pdfFileName : null,
        );
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.pop(context);
          widget.onSaved();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Failed to save syllabus.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _saveCourse),
            ),
          );
        }
      }
    } catch (error) {
      print("❌ Save error: $error");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _hasVideoFile() => kIsWeb ? _videoBytes != null : _videoFile != null;
  bool _hasPdfFile() => kIsWeb ? _pdfBytes != null : _pdfFile != null;
  String _getVideoFileName() => kIsWeb ? _videoFileName ?? 'Unknown' : _videoFile?.path.split('/').last ?? 'Unknown';
  String _getPdfFileName() => kIsWeb ? _pdfFileName ?? 'Unknown' : _pdfFile?.path.split('/').last ?? 'Unknown';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.course == null ? 'Add Syllabus' : 'Edit Syllabus'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                  maxLines: 3,
                  minLines: 3,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _pickFile('video'),
                        icon: Icon(Icons.video_library),
                        label: Text(_hasVideoFile() ? 'Video Selected' : 'Pick Video'),
                        style: OutlinedButton.styleFrom(foregroundColor: _hasVideoFile() ? Colors.green : null),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _pickFile('pdf'),
                        icon: Icon(Icons.picture_as_pdf),
                        label: Text(_hasPdfFile() ? 'PDF Selected' : 'Pick PDF'),
                        style: OutlinedButton.styleFrom(foregroundColor: _hasPdfFile() ? Colors.red : null),
                      ),
                    ),
                  ],
                ),
                if (_hasVideoFile() || _hasPdfFile()) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Files:', style: TextStyle(fontWeight: FontWeight.bold)),
                        if (_hasVideoFile()) Text('📹 ${_getVideoFileName()}', style: TextStyle(fontSize: 12)),
                        if (_hasPdfFile()) Text('📄 ${_getPdfFileName()}', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 8),
                Text('Platform: ${kIsWeb ? 'Web' : 'Mobile/Desktop'}', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCourse,
          child: _isLoading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.course == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}
