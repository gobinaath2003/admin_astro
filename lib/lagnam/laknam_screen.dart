import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../sidebar/sidebar.dart';
import 'laknam_controller.dart';
import 'laknam_service.dart';
import 'laknam_utils.dart';

class LaknamScreen extends StatelessWidget {
  final LaknamController controller = Get.put(
    LaknamController(service: LaknamService()),
  );

  final List<String> allTypes = [
    'All',
    'Strong',
    'Weak',
    'Positive',
    'Negative',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 600;

    return Scaffold(
      drawer: isLargeScreen ? null : Sidebar(),
      appBar:
          isLargeScreen
              ? null
              : AppBar(
                backgroundColor: Colors.deepOrange,
                title: const Text(
                  "Laknam",
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
        onPressed: controller.showBulkUploadDialog,
        child: const Icon(Icons.upload_file, color: Colors.white),
        tooltip: 'Bulk Upload Laknam Notes',
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (isLargeScreen)
              SizedBox(width: screenWidth * 0.18, child: Sidebar()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Card: Dropdowns + Add Button (like StarScreen)
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
                            // Only show dropdowns on small screens
                            if (!isLargeScreen) ...[
                              Row(
                                children: [
                                  // Lagnam Dropdown
                                  Expanded(
                                    flex: 3,
                                    child: DropdownButtonHideUnderline(
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
                                            value:
                                                controller.selectedLagnam.value,
                                            onChanged: (newValue) {
                                              if (newValue != null) {
                                                controller
                                                    .selectedLagnam
                                                    .value = newValue;
                                                controller.fetchPosts();
                                              }
                                            },
                                            items:
                                                lagnamList
                                                    .map(
                                                      (
                                                        lagnam,
                                                      ) => DropdownMenuItem(
                                                        value: lagnam,
                                                        child: Text(
                                                          lagnam,
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        );
                                      }),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Type Dropdown
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
                                          value: controller.selectedType.value,
                                          onChanged: (newType) {
                                            if (newType != null) {
                                              controller.selectedType.value =
                                                  newType;
                                            }
                                          },
                                          items:
                                              allTypes
                                                  .map(
                                                    (type) => DropdownMenuItem(
                                                      value: type,
                                                      child: Text(
                                                        type,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
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

                            // Add Button
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
                              onPressed: controller.showBulkUploadDialog,
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
                    // Note Input

                    // Data Table Card
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Obx(() {
                            if (controller.posts.isEmpty) {
                              return const Center(
                                child: Text(
                                  "தேர்வு செய்யப்பட்ட லக்னத்திற்கு தொடர்புடைய தரவுகள் இல்லை",
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
                                  headingRowHeight:
                                      60, // increase header height
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
                                      controller.posts.asMap().entries.map((
                                        entry,
                                      ) {
                                        final index = entry.key + 1;
                                        final post = entry.value;

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12.0,
                                                ), // add spacing
                                                child: Text(index.toString()),
                                              ),
                                            ),
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12.0,
                                                ), // add spacing
                                                child: Text(post.content),
                                              ),
                                            ),
                                            DataCell(
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                        size: 18,
                                                      ),
                                                      onPressed:
                                                          () => controller
                                                              .showEditDialog(
                                                                context,
                                                                post,
                                                              ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                        size: 18,
                                                      ),
                                                      onPressed:
                                                          () => controller
                                                              .deletePost(
                                                                post.postId,
                                                              ),
                                                    ),
                                                  ],
                                                ),
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
                        onPressed: controller.showBulkUploadDialog,
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
