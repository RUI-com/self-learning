// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostController {
  File? imageFile;
  final descriptionController = TextEditingController();

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      imageFile = File(image.path);
    }
  }

  Future<String?> uploadImage(String path) async {
    try {
      final response = await Supabase.instance.client.storage
          .from('image')
          .upload(path, imageFile!);
      final imageUrl =
          Supabase.instance.client.storage.from('image').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }

  Future<void> uploadPost(Function onSuccess, Function onError) async {
    if (imageFile == null || descriptionController.text.isEmpty) {
      onError("Please select an image and enter a description");
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      onError("User not authenticated");
      return;
    }

    final profile = await Supabase.instance.client
        .from('users_profile')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (profile == null) {
      onError("No profile found for user ID: ${user.id}");
      return;
    }

    final username = profile['username'] ?? 'Unknown User';
    final avatarUrl = profile['avatar_url'] ??
        'https://pgbrg.nl/wp-content/uploads/2024/02/default_avatar.png';

    final fileName = DateTime.now().microsecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    try {
      final imageUrl = await uploadImage(path);

      await Supabase.instance.client.from('posts').insert({
        'user_id': user.id,
        'username': username,
        'image_url': imageUrl,
        'description': descriptionController.text,
        'created_at': DateTime.now().toString(),
        'user_avatar': avatarUrl,
      });

      onSuccess();
    } catch (e) {
      onError("Failed to upload post: $e");
    }
  }
}
