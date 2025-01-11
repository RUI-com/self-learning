import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/profile_controller.dart';
import '../controller/theme_controller.dart';
import '../pages/other_profile.dart';
import '../pages/profile_page.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final ProfileController controller = Get.find();

  final authService = Supabase.instance.client.auth;

  final ThemeController themeController = Get.find();
  @override
  void initState() {
    super.initState();

    controller.fetchFollowing();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = authService.currentUser?.id ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.following.isEmpty) {
          return Center(child: Text('No following found.'));
        }

        return ListView.builder(
          itemCount: controller.following.length,
          itemBuilder: (context, index) {
            final follow = controller.following[index];

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: themeController.switchValue.value
                      ? themeController.lightBackground
                      : themeController.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(12),
                  leading: InkWell(
                    onTap: () {
                      // تحقق مما إذا كان البروفايل للمستخدم الحالي
                      if (follow['user_id'] == currentUserId) {
                        // انتقل إلى صفحة بروفايل المستخدم الحالي
                        Get.to(() => ProfileScreen());
                      } else {
                        // انتقل إلى صفحة بروفايل المستخدم الآخر
                        Get.to(() =>
                            OtherProfileScreen(userId: follow['user_id']));
                      }
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: follow['avatar_url'] != null
                          ? NetworkImage(follow['avatar_url'])
                          : null,
                      child: follow['avatar_url'] == null
                          ? Icon(Icons.person, size: 30, color: Colors.white)
                          : null,
                    ),
                  ),
                  title: Text(
                    follow['username'] ?? 'No Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeController.switchValue.value
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    "Tap to view profile",
                    style: TextStyle(
                      fontSize: 12,
                      color: themeController.switchValue.value
                          ? Colors.black54
                          : Colors.white70,
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
