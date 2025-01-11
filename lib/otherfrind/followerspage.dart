// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/other_profile.dart';
import '../pages/profile_page.dart';

class FollowersPage extends StatelessWidget {
  final String userId;
  final supabaseClient = Supabase.instance.client;

  FollowersPage({required this.userId});
  final authService = Supabase.instance.client.auth;
  @override
  Widget build(BuildContext context) {
    final currentUserId = authService.currentUser?.id ?? "";
    return Scaffold(
      appBar: AppBar(
        title: Text("Followers"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFollowers(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final followersList = snapshot.data ?? [];

          return ListView.builder(
            itemCount: followersList.length,
            itemBuilder: (context, index) {
              final followerUser = followersList[index];
              return ListTile(
                leading: InkWell(
                  onTap: () {
                    if (followerUser['user_id'] == currentUserId) {
                      // انتقل إلى صفحة بروفايل المستخدم الحالي
                      Get.to(() => ProfileScreen());
                    } else {
                      // انتقل إلى صفحة بروفايل المستخدم الآخر
                      Get.to(() =>
                          OtherProfileScreen(userId: followerUser['user_id']));
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage(followerUser['avatar_url'] ?? ''),
                  ),
                ),
                title: Text(followerUser['username']),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFollowers(String userId) async {
    try {
      final response = await supabaseClient
          .from('friends')
          .select('user_id')
          .eq('friend_id', userId);

      final followersIds = response ?? [];
      List<Map<String, dynamic>> followersUsers = [];

      for (var id in followersIds) {
        final userResponse = await supabaseClient
            .from('users_profile')
            .select()
            .eq('user_id', id['user_id'])
            .maybeSingle();

        if (userResponse != null) {
          followersUsers.add(userResponse);
        }
      }

      return followersUsers;
    } catch (e) {
      print("Error fetching followers data: $e");
      return [];
    }
  }
}
