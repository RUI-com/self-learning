// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, avoid_print
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../chat/chat_list_screen.dart';
import '../components/post_item.dart';
import '../controller/theme_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = Supabase.instance.client.auth;
  final supabaseClient = Supabase.instance.client;
  List<dynamic> posts = [];
  bool isLoading = true;
  final ThemeController themeController = Get.find();
  @override
  void initState() {
    super.initState();
    fetchPosts(); // تحميل البيانات الأولية
  }

  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      // استخدام select فقط بدون execute()
      final response = await supabaseClient
          .from('posts')
          .select() // select بدون الحاجة لـ execute()
          .order('created_at', ascending: false); // ترتيب حسب تاريخ الإنشاء

      // التعامل مع البيانات مباشرة
      if (response.isNotEmpty) {
        setState(() {
          posts = response as List<dynamic>; // استخراج البيانات بشكل صحيح
        });
      } else {
        print("No posts found");
      }
    } catch (e) {
      // التعامل مع الأخطاء بشكل عام فقط
      print("Error fetching posts: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
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
        leading: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Image.asset(
              "assets/logo/self learning-logo.png",
              width: 40,
            ),
          ],
        ),
        title: Obx(
          () => themeController.switchValue.value
              ? Image.asset(
                  "assets/logo/world-self.png",
                  width: 100,
                )
              : Image.asset(
                  "assets/logo/world-self-darkmode.png",
                  width: 100,
                ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => ChatListScreen());
            },
            icon: Icon(
              UIcons.regularRounded.paper_plane,
              size: 20,
              color: themeController.switchValue.value
                  ? themeController.lightText
                  : themeController.darkText,
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchPosts,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];

                  // استخراج معرف المستخدم الحالي
                  final currentUserId = authService.currentUser?.id ?? "";

                  return PostItem(
                    post: post,
                    currentUserId: currentUserId, // تمرير currentUserId هنا
                  );
                },
              ),
            ),
    );
  }
}
