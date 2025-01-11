// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, unused_local_variable, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Theme/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/theme_controller.dart';
import '../main_screen.dart';

class EditPostPage extends StatefulWidget {
  final dynamic post;

  const EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ThemeController themeController = Get.find();
  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.post['description'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updatePost() async {
    final supabaseClient = Supabase.instance.client;

    String? imageUrl;

    // إذا تم اختيار صورة جديدة، ارفعها
    if (_selectedImage != null) {
      try {
        final fileName =
            'uploads/${DateTime.now().millisecondsSinceEpoch}.jpg'; // استخدام مجلد uploads داخل الحاوية image
        final response = await supabaseClient.storage
            .from('image') // اسم الحاوية هو image
            .upload(fileName, _selectedImage!);

        // الحصول على رابط الصورة المرفوعة
        imageUrl = supabaseClient.storage
            .from('image') // اسم الحاوية هو image
            .getPublicUrl(fileName); // الحصول على الرابط العام للصورة
      } catch (e) {
        print("Error uploading image: $e");
        Get.snackbar("خطأ", "تعذر رفع الصورة.");
        return;
      }
    }

    // تحديث بيانات المنشور باستخدام update
    try {
      await supabaseClient.from('posts').update({
        'description': _descriptionController.text,
        if (imageUrl != null) 'image_url': imageUrl,
      }).eq('id', widget.post['id']); // تحديد المنشور الذي سيتم تحديثه;

      // إذا تم التحديث بنجاح
      Get.snackbar("نجاح", "تم تعديل المنشور بنجاح.");
      Get.offAll(MainScreen()); // العودة إلى الصفحة الرئيسية بعد الحفظ
    } catch (e) {
      print("Error updating post: $e");
      Get.snackbar("خطأ", "تعذر تعديل المنشور.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.switchValue.value
          ? themeController.lightBackground
          : themeController.darkBackground,
      appBar: AppBar(
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        foregroundColor: themeController.switchValue.value
            ? themeController.lightText
            : themeController.darkText,
        title: Text("Edit Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updatePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        widget.post['image_url'],
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              style: TextStyle(
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText),
              decoration: InputDecoration(
                labelText: "description",
                labelStyle: TextStyle(color: buttonb),
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
