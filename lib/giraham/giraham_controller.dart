import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'giraham_model.dart';
import 'giraham_service.dart';
import 'giraham_utils.dart';

class GirahamController extends GetxController {
  RxList<GirahamModel> girahams = <GirahamModel>[].obs;

  // Selected planet
  RxString selectedPlanet = planetList[0].obs;

  // Selected Type
  RxString selectedType = 'All'.obs;

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  final TextEditingController descController = TextEditingController();

  String? bearerToken;

  /// Initialize with token
  void initData(String token) {
    if (bearerToken != null) return;
    bearerToken = token;
    fetchAllGiraham();
  }

  /// Fetch all girahams from backend
  Future<void> fetchAllGiraham() async {
    if (bearerToken == null) return;
    try {
      var data = await GirahamService.fetchAllGiraham(bearerToken!);

      // Filter by planet if needed
      final planetId = girahamIdFromPlanet(selectedPlanet.value);
      if (planetId != null) {
        data = data.where((g) => g.girahamId == planetId).toList();
      }

      // Filter by type if needed (if your API supports type, else skip)
      if (selectedType.value != 'All') {
        data = data.where((g) => g.type == selectedType.value).toList();
      }

      girahams.assignAll(data);
    } catch (e) {
      showSnackBar('Error fetching Girahams: $e');
    }
  }

  /// Add a new Giraham
  Future<void> addGiraham(int girahamId, String desc) async {
    if (bearerToken == null) return;
    if (desc.trim().isEmpty) {
      showSnackBar('Description cannot be empty');
      return;
    }
    try {
      await GirahamService.createGiraham(bearerToken!, girahamId, desc);
      descController.clear();
      await fetchAllGiraham();
      showSnackBar('Giraham added successfully!');
    } catch (e) {
      showSnackBar('Error adding Giraham: $e');
    }
  }

  /// Update Giraham
  Future<void> updateGiraham(int id, String desc) async {
    if (bearerToken == null) return;
    if (desc.trim().isEmpty) {
      showSnackBar('Description cannot be empty');
      return;
    }
    try {
      await GirahamService.updateGiraham(bearerToken!, id, desc);
      await fetchAllGiraham();
      showSnackBar('Giraham updated successfully!');
    } catch (e) {
      showSnackBar('Error updating Giraham: $e');
    }
  }

  /// Delete Giraham
  Future<void> deleteGiraham(int id) async {
    if (bearerToken == null) return;
    try {
      await GirahamService.deleteGiraham(bearerToken!, id);
      await fetchAllGiraham();
      showSnackBar('Giraham deleted successfully!');
    } catch (e) {
      showSnackBar('Error deleting Giraham: $e');
    }
  }

  /// Show bulk upload dialog
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
                  "பல கிரகம் குறிப்புகள் சேர்க்க",
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
                Obx(
                  () => DropdownButton<String>(
                    isExpanded: true,
                    value: selectedPlanet.value,
                    items:
                        planetList
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) selectedPlanet.value = val;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Obx(
                  () => DropdownButton<String>(
                    isExpanded: true,
                    value: selectedType.value,
                    items:
                        allTypes
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    onChanged: (val) {
                      if (val != null) selectedType.value = val;
                    },
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        child: const Text("ரத்து செய்யவும்"),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("பதிவேற்றவும்"),
                        onPressed: () async {
                          final notes = bulkController.text
                              .trim()
                              .split('\n')
                              .where((n) => n.isNotEmpty);
                          final planetId = girahamIdFromPlanet(
                            selectedPlanet.value,
                          );
                          if (planetId == null) return;

                          for (final note in notes) {
                            await addGiraham(planetId, note.trim());
                          }

                          Get.back();
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

  /// Show snackbar helper
  void showSnackBar(String msg) {
    Get.snackbar(
      '',
      '',
      messageText: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.black87,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Show Edit dialog for a Giraham
  void showEditDialog(BuildContext context, GirahamModel item) {
    final editController = TextEditingController(text: item.description);

    Get.dialog(
      AlertDialog(
        title: const Text('குறிப்பு திருத்தம்'),
        content: TextField(controller: editController),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              updateGiraham(item.id, editController.text.trim());
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
