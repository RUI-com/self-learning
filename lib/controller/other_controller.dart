// ignore_for_file: avoid_print, unnecessary_null_comparison, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OtherController extends GetxController {
  final supabaseClient = Supabase.instance.client;

  var username = ''.obs;
  var avatarUrl = ''.obs;
  var followingCount = 0.obs;
  var followersCount = 0.obs;
  var posts = <Map<String, dynamic>>[].obs;
  var isFriend = false.obs;
  var isLoading = true.obs;
  Future<void> fetchProfileDataByUserId(String userId) async {
    try {
      isLoading.value = true;

      final profileResponse = await supabaseClient
          .from('users_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (profileResponse != null) {
        username.value = profileResponse['username'] ?? '';
        avatarUrl.value = profileResponse['avatar_url'] ?? '';
      }

      final followingResponse = await supabaseClient
          .from('friends')
          .select('friend_id')
          .eq('user_id', userId);

      followingCount.value = followingResponse?.length ?? 0;

      final followersResponse = await supabaseClient
          .from('friends')
          .select('user_id')
          .eq('friend_id', userId);

      followersCount.value = followersResponse?.length ?? 0;
    } catch (e) {
      print("Error fetching profile data: $e");
    } finally {
      // بعد اكتمال البناء، قم بتحديث isLoading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isLoading.value = false;
      });
    }
  }

  Future<void> fetchPosts(String userId) async {
    try {
      isLoading.value = true;

      final response =
          await supabaseClient.from('posts').select().eq('user_id', userId);

      posts.value = List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      print("Error fetching posts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkFriendStatus(String userId) async {
    try {
      final response = await supabaseClient
          .from('friends')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('friend_id', userId)
          .single();

      isFriend.value = response != null;
    } catch (e) {
      isFriend.value = false;
    }
  }

  Future<void> addFriend(String userId) async {
    try {
      await supabaseClient.from('friends').insert({
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'friend_id': userId,
      });
      isFriend.value = true;

      Get.snackbar(
        "Success", // العنوان
        "Friend added!", // الرسالة
        snackPosition: SnackPosition.BOTTOM, // مكان الإشعار
        duration: Duration(seconds: 3), // مدة الإشعار
      );
    } catch (e) {
      print("Error adding friend: $e");
    }
  }

  Future<void> removeFriend(String userId) async {
    try {
      await supabaseClient
          .from('friends')
          .delete()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('friend_id', userId);

      isFriend.value = false;

      Get.snackbar(
        "Success", // العنوان
        "Friend removed!", // الرسالة
        snackPosition: SnackPosition.BOTTOM, // مكان الإشعار
        duration: Duration(seconds: 3), // مدة الإشعار
      );
    } catch (e) {
      print("Error removing friend: $e");
    }
  }
}
