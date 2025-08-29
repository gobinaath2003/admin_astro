import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Material(
      elevation: 8,
      color: Colors.white,
      child: Container(
        width: isMobile ? 240 : 280,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo & Admin Info
              const SizedBox(height: 30),

              Center(
                child: Image.asset(
                  'assets/rka.png',
                  height: isMobile ? 80 : 100,
                ),
              ),
              const SizedBox(height: 30),

              // Menu Items
              ..._buildMenuItems(context),

              const SizedBox(height: 20),
              const Divider(thickness: 1, color: Colors.grey),

              // Sign Out
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.redAccent.withOpacity(0.1),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Get.offAllNamed('/logincredential');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    // Reordered first 6 items
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.brightness_1_outlined,
        'label': "லக்னம்",
        'route': '/lagnam',
      },
      {'icon': Icons.circle, 'label': "பாவம்", 'route': '/bhavam'},
      {
        'icon': Icons.feedback,
        'label': "2 சேர்க்கை",
        'route': '/twocombination',
      },
      {'icon': Icons.star, 'label': "நட்சத்திரங்கள்", 'route': '/star'},
      {'icon': Icons.brightness_4, 'label': "ராசி", 'route': '/rasi'},
      {
        'icon': Icons.brightness_1_outlined,
        'label': "3 சேர்க்கை",
        'route': '/threecombination',
      },

      // Rest of items unchanged
      {'icon': Icons.circle, 'label': "பலன்கள்", 'route': '/planet'},
      {'icon': Icons.feedback, 'label': "பரிந்துரை", 'route': '/suggestion'},
      {'icon': Icons.memory, 'label': "ஏ.ஐ", 'route': '/ai'},
      {'icon': Icons.warning, 'label': "தோஷம்", 'route': '/dhosham'},
      {
        'icon': Icons.local_florist,
        'label': "மலர் மருத்துவம்",
        'route': '/malar',
      },
      {
        'icon': Icons.account_circle,
        'label': "மந்திரிகம்",
        'route': '/mantrigam',
      },
      {'icon': Icons.healing, 'label': "பரிகாரம்", 'route': '/pariharam'},
      {'icon': Icons.visibility, 'label': "கிரக பார்வை", 'route': '/paravi'},
      {'icon': Icons.accessibility, 'label': "பிரசன்னம்", 'route': '/prasanam'},
      {
        'icon': Icons.accessibility,
        'label': "புரிந்துணர்வு",
        'route': '/prediction',
      },
      {
        'icon': Icons.flutter_dash,
        'label': "தாந்திரிகம்",
        'route': '/thantrigam',
      },
       {
        'icon': Icons.add,   
        'label': "Add course",
        'route': '/astroprofile',
      },
       {
        'icon': Icons.admin_panel_settings,   
        'label': "Add course",
        'route': '/course',
      },
      {'icon': Icons.campaign, 'label': "விளம்பரம்", 'route': '/advertisement'},
    ];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Get.toNamed(item['route']),
          hoverColor: isDesktop ? Colors.orange.shade50 : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade100.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(item['icon'], color: Colors.orange.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
