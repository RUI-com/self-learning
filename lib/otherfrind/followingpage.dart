// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/other_profile.dart';
import '../pages/profile_page.dart';

class FollowingPage extends StatelessWidget {
  final String userId;
  final supabaseClient = Supabase.instance.client;

  FollowingPage({required this.userId});
  final authService = Supabase.instance.client.auth;
  @override
  Widget build(BuildContext context) {
    final currentUserId = authService.currentUser?.id ?? "";
    return Scaffold(
      appBar: AppBar(
        title: Text("Following"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFollowing(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final followingList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: followingList.length,
            itemBuilder: (context, index) {
              final followingUser = followingList[index];
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    if (followingUser['user_id'] == currentUserId) {
                      // انتقل إلى صفحة بروفايل المستخدم الحالي
                      Get.to(() => ProfileScreen());
                    } else {
                      // انتقل إلى صفحة بروفايل المستخدم الآخر
                      Get.to(() =>
                          OtherProfileScreen(userId: followingUser['user_id']));
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(followingUser['avatar_url'] ?? ''),
                  ),
                ),
                title: Text(followingUser['username']),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFollowing(String userId) async {
    try {
      final response = await supabaseClient
          .from('friends')
          .select('friend_id')
          .eq('user_id', userId);

      final followingIds = response ?? [];
      List<Map<String, dynamic>> followingUsers = [];

      for (var id in followingIds) {
        final userResponse = await supabaseClient
            .from('users_profile')
            .select()
            .eq('user_id', id['friend_id'])
            .maybeSingle();

        if (userResponse != null) {
          followingUsers.add(userResponse);
        }
      }

      return followingUsers;
    } catch (e) {
      print("Error fetching following data: $e");
      return [];
    }
  }
}
