// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons/uicons.dart';

import '../Theme/color.dart';
import '../comment/comments_page.dart';
import '../controller/theme_controller.dart';
import '../detail/post_detail_page.dart';
import '../pages/editpost_page.dart';
import '../pages/other_profile.dart';
import '../pages/profile_page.dart';
import 'heart_button.dart';
import 'package:widgets_easier/widgets_easier.dart';

import 'save_icon.dart';

class PostItem extends StatelessWidget {
  final dynamic post;
  final String currentUserId;

  PostItem({required this.post, required this.currentUserId});

  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    Future<int> fetchCommentCount(String postId) async {
      final supabaseClient = Supabase.instance.client;
      try {
        final response = await supabaseClient
            .from('comments')
            .select('id')
            .eq('post_id', postId);
        return response.length;
      } catch (e) {
        print("Error fetching comment count: $e");
        return 0;
      }
    }

    Future<void> deletePost(String postId) async {
      final supabaseClient = Supabase.instance.client;
      try {
        await supabaseClient.from('posts').delete().eq('id', postId);
        Get.snackbar("تم الحذف", "تم حذف المنشور بنجاح");
        // قم بتحديث الصفحة بعد الحذف
        Get.forceAppUpdate(); // أو قم باستدعاء المنطق الخاص بك لإعادة تحميل البيانات
      } catch (e) {
        print("Error deleting post: $e");
        Get.snackbar("خطأ", "تعذر حذف المنشور");
      }
    }

    void showOwnerOptions(BuildContext context) {
      final ThemeController themeController = Get.find();
      showModalBottomSheet(
        backgroundColor: themeController.switchValue.value
            ? themeController.postbackgroundlight
            : themeController.postbackgrounddark,
        context: context,
        builder: (context) {
          return Container(
            color: themeController.switchValue.value
                ? themeController.lightBackground
                : themeController.darkBackground,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue),
                  title: Text(
                    "تعديل المنشور",
                    style: TextStyle(
                        color: themeController.switchValue.value
                            ? themeController.lightText
                            : themeController.darkText),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => EditPostPage(post: post));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    "حذف المنشور",
                    style: TextStyle(
                        color: themeController.switchValue.value
                            ? themeController.lightText
                            : themeController.darkText),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await deletePost(post['id'].toString());
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    void showShareOption(BuildContext context) {
      final ThemeController themeController = Get.find();
      showModalBottomSheet(
        backgroundColor: themeController.switchValue.value
            ? themeController.postbackgroundlight
            : themeController.postbackgrounddark,
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share, color: Colors.green),
                title: Text(
                  "مشاركة المنشور",
                  style: TextStyle(
                      color: themeController.switchValue.value
                          ? themeController.lightText
                          : themeController.darkText),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // منطق المشاركة
                },
              ),
            ],
          );
        },
      );
    }

    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeController.switchValue.value
            ? themeController.postbackgroundlight
            : themeController.postbackgrounddark, // لون الخلفية أبيض
        borderRadius: BorderRadius.circular(18), // حواف دائرية
        boxShadow: [
          BoxShadow(
            color: themeController.switchValue.value
                ? themeController.lightBackground
                : themeController.darkBackground,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // more icon
              IconButton(
                onPressed: () {
                  if (post['user_id'] == currentUserId) {
                    showOwnerOptions(context);
                  } else {
                    showShareOption(context);
                  }
                },
                icon: Icon(
                  Icons.more_horiz,
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText,
                ),
              ),
              // profile image
              InkWell(
                onTap: () {
                  // تحقق مما إذا كان البوست منشأ من حسابي الشخصي
                  if (post['user_id'] == currentUserId) {
                    // انتقل إلى صفحة البروفايل الخاصة بك
                    Get.to(() => ProfileScreen());
                  } else {
                    // انتقل إلى صفحة البروفايل الخاصة بالمستخدم الآخر
                    Get.to(() => OtherProfileScreen(userId: post['user_id']));
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    shape: DashedBorder(
                      width: 3,
                      dashSize: 10,
                      dashSpacing: 3,
                      gradient: LinearGradient(colors: [
                        buttonc,
                        buttonb,
                      ]),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(post['user_avatar']),
                    ),
                  ),
                ),
              ),
              // save icon
              SaveIcon(),
            ],
          ),
          SizedBox(height: 10),
          // post image
          InkWell(
            onTap: () {
              // التنقل إلى صفحة تفاصيل المنشور
              Get.to(() => PostDetailPage(
                    post: post,
                    currentUserId: currentUserId,
                  ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(post['image_url']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(post['username'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: themeController.switchValue.value
                          ? themeController.lightText
                          : themeController.darkText)),
              // like an comment
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(() => CommentsPage(postId: post['id']));
                    },
                    child: Row(
                      children: [
                        Icon(
                          UIcons.regularRounded.comment,
                          color: themeController.switchValue.value
                              ? themeController.lightText
                              : themeController.darkText,
                        ),
                        FutureBuilder<int>(
                          future: fetchCommentCount(post['id'].toString()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "...",
                                  style: TextStyle(
                                      color: themeController.switchValue.value
                                          ? themeController.lightText
                                          : themeController.darkText),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "0",
                                  style: TextStyle(
                                      color: themeController.switchValue.value
                                          ? themeController.lightText
                                          : themeController.darkText),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "${snapshot.data}",
                                  style: TextStyle(
                                      color: themeController.switchValue.value
                                          ? themeController.lightText
                                          : themeController.darkText),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15),
                  HeartButton(),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),

          Text(
            post['created_at'].substring(0, 10),
            style: TextStyle(
                color: themeController.switchValue.value
                    ? buttonb
                    : themeController.darkText,
                fontSize: 12),
          ),
        ],
      ),
    );
  }
}
