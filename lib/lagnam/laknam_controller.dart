import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'laknam_model.dart';
import 'laknam_service.dart';
import 'laknam_utils.dart';

class LaknamController extends GetxController {
  final LaknamService service;

  LaknamController({required this.service});

  var posts = <LaknamPost>[].obs;

  // Selected Lagnam
  final selectedLagnam = 'அனைத்து லக்னம்'.obs;

  // Selected Type
  final selectedType = 'All'.obs;

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  // Note input controller
  final noteController = TextEditingController();

  /// Mapping Lagnam name to backend LaknamId
  final Map<String, int> _laknamNameToId = {
    'அனைத்து லக்னம்': 0,
    'மேஷம் லக்னம்': 1,
    'ரிஷபம் லக்னம்': 2,
    'மிதுனம் லக்னம்': 3,
    'கடகம் லக்னம்': 4,
    'சிம்மம் லக்னம்': 5,
    'கன்னி லக்னம்': 6,
    'துலாம் லக்னம்': 7,
    'விருச்சிகம் லக்னம்': 8,
    'தனுசு லக்னம்': 9,
    'மகரம் லக்னம்': 10,
    'கும்பம் லக்னம்': 11,
    'மீனம் லக்னம்': 12,
  };

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  /// Fetch posts created by the logged-in admin
  Future<void> fetchPosts() async {
    try {
      // Fetch only admin posts from backend
      var result = await service.fetchPostsByAdmin();

      // Filter by selected Lagnam if not "All"
      if (selectedLagnam.value != 'அனைத்து லக்னம்') {
        final laknamId = _laknamNameToId[selectedLagnam.value]!;
        result = result.where((p) => p.laknamId == laknamId).toList();
      }

      // Filter by type if not "All"
      if (selectedType.value != 'All') {
        result = result.where((p) => p.type == selectedType.value).toList();
      }

      posts.value = result;
    } catch (e) {
      print("Fetch Error: $e");
      Get.snackbar("Error", "பதிவுகளை பெற முடியவில்லை: $e");
    }
  }

  /// Add a new post for the selected Lagnam
  Future<void> addPost() async {
    final content = noteController.text.trim();
    final laknam = selectedLagnam.value;

    if (laknam != 'அனைத்து லக்னம்' && content.isNotEmpty) {
      try {
        final laknamId = _laknamNameToId[laknam]!;
        final typeToSend =
            selectedType.value == 'All' ? 'Positive' : selectedType.value;
        await service.createPost(laknamId, content, typeToSend);
        noteController.clear();
        await fetchPosts();
        Get.snackbar("Success", "$laknam க்கு பதிவு சேர்க்கப்பட்டது");
      } catch (e) {
        Get.snackbar("Error", "பதிவு சேர்க்க முடியவில்லை: $e");
      }
    } else {
      Get.snackbar("Error", "ஒரு லக்னம் மற்றும் குறிப்பை உள்ளிடவும்");
    }
  }

  /// Update existing post
  Future<void> updatePost(int postId, String content, String laknamName) async {
    try {
      final laknamId = _laknamNameToId[laknamName]!;
      await service.updatePost(postId, content, laknamId);
      await fetchPosts();
      Get.snackbar("Success", "பதிவு புதுப்பிக்கப்பட்டது");
    } catch (e) {
      Get.snackbar("Error", "பதிவு புதுப்பிக்க முடியவில்லை: $e");
    }
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    try {
      await service.deletePost(postId);
      await fetchPosts();
      Get.snackbar("Success", "பதிவு நீக்கப்பட்டது");
    } catch (e) {
      Get.snackbar("Error", "பதிவு நீக்க முடியவில்லை: $e");
    }
  }

  /// Show bulk upload dialog (like StarController)
  Future<void> showBulkUploadDialog() async {
    final bulkController = TextEditingController();

    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 700),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "பல லக்னக் குறிப்புகள் சேர்க்க",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: bulkController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "ஒரு வரியில் குறிப்புகளை சேர்க்கவும்...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 15),
                // Lagnam dropdown
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedLagnam.value,
                      underline: const SizedBox(),
                      items:
                          _laknamNameToId.keys
                              .map(
                                (lagnam) => DropdownMenuItem(
                                  value: lagnam,
                                  child: Text(lagnam),
                                ),
                              )
                              .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) selectedLagnam.value = newValue;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Type dropdown
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedType.value,
                      underline: const SizedBox(),
                      items:
                          allTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) selectedType.value = newValue;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("ரத்து செய்யவும்"),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "பதிவேற்றவும்",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final notes = bulkController.text.trim().split('\n');
                          final lagnam = selectedLagnam.value;
                          final type = selectedType.value;

                          if (lagnam == 'அனைத்து லக்னம்') {
                            Get.snackbar(
                              "பிழை",
                              "ஒரு குறிப்பிட்ட லக்னம் தேர்வு செய்யவும்.",
                              backgroundColor: Colors.red.shade100,
                            );
                            return;
                          }

                          final laknamId = _laknamNameToId[lagnam]!;
                          bool success = true;

                          for (final note in notes) {
                            if (note.trim().isNotEmpty) {
                              String typeToSend =
                                  type == 'All' ? 'Positive' : type;
                              try {
                                await service.createPost(
                                  laknamId,
                                  note.trim(),
                                  typeToSend,
                                );
                              } catch (e) {
                                success = false;
                              }
                            }
                          }

                          if (success) {
                            Get.back();
                            fetchPosts();
                            Get.snackbar(
                              "வெற்றி",
                              "$lagnam க்கு அனைத்து குறிப்புகளும் சேர்க்கப்பட்டன.",
                              backgroundColor: Colors.green.shade100,
                            );
                          } else {
                            Get.snackbar(
                              "பிழை",
                              "சில குறிப்புகளை சேர்க்க முடியவில்லை.",
                              backgroundColor: Colors.red.shade100,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show Edit Dialog for a Laknam post
  void showEditDialog(BuildContext context, LaknamPost post) {
    final editController = TextEditingController(text: post.content);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("குறிப்பு திருத்தம்"),
            content: TextField(
              controller: editController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "குறிப்பு திருத்தவும்",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newContent = editController.text.trim();
                  if (newContent.isNotEmpty) {
                    await updatePost(
                      post.postId,
                      newContent,
                      selectedLagnam.value,
                    );
                    Navigator.pop(context);
                  } else {
                    Get.snackbar("Error", "குறிப்பு வெறுமையாக இருக்க முடியாது");
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }
}
