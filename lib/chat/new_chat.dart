// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/theme_controller.dart';
import 'chat_screen.dart';

class NewChatScreen extends StatefulWidget {
  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final supabaseClient = Supabase.instance.client;
  List<dynamic> allUsers = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  final ThemeController themeController = Get.find();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(() {
      filterUsers();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabaseClient
          .from('users_profile')
          .select('user_id, username, avatar_url');

      if (response.isNotEmpty) {
        setState(() {
          allUsers = response;
          filteredUsers = response;
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((user) {
        final username = user['username']?.toLowerCase() ?? '';
        return username.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Chat'),
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(
                  color: themeController.switchValue.value
                      ? Colors.black
                      : Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        leading: user['avatar_url'] != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user['avatar_url']),
                              )
                            : CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(user['username'] ?? 'Unknown'),
                        onTap: () {
                          final senderId = supabaseClient.auth.currentUser!.id;
                          final receiverId = user['user_id'];
                          final receiverName = user['username'];
                          final receiverAvatarUrl = user['avatar_url'];
                          if (senderId != receiverId) {
                            Get.to(() => ChatScreen(
                                senderId: senderId,
                                receiverId: receiverId,
                                receiverName: user['username'] ?? 'Unknown',
                                receiverAvatarUrl: user['avatar_url']));
                          } else {
                            print("لا يمكن التواصل مع نفسك!");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("لا يمكنك التواصل مع نفسك!")),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
