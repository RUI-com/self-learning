// ignore_for_file: prefer_const_constructors, deprecated_member_use, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controller/profile_controller.dart';
import '../controller/theme_controller.dart';
import 'chat_screen.dart';
import 'new_chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final supabaseClient = Supabase.instance.client;
  List<dynamic> chats = [];
  List<dynamic> friends = []; // قائمة الأصدقاء
  Map<String, Map<String, String>> userProfiles = {};
  bool isLoading = true;
  final authService = Supabase.instance.client.auth;
  final ThemeController themeController = Get.find();
  final ProfileController controller = Get.find();
  List<String> selectedChats = [];
  bool isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    fetchChats();
    controller.fetchFollowing();
  }

  Future<void> fetchChats() async {
    setState(() {
      isLoading = true;
    });
    try {
      final currentUserId = authService.currentUser?.id;

      final response = await supabaseClient
          .from('messages')
          .select()
          .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .order('timestamp', ascending: false);

      if (response.isNotEmpty) {
        final uniqueChats = <String, dynamic>{};
        for (var chat in response) {
          final chatPartnerId = chat['sender_id'] == currentUserId
              ? chat['receiver_id']
              : chat['sender_id'];
          if (!uniqueChats.containsKey(chatPartnerId)) {
            uniqueChats[chatPartnerId] = chat;
          }
        }

        setState(() {
          chats = uniqueChats.values.toList();
        });

        await fetchUserProfiles();
      }
    } catch (e) {
      print("Error fetching chats: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserProfiles() async {
    try {
      final userIds = chats.map((chat) {
        return chat['sender_id'] == authService.currentUser?.id
            ? chat['receiver_id']
            : chat['sender_id'];
      }).toSet();

      final response = await supabaseClient
          .from('users_profile')
          .select('user_id, username, avatar_url')
          .or(userIds.map((id) => 'user_id.eq.$id').join(','));

      if (response.isNotEmpty) {
        setState(() {
          for (var user in response) {
            userProfiles[user['user_id']] = {
              'username': user['username'],
              'avatar_url': user['avatar_url'],
            };
          }
        });
      }
    } catch (e) {
      print("Error fetching user profiles: $e");
    }
  }

  Future<void> deleteSelectedChats() async {
    try {
      for (String chatId in selectedChats) {
        await supabaseClient.from('messages').delete().eq('id', chatId);
      }
      setState(() {
        chats.removeWhere((chat) => selectedChats.contains(chat['id']));
        selectedChats.clear();
        isSelectionMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chats deleted successfully.')),
      );
    } catch (e) {
      print("Error deleting chats: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting chats.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              print("Search clicked");
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // القسم الأول: الأصدقاء
          SizedBox(
              height: 100,
              child: Obx(() {
                if (controller.following.isEmpty) {
                  return Center(child: Text('No following found.'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.following.length,
                  itemBuilder: (context, index) {
                    final friend = controller.following[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              String senderId = authService.currentUser!.id;
                              String receiverId = friend['user_id'];

                              if (senderId != receiverId) {
                                Get.to(() => ChatScreen(
                                    senderId: senderId,
                                    receiverId: receiverId,
                                    receiverName:
                                        friend['username'] ?? 'Unknown',
                                    receiverAvatarUrl: friend['avatar_url']));
                              } else {
                                print("لا يمكن التواصل مع نفسك!");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("لا يمكنك التواصل مع نفسك!")),
                                );
                              }
                            },
                            child: CircleAvatar(
                              backgroundImage: friend['avatar_url'] != null
                                  ? NetworkImage(friend['avatar_url'])
                                  : null,
                              radius: 30,
                              child: friend['avatar_url'] == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            friend['username'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              })),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Chats",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // القسم الثاني: الدردشات
          if (isSelectionMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedChats.length} Selected',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await deleteSelectedChats();
                    },
                  ),
                ],
              ),
            ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: fetchChats,
                    child: ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final chatPartnerId =
                            chat['sender_id'] == authService.currentUser?.id
                                ? chat['receiver_id']
                                : chat['sender_id'];
                        final lastMessage = chat['message'];
                        final timestamp = chat['timestamp'];

                        final chatPartnerData = userProfiles[chatPartnerId];
                        final chatPartnerName =
                            chatPartnerData?['username'] ?? 'Unknown User';
                        final avatarUrl = chatPartnerData?['avatar_url'];

                        return GestureDetector(
                          onLongPress: () {
                            setState(() {
                              isSelectionMode = true;
                              selectedChats.add(chat['id']
                                  .toString()); // استخدام معرف المحادثة
                            });
                          },
                          child: ListTile(
                            leading: avatarUrl != null
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(avatarUrl),
                                    radius: 25,
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.person),
                                    radius: 25,
                                  ),
                            title: Text(
                              chatPartnerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: isSelectionMode
                                ? Checkbox(
                                    value: selectedChats
                                        .contains(chat['id'].toString()),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedChats
                                              .add(chat['id'].toString());
                                        } else {
                                          selectedChats
                                              .remove(chat['id'].toString());
                                        }
                                      });
                                    },
                                  )
                                : Text(
                                    _formatTimeOnly(timestamp),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                            onTap: isSelectionMode
                                ? () {
                                    setState(() {
                                      if (selectedChats
                                          .contains(chat['id'].toString())) {
                                        selectedChats
                                            .remove(chat['id'].toString());
                                      } else {
                                        selectedChats
                                            .add(chat['id'].toString());
                                      }
                                    });
                                  }
                                : () {
                                    Get.to(() => ChatScreen(
                                        senderId: authService.currentUser!.id,
                                        receiverId: chatPartnerId,
                                        receiverName: chatPartnerName,
                                        receiverAvatarUrl: avatarUrl));
                                  },
                          ),
                        );
                      },
                    ),
                  ),
          ),
          // القسم الثالث: زر دردشة جديدة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.pink),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  Get.to(() => NewChatScreen());
                },
                child: Container(
                  width: 100,
                  child: Row(
                    children: [Icon(Icons.add), Text('New Chat')],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeOnly(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
