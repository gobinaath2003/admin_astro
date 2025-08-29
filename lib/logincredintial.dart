import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:testadm/lagnam.dart';
import 'package:testadm/lagnam/laknam_screen.dart';
import 'package:testadm/services/auth_controller.dart';
import 'package:testadm/sugggestion/PrefsHelper.dart';

class Logincredintialpage extends StatefulWidget {
  const Logincredintialpage({super.key});

  @override
  State<Logincredintialpage> createState() => _LoginPageState();
}

class _LoginPageState extends State<Logincredintialpage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier<bool>(false);
  final authController = Get.find<AuthController>();

  Future<void> validateAndLogin() async {
    print("[Login] Sign in button pressed");

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      print("[Login] Validation failed: empty fields");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      print("[Login] Sending login request for email: $email");

      final response = await http.post(
        Uri.parse('https://astro-j7b4.onrender.com/api/admins/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("[Login] Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final adminId = data['id'];

        print("[Login] Received token: $token");
        print("[Login] Received Admin ID: $adminId");

        if (token == null) {
          print("[Login] Token is null! Login cannot proceed.");
          throw Exception("Token not found");
        }

        // Save token locally
        await PrefsHelper.saveAuthData(token, adminId);
        print("[Login] Token and Admin ID saved to PrefsHelper");

        // Update AuthController
        authController.setToken(token);
        authController.setAdminId(adminId);
        print("[Login] Token in AuthController: ${authController.token.value}");
        print(
          "[Login] AdminID in AuthController: ${authController.adminId.value}",
        );

        print("[Login] Login successful, navigating to Lagnam page...");
        Get.offAll(() => LaknamScreen());
      } else {
        final errorData = jsonDecode(response.body);
        print("[Login] Login failed with status ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${errorData['message'] ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      print("[Login] Exception occurred: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isPasswordVisible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade500,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/rka.png', height: 60),
              const SizedBox(height: 10),
              const Text(
                "Sign in with Email & Password",
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<bool>(
                valueListenable: isPasswordVisible,
                builder: (context, value, child) {
                  return TextField(
                    controller: passwordController,
                    obscureText: !value,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          value ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => isPasswordVisible.value = !value,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Sign in"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
