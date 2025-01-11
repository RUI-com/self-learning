// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentsController extends GetxController {
  final int postId;
  CommentsController({required this.postId});

  final supabaseClient = Supabase.instance.client;
  final TextEditingController commentController = TextEditingController();
  List<dynamic> comments = [];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  Future<void> fetchComments() async {
    isLoading = true;
    update();
    try {
      final response = await supabaseClient
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      comments = response as List<dynamic>;
    } catch (e) {
      print("Error fetching comments: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> addComment() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null || commentController.text.isEmpty) return;

    try {
      final userProfile = await supabaseClient
          .from('users_profile')
          .select()
          .eq('user_id', user.id)
          .single();

      await supabaseClient.from('comments').insert({
        'post_id': postId,
        'user_id': user.id,
        'username': userProfile['username'] ?? 'Unknown',
        'user_avatar': userProfile['avatar_url'] ?? '',
        'comment_text': commentController.text,
      });
      commentController.clear();
      fetchComments();
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final response =
          await supabaseClient.from('comments').delete().eq('id', commentId);

      if (response != null && response.error != null) {
        // في حال وجود خطأ في الاستجابة
        print("Error deleting comment: ${response.error!.message}");
        Get.snackbar("خطأ", "تعذر حذف التعليق");
      } else {
        // في حال الحذف بنجاح
        Get.snackbar("تم الحذف", "تم حذف التعليق بنجاح");
        comments.removeWhere((comment) => comment['id'] == commentId);
        update();
        // بعد الحذف، قم بتحديث التعليقات من قاعدة البيانات للتأكد من التحديث بشكل صحيح
        fetchComments();
      }
    } catch (e) {
      // في حال حدوث أي استثناء
      print("Error deleting comment: $e");
      Get.snackbar("خطأ", "تعذر حذف التعليق");
    }
  }

  Future<void> updateComment(int commentId, String newText) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;

    try {
      await supabaseClient
          .from('comments')
          .update({'comment_text': newText})
          .eq('id', commentId)
          .eq('user_id', user.id);
      fetchComments();
    } catch (e) {
      print("Error updating comment: $e");
    }
  }

  void handlePopupMenuSelection(String value, dynamic comment) {
    switch (value) {
      case 'edit':
        _handleEditComment(comment);
        break;
      case 'delete':
        _handleDeleteComment(comment);
        break;
      default:
        print("Unknown action: $value");
    }
  }

  void _handleEditComment(dynamic comment) {
    TextEditingController editController =
        TextEditingController(text: comment['comment_text']);
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text("Edit Comment"),
        content: TextField(
          controller: editController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              updateComment(comment['id'], editController.text);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteComment(dynamic comment) {
    final commentId = comment['id'];

    // تحقق من وجود الـ ID قبل محاولة الحذف
    if (commentId != null) {
      deleteComment(commentId);
    } else {
      print("Error: Comment ID is null");
    }
  }
}
