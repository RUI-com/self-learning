// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, unnecessary_brace_in_string_interps, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Theme/color.dart';
import '../components/button_auth.dart';
import '../components/textfiled_auth.dart';
import '../controller/auth_controller.dart';
import '../controller/theme_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final ThemeController themeController = Get.find();
  final AuthController authController = Get.put(AuthController());
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    try {
      // التحقق من كلمة المرور الحالية
      final currentPassword = _currentPasswordController.text.trim();
      final email = Supabase.instance.client.auth.currentUser?.email;

      if (email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to verify user.')),
        );
        return;
      }

      // محاولة تسجيل الدخول باستخدام كلمة المرور الحالية
      final loginResponse =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (loginResponse.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Current password is incorrect.')),
        );
        return;
      }

      // تحديث كلمة المرور إذا كانت كلمة المرور الحالية صحيحة
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text.trim(),
        ),
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password updated successfully!')),
        );
        Get.back();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.switchValue.value
          ? themeController.lightBackground
          : themeController.darkBackground,
      appBar: AppBar(
        foregroundColor: themeController.switchValue.value
            ? themeController.lightText
            : themeController.darkText,
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              'Change Password',
              style: TextStyle(
                  fontSize: 24,
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText),
            ),
            SizedBox(height: 10),
            Obx(
              () => TextfiledAuth(
                controller: _currentPasswordController,
                obscureText: authController.obscureText.value,
                data: "Current Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.obscureText.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: authController.togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 10),
            Obx(
              () => TextfiledAuth(
                controller: _newPasswordController,
                obscureText: authController.obscureText.value,
                data: "New Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.obscureText.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: authController.togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 10),
            Obx(
              () => TextfiledAuth(
                controller: _confirmPasswordController,
                obscureText: authController.obscureText.value,
                data: "Confirm New Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    authController.obscureText.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: authController.togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 16),
            ButtonAuth(
              data: "Update Password",
              onPressed: _changePassword,
            ),
          ],
        ),
      ),
    );
  }
}
