// ignore_for_file: prefer_const_constructors, avoid_print, use_key_in_widget_constructors, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/other_profile.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons/uicons.dart';
import 'package:widgets_easier/widgets_easier.dart';

import '../Theme/color.dart';
import '../comment/comments_page.dart';
import '../components/heart_button.dart';

import '../components/like_comment.dart';
import '../components/save_icon.dart';
import '../controller/theme_controller.dart';
import '../pages/editpost_page.dart';
import '../pages/profile_page.dart';

class PostDetailPage extends StatelessWidget {
  final dynamic post;
  final String? currentUserId;

  PostDetailPage({required this.post, this.currentUserId});
  final ThemeController themeController = Get.find();
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
      Get.forceAppUpdate();
    } catch (e) {
      print("Error deleting post: $e");
      Get.snackbar("خطأ", "تعذر حذف المنشور");
    }
  }

  void showOwnerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text("تعديل المنشور"),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => EditPostPage(post: post));
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("حذف المنشور"),
              onTap: () async {
                Navigator.pop(context);
                await deletePost(post['id'].toString());
              },
            ),
          ],
        );
      },
    );
  }

  void showShareOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: Colors.green),
              title: Text("مشاركة المنشور"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> fetchComments(String postId) async {
    final supabaseClient = Supabase.instance.client;
    try {
      final response = await supabaseClient
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      print("Error fetching comments: $e");
      return [];
    }
  }

  Future<void> refreshData() async {
    await fetchComments(post['id'].toString());
    print("تم تحديث البيانات!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.switchValue.value
          ? themeController.postbackgroundlight
          : themeController.postbackgrounddark,
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // تحقق مما إذا كان البوست منشأ من حسابي الشخصي
                                    if (post['user_id'] == currentUserId) {
                                      // انتقل إلى صفحة البروفايل الخاصة بك
                                      Get.to(() => ProfileScreen());
                                    } else {
                                      // انتقل إلى صفحة البروفايل الخاصة بالمستخدم الآخر
                                      Get.to(() => OtherProfileScreen(
                                          userId: post['user_id']));
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
                                        gradient: LinearGradient(
                                            colors: [buttonc, buttonb]),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    child: Center(
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage:
                                            NetworkImage(post['user_avatar']),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['username'] ?? "مستخدم مجهول",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: themeController
                                                  .switchValue.value
                                              ? themeController.darkBackground
                                              : themeController
                                                  .lightBackground),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      post['created_at']?.substring(0, 10) ??
                                          "تاريخ غير معروف",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: themeController
                                                  .switchValue.value
                                              ? Colors.grey[700]
                                              : themeController.lightBackground,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // more
                            IconButton(
                              onPressed: () {
                                if (post['user_id'] == currentUserId) {
                                  showOwnerOptions(context);
                                } else {
                                  showShareOption(context);
                                }
                              },
                              icon: Icon(
                                UIcons.boldRounded.menu_dots_vertical,
                                color: themeController.switchValue.value
                                    ? themeController.darkBackground
                                    : themeController.lightBackground,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (post['image_url'] != null)
                          Hero(
                            tag: "post_${post['id']}",
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                post['image_url'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            HeartButton(),
                            SizedBox(width: 15),
                            InkWell(
                              onTap: () {
                                Get.to(() => CommentsPage(postId: post['id']));
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    UIcons.regularRounded.comment,
                                    color: themeController.switchValue.value
                                        ? themeController.darkBackground
                                        : themeController.lightBackground,
                                  ),
                                  FutureBuilder<int>(
                                    future: fetchCommentCount(
                                        post['id'].toString()),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "...",
                                            style: TextStyle(
                                              color: themeController
                                                      .switchValue.value
                                                  ? themeController
                                                      .darkBackground
                                                  : themeController
                                                      .lightBackground,
                                            ),
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "0",
                                            style: TextStyle(
                                              color: themeController
                                                      .switchValue.value
                                                  ? themeController
                                                      .darkBackground
                                                  : themeController
                                                      .lightBackground,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "${snapshot.data}",
                                            style: TextStyle(
                                              color: themeController
                                                      .switchValue.value
                                                  ? themeController
                                                      .darkBackground
                                                  : themeController
                                                      .lightBackground,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 320,
                              child: Text(
                                post['description'] ?? "لا يوجد وصف.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeController.switchValue.value
                                      ? themeController.darkBackground
                                      : themeController.lightBackground,
                                ),
                                softWrap: true, // خاصية الالتفاف
                                overflow: TextOverflow
                                    .visible, // النص سيظهر بالكامل عند الالتفاف
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1, // لتحديد سمك الـ Divider
                    indent: 10, // المسافة من الجهة اليسرى
                    endIndent: 10, // المسافة من الجهة اليمنى
                    color: themeController.switchValue.value
                        ? Colors.grey[300]
                        : themeController.lightBackground, // اللون
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: fetchComments(post['id'].toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text("حدث خطأ أثناء تحميل التعليقات."));
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return Center(
                            child: Text(
                          "no comment",
                          style: TextStyle(
                              color: themeController.switchValue.value
                                  ? themeController.darkBackground
                                  : themeController.lightBackground),
                        ));
                      } else {
                        final comments = snapshot.data!;
                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      comment['user_avatar'] ?? ''),
                                ),
                                title: Text(
                                  comment['username'] ?? "مستخدم مجهول",
                                  style: TextStyle(
                                      color: themeController.switchValue.value
                                          ? themeController.darkBackground
                                          : themeController.lightBackground),
                                ),
                                subtitle: Text(
                                  comment['comment_text'] ?? '',
                                  style: TextStyle(
                                      color: themeController.switchValue.value
                                          ? themeController.darkBackground
                                          : themeController.lightBackground),
                                ),
                                trailing: LikeComment());
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 400,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: themeController.switchValue.value
                      ? themeController.postbackgroundlight
                      : themeController
                          .postbackgrounddark, // لون خلفية الـ Container
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(0.1), // لون الظل مع شفافية
                      spreadRadius: 4, // مدى انتشار الظل
                      blurRadius: 5, // مدى ضبابية الظل
                      offset: Offset(2, 2), // إزاحة الظل أفقياً وعمودياً
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Action for back button
                          Get.back();
                        },
                        icon: Icon(
                          UIcons.regularStraight.angle_left,
                          color: themeController.switchValue.value
                              ? buttonb
                              : themeController.lightBackground,
                          size: 15,
                        ),
                        label: Text('BACK',
                            style: TextStyle(
                              color: themeController.switchValue.value
                                  ? buttonb
                                  : themeController.lightBackground,
                            )),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: themeController.switchValue.value
                              ? buttonb
                              : themeController.lightBackground,
                          backgroundColor: themeController.switchValue.value
                              ? themeController.postbackgroundlight
                              : themeController.postbackgrounddark,
                          elevation: 0,
                        ),
                      ),
                      Row(
                        children: [
                          SaveIcon(),
                          IconButton(
                            icon: Icon(UIcons.regularStraight.share,
                                color: themeController.switchValue.value
                                    ? themeController.darkBackground
                                    : themeController.lightBackground),
                            onPressed: () {
                              // Action for share
                            },
                            hoverColor: themeController.switchValue.value
                                ? Colors.grey[300]
                                : themeController.lightBackground,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
