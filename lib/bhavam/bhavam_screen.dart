import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/sidebar/sidebar.dart';
import 'bhavam_controller.dart';
import 'bhavam_utils.dart';
import '../sugggestion/PrefsHelper.dart';

class BhavamScreen extends StatelessWidget {
  final BhavamController controller = Get.put(BhavamController());

  BhavamScreen({super.key});

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  Future<void> _initController() async {
    final token = await PrefsHelper.getToken();
    if (token != null) {
      controller.initData(token);
    } else {
      print("[BhavamScreen] No token found! User might need to login again.");
      // Optionally redirect to login
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller with actual token
    _initController();

    final TextEditingController descController = TextEditingController();
    RxString selectedPlanet = planetList[controller.selectedSin.value - 1].obs;
    RxString selectedType = allTypes[0].obs;

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 800;

    return Scaffold(
      drawer: isLargeScreen ? null : const Sidebar(),
      appBar:
          isLargeScreen
              ? null
              : AppBar(
                backgroundColor: Colors.deepOrange,
                title: const Text(
                  "Bhavam",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
              ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(width: screenWidth * 0.15, child: const Sidebar()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Card: Dropdowns + Add Button
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isLargeScreen)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Obx(
                                      () => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedPlanet.value,
                                          onChanged: (val) {
                                            if (val != null) {
                                              selectedPlanet.value = val;
                                              controller
                                                  .selectedSin
                                                  .value = sinIdFromName(val);
                                              controller.fetchSins();
                                            }
                                          },
                                          items:
                                              planetList
                                                  .map(
                                                    (planet) =>
                                                        DropdownMenuItem(
                                                          value: planet,
                                                          child: Text(planet),
                                                        ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Obx(
                                      () => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedType.value,
                                          onChanged: (val) {
                                            if (val != null) {
                                              selectedType.value = val;
                                            }
                                          },
                                          items:
                                              allTypes
                                                  .map(
                                                    (type) => DropdownMenuItem(
                                                      value: type,
                                                      child: Text(type),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              onPressed: () {
                                if (descController.text.trim().isNotEmpty) {
                                  controller.addSin();
                                  descController.clear();
                                }
                              },
                              child: const Text(
                                "குறிப்புகள் சேர்க்க",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Note Input & DataTable
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Obx(() {
                            if (controller.sins.isEmpty) {
                              return const Center(
                                child: Text(
                                  "தேர்வு செய்யப்பட்ட பாவத்திற்கு தொடர்புடைய தரவுகள் இல்லை",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            }
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width,
                                ),
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.deepOrange.shade100,
                                  ),
                                  columnSpacing: 16,
                                  dataRowHeight: 50,
                                  headingTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text('பி.நி')),
                                    DataColumn(label: Text('குறிப்பு')),
                                    DataColumn(label: Text('செயல்கள்')),
                                  ],
                                  rows:
                                      controller.sins.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key + 1;
                                        final item = entry.value;
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(index.toString())),
                                            DataCell(Text(item.description)),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                      color: Colors.blue,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      final editController =
                                                          TextEditingController(
                                                            text:
                                                                item.description,
                                                          );
                                                      Get.dialog(
                                                        AlertDialog(
                                                          title: const Text(
                                                            'Edit Bhavam',
                                                          ),
                                                          content: TextField(
                                                            controller:
                                                                editController,
                                                            maxLines: null,
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Get.back(),
                                                              child: const Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                controller.updateSin(
                                                                  item.postId,
                                                                  editController
                                                                      .text,
                                                                );
                                                                Get.back();
                                                              },
                                                              child: const Text(
                                                                'Save',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (_) => AlertDialog(
                                                              title: const Text(
                                                                'குறிப்பை நீக்கு',
                                                              ),
                                                              content: const Text(
                                                                'நீக்க விரும்புகிறீர்களா?',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () => Navigator.pop(
                                                                        context,
                                                                      ),
                                                                  child:
                                                                      const Text(
                                                                        'ரத்து',
                                                                      ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () async {
                                                                    await controller
                                                                        .deleteSin(
                                                                          item.postId,
                                                                        );
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                        'நீக்கு',
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
