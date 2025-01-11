import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // تأكد من تثبيت مكتبة supabase_flutter
import 'package:uicons/uicons.dart';

import '../controller/theme_controller.dart';
import '../course/course_detailspage.dart';
import '../course/map_code.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final supabase = Supabase.instance.client; // Supabase client
  List<dynamic> courses = []; // لتخزين بيانات الكورسات
  final ThemeController themeController = Get.find();
  @override
  void initState() {
    super.initState();
    fetchCourses(); // استدعاء البيانات عند فتح الصفحة
  }

  // جلب بيانات الكورسات من Supabase
  Future<void> fetchCourses() async {
    final response = await supabase.from('courses').select();
    if (response != null) {
      setState(() {
        courses = response as List<dynamic>; // تأكد من تحويل البيانات إلى قائمة
      });
    } else {
      print('Error fetching courses: No data returned');
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
        title: const Text('Courses'),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Get.to(MapCode(
                url: 'https://roadmap.sh/',
              ));
            },
            child: Icon(UIcons.regularStraight.map_marker),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: courses.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // عرض المربعات اثنين في كل صف
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailsPage(course: course),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeController.switchValue.value
                          ? themeController.postbackgroundlight
                          : themeController.postbackgrounddark,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: themeController.switchValue.value
                              ? themeController.lightBackground
                              : themeController.darkBackground,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // أيقونة الكورس
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          child: Image.network(
                            course['course_icon'],
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child; // إذا تم تحميل الصورة بالكامل، تعرض الصورة.
                              } else {
                                return const Center(
                                  child:
                                      CircularProgressIndicator(), // تعرض دائرة تحميل أثناء التحميل.
                                );
                              }
                            },
                            fit: BoxFit.cover, // لتتناسب الصورة مع الأيقونة.
                          ),
                        ),

                        // اسم الكورس
                        Text(
                          course['course_name'] ?? 'No Name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
