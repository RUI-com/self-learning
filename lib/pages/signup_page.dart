// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/button_auth.dart';
import '../components/inwell_auth.dart';
import '../components/textfiled_auth.dart';
import '../controller/auth_controller.dart';
import '../controller/signup_controller.dart';

import '../controller/theme_controller.dart';
import 'login_pages.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    final ThemeController themeController = Get.find();
    final AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: themeController.switchValue.value
          ? themeController.lightBackground
          : themeController.darkBackground,
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeController.switchValue.value
                    ? themeController.postbackgroundlight
                    : themeController.postbackgrounddark,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  themeController.switchValue.value
                      ? Image.asset('assets/logo/logo-self.png')
                      : Image.asset('assets/logo/logo-self-darkmode.png'),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => controller.pickImage(),
                    child: GetBuilder<SignupController>(
                      builder: (controller) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: themeController.switchValue.value
                              ? Colors.grey[200]
                              : themeController.darkBackground,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: controller.imageFile != null
                            ? ClipOval(
                                child: Image.file(
                                  controller.imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: themeController.switchValue.value
                                      ? themeController.lightText
                                      : themeController.darkText,
                                ),
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // name
                  TextfiledAuth(
                      controller: controller.nameController,
                      obscureText: false,
                      data: "Enter name"),

                  SizedBox(height: 12),
                  // email
                  TextfiledAuth(
                      controller: controller.emailController,
                      obscureText: false,
                      data: "Enter email"),

                  SizedBox(height: 12),
                  // password
                  Obx(
                    () => TextfiledAuth(
                      controller: controller.passwordController,
                      obscureText: authController.obscureText.value,
                      data: "Enter Password",
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
                  SizedBox(height: 12),
                  // confirm Password
                  Obx(
                    () => TextfiledAuth(
                      controller: controller.confirmPasswordController,
                      obscureText: authController.obscureText.value,
                      data: "Confirm Password",
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

                  SizedBox(height: 12),
                  // button sign up
                  ButtonAuth(
                    data: "Sign Up",
                    onPressed: () => controller.signup(context),
                  ),

                  SizedBox(height: 12),
                  InwellAuth(
                      onTap: () {
                        Get.to(LoginPages());
                      },
                      text1: "Already have an account? ",
                      text2: "Log in"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
