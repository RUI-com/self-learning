// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_controller.dart';
import 'courseweb_viewpage.dart';

class CourseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> course;

  CourseDetailsPage({super.key, required this.course});
  final ThemeController themeController = Get.find();

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
        title: Text(
          course['course_name'] ?? 'Course Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            // أيقونة الكورس مع دائرة تحميل وحواف دائرية
            course['course_img'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20), // حواف دائرية
                    child: Image.network(
                      course['course_img'],
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // إذا تم تحميل الصورة، تعرض الصورة نفسها.
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null, // نسبة التحميل
                            ),
                          ); // تعرض دائرة تحميل أثناء التحميل.
                        }
                      },
                      fit: BoxFit.cover,
                      height: 200, // لتحديد ارتفاع الصورة
                      width: double.infinity, // لجعل الصورة بعرض كامل
                    ),
                  )
                : const Icon(Icons.image_not_supported, size: 100),
            const SizedBox(height: 16),
            // اسم المدرب (كتابة من اليمين لليسار)
            Text(
              'اسم المدرب: ${course['instructor_name'] ?? 'غير معروف'}',
              style: const TextStyle(fontSize: 18),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            // تفاصيل الكورس (كتابة من اليمين لليسار)
            Text(
              course['course_details'] ?? 'لا توجد تفاصيل',
              style: const TextStyle(fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            // زر لعرض الكورس في WebView
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseWebViewPage(url: course['course_link'] ?? ''),
                    ),
                  );
                },
                child: Text(
                  'عرض الكورس',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
