// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, unnecessary_null_comparison, use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last, deprecated_member_use, await_only_futures

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/change_password_page.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons/uicons.dart';
import 'dart:io'; // استيراد مكتبة التعامل مع الملفات

import '../Theme/color.dart';
import '../controller/auth_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/signup_controller.dart';
import '../controller/theme_controller.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthController authController = Get.put(AuthController());
  final SignupController signupController = Get.put(SignupController());
  final _supabase = Supabase.instance.client;
  final ProfileController controller = Get.put(ProfileController());
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final ThemeController themeController = Get.find();
  String? _avatarUrl;
  File? _imageFile; // ملف الصورة الملتقطة

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await _supabase
          .from('users_profile')
          .select()
          .eq('user_id', user.id)
          .single();
      if (response != null && mounted) {
        // Check if widget is still mounted
        setState(() {
          _avatarUrl = response['avatar_url'];
          _usernameController.text = response['username'] ?? '';
          _emailController.text = response['user_email'] ?? '';
        });
      }
    }
  }

  // اختيار صورة
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    // التحقق من اختيار الصورة
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an avatar image")),
      );
      return;
    }

    try {
      // Define the path and file name
      final fileName = 'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Use the 'upload' method to upload the file
      final response =
          await _supabase.storage.from('image').upload(fileName, _imageFile!);

      // Ensure the response is of the correct type (PostgrestResponse)
      if (response != null) {
        // الحصول على رابط الصورة
        final avatarUrl =
            await _supabase.storage.from('image').getPublicUrl(fileName);

        // فقط إذا تم تغيير الصورة
        if (avatarUrl != _avatarUrl && mounted) {
          // Check if still mounted
          setState(() {
            _avatarUrl = avatarUrl;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _updateUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final userId = user.id;
      final currentResponse = await _supabase
          .from('users_profile')
          .select()
          .eq('user_id', userId)
          .single();

      if (currentResponse != null) {
        Map<String, dynamic> updatedFields = {};

        // Check if username is changed
        if (_usernameController.text != currentResponse['username']) {
          updatedFields['username'] = _usernameController.text;
        }

        // Check if email is changed
        if (_emailController.text != currentResponse['user_email']) {
          updatedFields['user_email'] = _emailController.text;
        }

        // Check if avatar_url is changed
        if (_avatarUrl != currentResponse['avatar_url']) {
          updatedFields['avatar_url'] = _avatarUrl;

          // تحديث الـ avatar_url في جدول الـ posts
          await _supabase
              .from('posts')
              .update({'user_avatar': _avatarUrl}).eq('user_id', userId);
        }

        if (updatedFields.isNotEmpty) {
          await _supabase
              .from('users_profile')
              .update(updatedFields)
              .eq('user_id', userId);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated!')),
          );
          Get.back();
        }
      }
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
        elevation: 0,
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        actions: [
          TextButton(
            onPressed: () {
              _updateUserProfile();
              _uploadImage();
            },
            child: Text(
              'Save',
              style: TextStyle(
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText,
                  fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: themeController.switchValue.value
                            ? themeController.lightText
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Obx(() => CircleAvatar(
                                    radius: 60,
                                    backgroundImage: controller
                                            .avatarUrl.value.isNotEmpty
                                        ? NetworkImage(
                                            controller.avatarUrl.value)
                                        : AssetImage(
                                                'assets/logo/default_avatar.png')
                                            as ImageProvider,
                                  ))),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'PROFILE PHOTO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: themeController.switchValue.value
                    ? themeController.lightText
                    : Colors.grey,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              style: TextStyle(
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText),
              controller: _usernameController,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText),
                labelText: 'NAME',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                suffixIcon: Icon(
                  UIcons.boldRounded.angle_right,
                  size: 15,
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              style: TextStyle(
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText),
              controller: _emailController,
              decoration: InputDecoration(
                labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText),
                labelText: 'EMAIL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(style: BorderStyle.none),
                ),
                suffixIcon: Icon(
                  UIcons.boldRounded.angle_right,
                  size: 15,
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText,
                ),
              ),
            ),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                Get.to(ChangePasswordPage());
              },
              child: Text(
                'Change Password',
                style: TextStyle(
                    color: themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                    color: themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
