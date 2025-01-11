// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../chat/chat_screen.dart';
import '../components/otherProfile/profilebutton.dart';
import '../components/otherProfile/profilestat.dart';
import '../controller/other_controller.dart';
import '../controller/profile_controller.dart';
import '../controller/theme_controller.dart';
import '../detail/post_detail_page.dart';
import '../otherfrind/followerspage.dart';
import '../otherfrind/followingpage.dart';

class OtherProfileScreen extends StatelessWidget {
  final String userId;
  final ProfileController profileController = Get.put(ProfileController());
  final OtherController controller = Get.put(OtherController());
  final ThemeController themeController = Get.find();

  OtherProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    controller.fetchProfileDataByUserId(userId);
    controller.fetchPosts(userId);
    controller.checkFriendStatus(userId);

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: themeController.switchValue.value
                          ? themeController.darkBackground
                          : themeController.lightBackground,
                    ),
                  ),
                ],
              ),
              // Profile Info
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() {
                          return ProfileStat(
                            label: 'Following',
                            count: controller.followingCount.value,
                            onTap: () {
                              Get.off(() => FollowingPage(
                                  userId:
                                      userId)); // الانتقال إلى صفحة المتابعين
                            },
                          );
                        }),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: controller
                                      .avatarUrl.value.isNotEmpty
                                  ? NetworkImage(controller.avatarUrl.value)
                                  : AssetImage('assets/logo/default_avatar.png')
                                      as ImageProvider,
                            ),
                            SizedBox(height: 10),
                            Text(
                              controller.username.value,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: themeController.switchValue.value
                                    ? themeController.darkBackground
                                    : themeController.lightBackground,
                              ),
                            ),
                            Text(
                              '@${controller.username.value}',
                              style: TextStyle(
                                color: themeController.switchValue.value
                                    ? Colors.grey
                                    : themeController.lightBackground,
                              ),
                            ),
                          ],
                        ),
                        Obx(() {
                          return ProfileStat(
                            label: 'Followers',
                            count: controller.followersCount.value,
                            onTap: () {
                              Get.off(() => FollowersPage(
                                  userId:
                                      userId)); // الانتقال إلى صفحة المتابعين
                            },
                          );
                        }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ProfileButton(
                          label:
                              controller.isFriend.value ? 'Unfollow' : 'Follow',
                          onTap: () {
                            if (controller.isFriend.value) {
                              controller.removeFriend(userId);
                            } else {
                              controller.addFriend(userId);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: controller.isFriend.value
                                ? Colors.transparent
                                : Colors.blue,
                          ),
                        ),
                        SizedBox(width: 10),
                        ProfileButton(
                          label: 'Contact',
                          onTap: () {
                            String senderId =
                                profileController.supabase.auth.currentUser!.id;
                            String receiverId = userId;

                            if (senderId != receiverId) {
                              Get.to(() => ChatScreen(
                                  senderId: senderId,
                                  receiverId: receiverId,
                                  receiverName: controller.username.value,
                                  receiverAvatarUrl:
                                      controller.avatarUrl.value));
                            } else {
                              print("لا يمكن التواصل مع نفسك!");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("لا يمكنك التواصل مع نفسك!")),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: BorderSide(
                              color: themeController.switchValue.value
                                  ? Colors.grey
                                  : themeController.lightBackground,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              // Posts
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final post = controller.posts[index];
                  return post['image_url'] != null
                      ? InkWell(
                          onTap: () {
                            Get.to(() => PostDetailPage(
                                  post: post,
                                  currentUserId: controller.supabaseClient.auth
                                          .currentUser?.id ??
                                      "",
                                ));
                          },
                          child: Image.network(
                            post['image_url'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
