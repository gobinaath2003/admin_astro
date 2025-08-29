import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; 
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data'; 
import 'package:testadm/services/courseapi.dart';

class addcourse extends StatefulWidget {
  const addcourse({Key? key}) : super(key: key);

  @override
  _addcourseScreenState createState() => _addcourseScreenState();
}

class _addcourseScreenState extends State<addcourse> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _languageController = TextEditingController();
  final _experienceController = TextEditingController();
  final _minutes= TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  
  int _rating = 5;
  
  // For mobile platforms
  File? _selectedImageFile;
  
  // For web platform
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Add Astrologer'),
        backgroundColor: Color.fromARGB(255, 254, 182, 58),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildImageSection(),
            SizedBox(height: 20),
            _buildTextField(_nameController, 'Name', Icons.person, required: true),
            _buildTextField(_specializationController, 'Specialization', Icons.psychology, required: true),
            _buildTextField(_languageController, 'Languages', Icons.language, required: true),
            Row(
              children: [
                Expanded(child: _buildTextField(_experienceController, 'Experience (Years)', Icons.trending_up, 
                    keyboardType: TextInputType.number, required: true)),
                SizedBox(width: 12),
                Expanded(child: _buildTextField(_minutes, 'Minutes', Icons.shopping_bag, 
                    keyboardType: TextInputType.number, required: true)),
              ],
            ),
            _buildRatingSection(),
            Row(
              children: [
                Expanded(child: _buildTextField(_originalPriceController, 'Original Price (₹)', Icons.currency_rupee, 
                    keyboardType: TextInputType.number, required: true)),
                SizedBox(width: 12),
                Expanded(child: _buildTextField(_discountedPriceController, 'Discount Price (₹)', Icons.local_offer, 
                    keyboardType: TextInputType.number, required: true)),
              ],
            ),
            SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: InkWell(
        onTap: _isLoading ? null : _pickImage,
        borderRadius: BorderRadius.circular(12),
        child: _hasImage()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImageDisplay(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 40, color: Color.fromARGB(255, 254, 182, 58)),
                  SizedBox(height: 8),
                  Text('Tap to add profile photo', style: TextStyle(color: Colors.grey[600])),
                  if (kIsWeb) 
                    Text('(Web compatible)', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
      ),
    );
  }

  Widget _buildImageDisplay() {
    if (kIsWeb && _selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (!kIsWeb && _selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Container();
  }

  bool _hasImage() {
    return (kIsWeb && _selectedImageBytes != null) || 
           (!kIsWeb && _selectedImageFile != null);
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType, bool required = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        validator: required ? (value) {
          if (value?.isEmpty ?? true) {
            return 'This field is required';
          }
          if (keyboardType == TextInputType.number) {
            if (int.tryParse(value!) == null) {
              return 'Please enter a valid number';
            }
          }
          return null;
        } : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color.fromARGB(255, 255, 209, 71)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Column(
        children: [
          Text('Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: _isLoading ? null : () => setState(() => _rating = index + 1),
                icon: Icon(
                  Icons.star,
                  size: 32,
                  color: index < _rating ? Colors.amber : Colors.grey[300],
                ),
              );
            }),
          ),
          Text('${_rating}/5 stars', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color.fromARGB(255, 221, 152, 54), Color.fromARGB(255, 225, 152, 6)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Color.fromARGB(255, 236, 182, 82).withOpacity(0.3), blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading 
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('Adding...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )
            : Text('Add Astrologer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // For web platform, read the file as bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageName = image.name;
            _selectedImageFile = null; // Clear mobile file
          });
        } else {
          // For mobile platforms, use File
          setState(() {
            _selectedImageFile = File(image.path);
            _selectedImageBytes = null; // Clear web bytes
            _selectedImageName = null;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  void _submitForm() async {
  if (!(_formKey.currentState?.validate() ?? false)) {
    print("Form validation failed ❌");
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // Prepare image data based on platform
    dynamic imageData;
    if (kIsWeb && _selectedImageBytes != null) {
      print("Platform: Web 🌐");
      imageData = {
        'bytes': _selectedImageBytes,
        'name': _selectedImageName ?? 'profile_image.jpg',
      };
      print("Selected image name: ${imageData['name']}");
    } else if (!kIsWeb && _selectedImageFile != null) {
      print("Platform: Mobile 📱");
      imageData = _selectedImageFile;
      print("Selected image file path: ${_selectedImageFile?.path}");
    } else {
      print("⚠️ No image selected");
    }

    // Log form data before API call
    print("Submitting form with values:");
    print("Name: ${_nameController.text.trim()}");
    print("Specialization: ${_specializationController.text.trim()}");
    print("Language: ${_languageController.text.trim()}");
    print("Experience: ${_experienceController.text}");
    print("Rating: $_rating");
    print("Orders: ${_minutes.text}");
    print("Original Price: ${_originalPriceController.text}");
    print("Discounted Price: ${_discountedPriceController.text}");

    // Call the API service
    final result = await AstrologerService.addAstrologer(
      name: _nameController.text.trim(),
      specialization: _specializationController.text.trim(),
      language: _languageController.text.trim(),
      experience: int.parse(_experienceController.text),
      rating: _rating,
       miuutes: int.parse(_minutes.text),
      originalPrice: int.parse(_originalPriceController.text),
      discountedPrice: int.parse(_discountedPriceController.text),
      image: imageData, // Pass the platform-appropriate image data
    );

    print("API Response: $result");

    if (result['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Astrologer added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      print("✅ Astrologer added successfully");

      // Clear form
      _clearForm();

      // Navigate back or to astrologers list
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      print("❌ Failed: ${result['message']}");
      _showErrorSnackBar(result['message'] ?? 'Failed to add astrologer');
    }
  } catch (e) {
    print("🔥 Exception: ${e.toString()}");
    _showErrorSnackBar('An error occurred: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
    print("Loading state set to false");
  }
}

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _specializationController.clear();
    _languageController.clear();
    _experienceController.clear();
    _minutes.clear();
    _originalPriceController.clear();
    _discountedPriceController.clear();
    setState(() {
      _rating = 5;
      _selectedImageFile = null;
      _selectedImageBytes = null;
      _selectedImageName = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _languageController.dispose();
    _experienceController.dispose();
    _minutes.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    super.dispose();
  }
}