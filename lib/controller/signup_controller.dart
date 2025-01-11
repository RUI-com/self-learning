// ignore_for_file: file_names, prefer_const_constructors, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../auth/auth_service.dart';
import '../pages/login_pages.dart';

class SignupController extends GetxController {
  final authService = AuthService();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  File? imageFile;

  // اختيار صورة
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imageFile = File(image.path);
      update(); // لتحديث الواجهة
    }
  }

  // عملية التسجيل
  Future<void> signup(BuildContext context) async {
    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // التحقق من كلمة المرور
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Passwords don't match")));
      return;
    }

    // التحقق من اختيار الصورة
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select an avatar image")));
      return;
    }

    try {
      // رفع الصورة
      final fileName = DateTime.now().microsecondsSinceEpoch.toString();
      final path = 'avatars/$fileName';
      await authService.uploadImage(path, imageFile!);

      // الحصول على رابط الصورة
      final avatarUrl = authService.getPublicUrl(path);

      // إنشاء الحساب
      final response = await authService.signUpWithEmailPassword(
          email, password, name, avatarUrl);

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Account created successfully! You can now log in.")));

        // الانتقال إلى صفحة تسجيل الدخول
        Get.to(LoginPages());
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
