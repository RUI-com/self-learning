// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/button_auth.dart';
import '../components/inwell_auth.dart';
import '../components/textfiled_auth.dart';

import '../controller/auth_controller.dart';
import '../controller/theme_controller.dart';
import 'signup_page.dart';

class LoginPages extends StatelessWidget {
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: themeController.switchValue.value
          ? themeController.lightBackground
          : themeController.darkBackground,
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: themeController.switchValue.value
                        ? themeController.postbackgroundlight
                        : themeController.postbackgrounddark,
                  ),
                  child: Column(
                    children: [
                      themeController.switchValue.value
                          ? Image.asset('assets/logo/logo-self.png')
                          : Image.asset('assets/logo/logo-self-darkmode.png'),

                      SizedBox(height: 12),
                      // Email field
                      TextfiledAuth(
                        controller: authController.emailController,
                        obscureText: false,
                        data: "Enter email",
                      ),
                      SizedBox(height: 12),
                      // Password field
                      Obx(
                        () => TextfiledAuth(
                          controller: authController.passwordController,
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
                      // Login button
                      ButtonAuth(
                        data: "Login",
                        onPressed: authController.login,
                      ),
                      SizedBox(height: 12),
                      // Other UI components (OR divider, Google sign-in, etc.)
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                  color: themeController.switchValue.value
                                      ? themeController.lightText
                                      : themeController.darkText),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          // Add Google Sign-in logic here
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/logo/4.png", width: 18),
                                const SizedBox(width: 10),
                                const Text(
                                  'Login using Gmail',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      InwellAuth(
                          onTap: () {
                            Get.to(SignupPage());
                          },
                          text1: "Don't have An Account? ",
                          text2: "Sign up"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
