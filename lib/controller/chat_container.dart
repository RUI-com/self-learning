import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class ChatController extends GetxController {
  final supabaseClient = Supabase.instance.client;

  var sentMessages = <ChatMessage>[];
  var receivedMessages = <ChatMessage>[];
  var senderName = ''.obs;
  var receiverName = ''.obs;
  var senderProfilePicture = ''.obs;
  var receiverProfilePicture = ''.obs;

  // جلب بيانات المستخدمين
  Future<void> fetchUserData(String senderId, String receiverId) async {
    try {
      // جلب بيانات المرسل
      final senderResponse = await supabaseClient
          .from('users_profile')
          .select()
          .eq('user_id', senderId)
          .maybeSingle();
      if (senderResponse != null) {
        senderName.value = senderResponse['username'] ?? '';
        senderProfilePicture.value = senderResponse['avatar_url'] ?? '';
      }

      // جلب بيانات المستقبل
      final receiverResponse = await supabaseClient
          .from('users_profile')
          .select()
          .eq('user_id', receiverId)
          .maybeSingle();
      if (receiverResponse != null) {
        receiverName.value = receiverResponse['username'] ?? '';
        receiverProfilePicture.value = receiverResponse['avatar_url'] ?? '';
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchSentMessages(String senderId, String receiverId) async {
    try {
      var chatMessages = await supabaseClient
          .from('messages')
          .select()
          .eq('sender_id', senderId) // جلب الرسائل المرسلة
          .eq('receiver_id', receiverId)
          .order('timestamp', ascending: true); // ترتيب الرسائل حسب الوقت

      sentMessages.clear(); // تفريغ الرسائل القديمة
      for (var doc in chatMessages) {
        var message = ChatMessage(
          text: doc['message'],
          createdAt: DateTime.parse(doc['timestamp']),
          user: ChatUser(
            id: doc['sender_id'],
            firstName: doc['sender_name'],
          ),
        );
        sentMessages.add(message); // إضافة الرسالة إلى القائمة
      }
      update(); // تحديث الـ Controller بعد جلب الرسائل
    } catch (e) {
      print("Error fetching sent messages: $e");
    }
  }

  Future<void> fetchReceivedMessages(String senderId, String receiverId) async {
    try {
      var chatMessages = await supabaseClient
          .from('messages')
          .select()
          .eq('sender_id', receiverId) // جلب الرسائل المستقبلة
          .eq('receiver_id', senderId)
          .order('timestamp', ascending: true); // ترتيب الرسائل حسب الوقت

      receivedMessages.clear(); // تفريغ الرسائل القديمة
      for (var doc in chatMessages) {
        var message = ChatMessage(
          text: doc['message'],
          createdAt: DateTime.parse(doc['timestamp']),
          user: ChatUser(
            id: doc['sender_id'],
            firstName: doc['sender_name'],
          ),
        );
        receivedMessages.add(message); // إضافة الرسالة إلى القائمة
      }
      update(); // تحديث الـ Controller بعد جلب الرسائل
    } catch (e) {
      print("Error fetching received messages: $e");
    }
  }

  Future<void> sendMessage(
      ChatMessage message, String senderId, String receiverId) async {
    try {
      var messageType = 'text'; // تحديد نوع الرسالة

      // إذا كانت الرسالة تحتوي على صورة (حسب الحاجة)
      if (message.text.contains('image')) {
        messageType = 'image';
      }

      var newMessage = {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message.text,
        'timestamp': DateTime.now().toIso8601String(),
        'sender_name': senderName.value,
        'receiver_name': receiverName.value,
        'sender_profile_picture': senderProfilePicture.value,

        'receiver_profile_picture': receiverProfilePicture.value,
        'message_type': messageType, // نوع الرسالة
      };

      await supabaseClient.from('messages').insert(newMessage);
      // بعد إرسال الرسالة، يمكنك إضافتها إلى قائمة الرسائل
      sentMessages.add(message); // إضافة الرسالة المرسلة إلى القائمة
      update(); // تحديث الـ Controller
    } catch (e) {
      print("Error sending message: $e");
    }
  }
}
