// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Theme/color.dart';
import '../controller/post_controller.dart';
import '../controller/theme_controller.dart';
import '../main_screen.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final PostController _controller = PostController();
  final ThemeController themeController = Get.find();
  bool isLoading = false; // حالة التحميل

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _uploadPost() {
    setState(() {
      isLoading = true;
    });

    _controller.uploadPost(
      () {
        setState(() {
          isLoading = false;
        });
        _showMessage("Post uploaded successfully!");
        Get.off(MainScreen());
      },
      (error) {
        setState(() {
          isLoading = false;
        });
        _showMessage(error);
      },
    );
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
        title: Text("Add Post", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  await _controller.pickImage();
                  setState(() {});
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: themeController.switchValue.value
                        ? Colors.grey[200]
                        : themeController.postbackgrounddark,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _controller.imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _controller.imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child:
                              Icon(Icons.add_a_photo, size: 40, color: buttonb),
                        ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller.descriptionController,
                maxLines: 4,
                style: TextStyle(
                    color: themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText),
                decoration: InputDecoration(
                  labelText: "",
                  labelStyle: TextStyle(color: buttonb),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  filled: true,
                  fillColor: themeController.switchValue.value
                      ? Colors.grey[100]
                      : themeController.postbackgrounddark,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: isLoading ? null : _uploadPost,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : buttonb,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: buttonb.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : Text(
                            "Add Post",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
