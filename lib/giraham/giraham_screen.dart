import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../sidebar/sidebar.dart';
import 'giraham_controller.dart';
import 'giraham_utils.dart';

class GirahamScreen extends StatelessWidget {
  final GirahamController controller = Get.put(GirahamController());

  GirahamScreen({super.key});

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  @override
  Widget build(BuildContext context) {
    controller.initData('YOUR_BEARER_TOKEN'); // replace with actual token

    final TextEditingController descController = TextEditingController();
    RxString selectedPlanet = planetList[0].obs;
    RxString selectedType = allTypes[0].obs;

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      drawer: isLargeScreen ? null : const Sidebar(),
      appBar:
          isLargeScreen
              ? null
              : AppBar(
                backgroundColor: Colors.deepOrange,
                title: const Text(
                  "Giraham",
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          // Optional: implement bulk upload dialog
        },
        child: const Icon(Icons.upload_file, color: Colors.white),
        tooltip: 'Bulk Upload Girahams',
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(width: screenWidth * 0.18, child: const Sidebar()),
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
                            if (!isLargeScreen) ...[
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Obx(() {
                                      return Container(
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
                                            if (val != null)
                                              selectedPlanet.value = val;
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
                                      );
                                    }),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: Obx(() {
                                      return Container(
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
                                            if (val != null)
                                              selectedType.value = val;
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
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
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
                                final id = girahamIdFromPlanet(
                                  selectedPlanet.value,
                                );
                                if (id != null &&
                                    descController.text.trim().isNotEmpty) {
                                  controller.addGiraham(
                                    id,
                                    descController.text.trim(),
                                  );
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
                            if (controller.girahams.isEmpty) {
                              return const Center(
                                child: Text(
                                  "தேர்வு செய்யப்பட்ட கிரகத்திற்கு தொடர்புடைய தரவுகள் இல்லை",
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
                                      controller.girahams.asMap().entries.map((
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
                                                            'Edit Giraham',
                                                          ),
                                                          content: TextField(
                                                            controller:
                                                                editController,
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
                                                                controller.updateGiraham(
                                                                  item.id,
                                                                  editController
                                                                      .text
                                                                      .trim(),
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
                                                    onPressed:
                                                        () => controller
                                                            .deleteGiraham(
                                                              item.id,
                                                            ),
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
                    const SizedBox(height: 10),
                    // Bottom-right bulk upload button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(
                          Icons.upload_file,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "குறிப்புகள் சேர்க்க",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          // Optional: implement bulk upload dialog
                        },
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
