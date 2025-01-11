// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';
import '../pages/other_profile.dart'; // إضافة استيراد صفحة البروفايل الأخرى
import '../controller/theme_controller.dart';

class FollowersPage extends StatefulWidget {
  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  final ProfileController controller = Get.find();

  final ThemeController themeController = Get.find();

  @override
  void initState() {
    super.initState();

    controller.fetchFollowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.followers.isEmpty) {
          return Center(child: Text('No followers found.'));
        }

        return ListView.builder(
          itemCount: controller.followers.length,
          itemBuilder: (context, index) {
            final follower = controller.followers[index];

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: GestureDetector(
                    onTap: () {
                      // عند الضغط على صورة البروفايل يتم الانتقال إلى صفحة بروفايل المستخدم المتابع
                      Get.to(() =>
                          OtherProfileScreen(userId: follower['user_id']));
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: follower['avatar_url'] != null
                          ? NetworkImage(follower['avatar_url'])
                          : null,
                      child: follower['avatar_url'] == null
                          ? Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () {
                      // عند الضغط على اسم المستخدم يتم الانتقال إلى صفحة بروفايل المستخدم المتابع
                      Get.to(() =>
                          OtherProfileScreen(userId: follower['user_id']));
                    },
                    child: Text(
                      follower['username'] ?? 'No Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    "Tap to view profile",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
