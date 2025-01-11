// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, unused_element, sort_child_properties_last, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons/uicons.dart';

import '../components/gridview_posts.dart';
import '../controller/profile_controller.dart';
import '../controller/theme_controller.dart';
import '../detail/post_detail_page.dart';
import '../frinds/followers_page.dart';
import '../frinds/following_page.dart';
import 'edit_profile_page.dart';
import 'login_pages.dart';
import 'settings_page.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.put(ProfileController());
  final ThemeController themeController = Get.find();
  final authService = Supabase.instance.client.auth;

  final supabaseClient = Supabase.instance.client;
  List<dynamic> posts = [];
  void logout() async {
    await authService.signOut();
    Get.off(LoginPages());
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller.fetchProfileData();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    controller.fetchProfileData();
    setState(() {
      isLoading = true;
    });
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return;

      final response =
          await supabaseClient.from('posts').select().eq('user_id', user.id);

      // استخدام select فقط بدون execute()

      // التعامل مع البيانات مباشرة
      if (response.isNotEmpty) {
        setState(() {
          posts = List<Map<String, dynamic>>.from(response ?? []);
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchPosts,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Get.to(() => SettingsPage());
                              },
                              icon: Icon(
                                UIcons.regularStraight.settings,
                                color: themeController.switchValue.value
                                    ? themeController.darkBackground
                                    : themeController.lightBackground,
                              )),
                          IconButton(
                            onPressed: logout,
                            icon: Icon(Icons.logout,
                                size: 25,
                                color: themeController.switchValue.value
                                    ? themeController.darkBackground
                                    : themeController.lightBackground),
                          ),
                        ],
                      ),
                      // Profile Header
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => GestureDetector(
                                      onTap: () =>
                                          Get.to(() => FollowingPage()),
                                      child: _ProfileStat(
                                        label: 'Following',
                                        count: controller.followingCount.value,
                                      ),
                                    )),
                                Column(
                                  children: [
                                    Obx(() => CircleAvatar(
                                          radius: 60,
                                          backgroundImage: controller
                                                  .avatarUrl.value.isNotEmpty
                                              ? NetworkImage(
                                                  controller.avatarUrl.value)
                                              : AssetImage(
                                                      'assets/logo/default_avatar.png')
                                                  as ImageProvider,
                                        )),
                                    SizedBox(height: 10),
                                    Obx(() => Text(
                                          controller.username.value,
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: themeController
                                                      .switchValue.value
                                                  ? themeController
                                                      .darkBackground
                                                  : themeController
                                                      .lightBackground),
                                        )),
                                    Obx(() => Text(
                                          '@${controller.username.value}',
                                          style: TextStyle(
                                              color: themeController
                                                      .switchValue.value
                                                  ? Colors.grey
                                                  : themeController
                                                      .lightBackground),
                                        )),
                                    SizedBox(height: 20),
                                  ],
                                ),
                                Obx(() => GestureDetector(
                                      onTap: () =>
                                          Get.to(() => FollowersPage()),
                                      child: _ProfileStat(
                                        label: 'Followers',
                                        count: controller.followersCount.value,
                                      ),
                                    )),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ProfileButton(
                                    label: 'Edit Profile',
                                    onTap: () {
                                      Get.to(EditProfilePage());
                                    }),
                                SizedBox(width: 10),
                                _ProfileButton(label: 'Contact', onTap: () {}),
                              ],
                            ),
                          ],
                        ),
                      ),

                      GridviewPosts(), // مرر

                      // Posts Grid Section
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 columns
                          childAspectRatio: 1, // Square images
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          // استخراج معرف المستخدم الحالي
                          final currentUserId =
                              authService.currentUser?.id ?? "";

                          return post['image_url'] != null
                              ? InkWell(
                                  onTap: () {
                                    // التنقل إلى صفحة تفاصيل المنشور
                                    Get.to(() => PostDetailPage(
                                          post: post,
                                          currentUserId: currentUserId,
                                        ));
                                  },
                                  child: Image.network(
                                    post['image_url'],
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(); // Placeholder for posts without images
                        },
                      ),
                    ],
                  ),
                ),
              ));
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final int count;

  _ProfileStat({required this.label, required this.count});
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.switchValue.value
                    ? themeController.darkBackground
                    : themeController.lightBackground)),
        Text(label,
            style: TextStyle(
                color: themeController.switchValue.value
                    ? Colors.grey
                    : themeController.lightBackground)),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  _ProfileButton({required this.label, required this.onTap});
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
            color: themeController.switchValue.value
                ? Colors.grey[700]
                : themeController.lightBackground),
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(
            color: themeController.switchValue.value
                ? Colors.grey
                : themeController.lightBackground),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  _CategoryChip({required this.label});
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: TextStyle(
          color: themeController.switchValue.value
              ? themeController.darkBackground
              : themeController.lightBackground),
      backgroundColor: themeController.switchValue.value
          ? Colors.grey[700]
          : themeController.lightBackground,
    );
  }
}
