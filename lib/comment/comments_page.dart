// ignore_for_file: prefer_const_constructors, use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Theme/color.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/comments_controller.dart';
import '../controller/theme_controller.dart';

class CommentsPage extends StatelessWidget {
  final int postId;
  CommentsPage({required this.postId, Key? key}) : super(key: key);
  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentsController>(
      init: CommentsController(postId: postId),
      builder: (controller) {
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
            title: Text("Comment page"),
            centerTitle: true,
          ),
          body: controller.isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.comments.length,
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          final isMyComment = comment['user_id'] ==
                              Supabase.instance.client.auth.currentUser?.id;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  comment['user_avatar'] ??
                                      'https://via.placeholder.com/150'),
                            ),
                            title: Text(
                              comment['username'],
                              style: TextStyle(
                                  color: themeController.switchValue.value
                                      ? themeController.lightText
                                      : themeController.darkText),
                            ),
                            subtitle: Text(
                              comment['comment_text'],
                              style: TextStyle(
                                  color: themeController.switchValue.value
                                      ? themeController.lightText
                                      : themeController.darkText),
                            ),
                            trailing: isMyComment
                                ? PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: themeController.switchValue.value
                                          ? themeController.lightText
                                          : themeController.darkText,
                                    ),
                                    onSelected: (value) =>
                                        controller.handlePopupMenuSelection(
                                            value, comment),
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.commentController,
                              style: TextStyle(
                                  color: themeController.switchValue.value
                                      ? themeController.lightText
                                      : themeController.darkText),
                              decoration: InputDecoration(
                                hintText: 'write comment here ...',
                                hintStyle: TextStyle(color: buttonb),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: buttonb,
                            ),
                            onPressed: controller.addComment,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
