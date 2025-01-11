import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    // Attempt to sign in the user with email and password
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email, password, and name
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password, String name, String avatarUrl) async {
    // Attempt to sign up the user
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // If the user is created successfully, insert their profile into the database
    if (response.user != null) {
      final userId = response.user?.id;
      if (userId != null) {
        await _supabase.from('users_profile').insert([
          {
            'user_id': userId,
            'user_email': email,
            'username': name,
            'avatar_url': avatarUrl,
            'followers_count': 0,
            'following_count': 0,
          }
        ]);
      }
    }

    return response;
  }

  // Upload image to Supabase storage
  Future<void> uploadImage(String path, File imageFile) async {
    await _supabase.storage.from('image').upload(path, imageFile);
  }

  // Get public URL for the uploaded image
  String getPublicUrl(String path) {
    return _supabase.storage.from('image').getPublicUrl(path);
  }

  // Sign out
  Future<void> signOut() async {
    return await _supabase.auth.signOut();
  }
}
