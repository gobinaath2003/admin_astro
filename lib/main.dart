import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testadm/permission_controller.dart';
import 'package:testadm/sidebar/routing.dart';   // <-- AppRoutes is here
import 'package:testadm/services/auth_controller.dart';
import 'package:testadm/sugggestion/PrefsHelper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("[MAIN] Flutter binding initialized");


  Get.put(PermissionController());
  print("[MAIN] PermissionController initialized");

  final authController = Get.put(AuthController());
  print("[MAIN] AuthController initialized");


  String initialRoute = '/logincredential';
  try {
    final token = await PrefsHelper.getToken();
    final adminId = await PrefsHelper.getAdminId() ?? 0;

    print("[MAIN] Token retrieved: $token");
    print("[MAIN] AdminId retrieved: $adminId");

    if (token != null && token.isNotEmpty) {
      authController.setToken(token);
      authController.setAdminId(adminId);
      initialRoute = '/lagnam';
      print("[MAIN] Token valid, setting initialRoute to /lagnam");
    }
  } catch (e) {
    print("[MAIN] Error reading token: $e");
  }


  for (var page in AppRoutes.routes) {
    print("[ROUTING] Registered route: ${page.name}");
  }

  print("[MAIN] Running app with initialRoute: $initialRoute");

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    print("[MyApp] Building GetMaterialApp with initialRoute: $initialRoute");
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: AppRoutes.routes,

      // 👇 Debug helper: catches typos/missing routes
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          appBar: AppBar(title: const Text("Route Not Found")),
          body: Center(
            child: Text("No matching route found for: $initialRoute"),
          ),
        ),
      ),
    );
  }
}
