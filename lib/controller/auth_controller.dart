import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_service.dart';
import '../main_screen.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  // Controllers for email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observable state for password visibility
  var obscureText = true.obs;

  // Login function
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      await _authService.signInWithEmailPassword(email, password);
      Get.offAll(() => MainScreen()); // Navigate to main screen
    } catch (e) {
      Get.snackbar("Error", "$e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscureText.value = !obscureText.value;
  }

  // Clean up controllers
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
