// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

import '../controller/chat_container.dart';

class ChatScreen extends StatelessWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String? receiverAvatarUrl; // صورة المستخدم الآخر
  final ChatController chatController = Get.put(ChatController());

  ChatScreen({
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    this.receiverAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Fetch data when the screen is loaded
    chatController.fetchUserData(senderId, receiverId);
    chatController.fetchSentMessages(senderId, receiverId);
    chatController.fetchReceivedMessages(senderId, receiverId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: receiverAvatarUrl != null
                  ? NetworkImage(receiverAvatarUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
              radius: 20,
            ),
            const SizedBox(width: 10),
            Text(
              receiverName,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      body: GetBuilder<ChatController>(
        builder: (controller) {
          // دمج الرسائل المرسلة والمستقبلة
          var allMessages = [
            ...controller.sentMessages,
            ...controller.receivedMessages
          ];
          allMessages.sort((a, b) => b.createdAt
              .compareTo(a.createdAt)); // ترتيب الرسائل من الأحدث إلى الأقدم

          return DashChat(
            currentUser: ChatUser(id: senderId),
            onSend: (ChatMessage message) {
              chatController.sendMessage(message, senderId, receiverId);
            },
            messages: allMessages, // استخدام جميع الرسائل
            messageOptions: MessageOptions(
              currentUserContainerColor: Colors.pink.shade100,
              currentUserTextColor: Colors.white,
              containerColor: Colors.blue.shade50,
              textColor: Colors.black87,
              messagePadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            ),
            inputOptions: InputOptions(
              inputDecoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                hintText: 'اكتب رسالتك...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              inputTextStyle: const TextStyle(
                color: Colors.black87,
              ),
              sendButtonBuilder: (void Function() onSend) {
                return GestureDetector(
                  onTap: onSend,
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue, // خلفية الزر
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white, // لون الأيقونة
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
