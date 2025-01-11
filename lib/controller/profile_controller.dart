import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final supabase = Supabase.instance.client;
  var avatarUrl = ''.obs;
  var username = 'no name'.obs;
  var followersCount = 0.obs;
  var followingCount = 0.obs;
  var userEmail = ''.obs;
  var posts = <Map<String, dynamic>>[].obs;
  var followers = <Map<String, dynamic>>[].obs;
  var following = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
    fetchPosts();
    fetchFollowers();
    fetchFollowing();
  }

  Future<void> fetchProfileData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    // جلب معلومات المستخدم
    final profile = await supabase
        .from('users_profile')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (profile != null) {
      avatarUrl.value = profile['avatar_url'] ?? '';
      username.value = profile['username'] ?? 'no name';
      userEmail.value = profile['user_email'] ?? '';
    }

    // حساب عدد Following
    final followingResponse = await supabase
        .from('friends')
        .select('friend_id')
        .eq('user_id', user.id);

    followingCount.value = followingResponse?.length ?? 0;

    // حساب عدد Followers
    final followersResponse = await supabase
        .from('friends')
        .select('user_id')
        .eq('friend_id', user.id);

    followersCount.value = followersResponse?.length ?? 0;
  }

  Future<void> fetchPosts() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response =
        await supabase.from('posts').select().eq('user_id', user.id);

    posts.value = List<Map<String, dynamic>>.from(response ?? []);
  }

  Future<void> fetchFollowers() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // جلب بيانات المتابعين بناءً على friend_id
      final response = await supabase
          .from('friends')
          .select('user_id') // جلب user_id للمتابعين
          .eq('friend_id', user.id); // البحث عن المتابعين بناءً على friend_id

      if (response != null) {
        final followersList = List<Map<String, dynamic>>.from(response);

        // جلب معلومات المستخدمين الذين يتابعون
        final followerIds =
            followersList.map((follower) => follower['user_id']).toList();
        final profilesResponse = await supabase
            .from('users_profile')
            .select('user_id,username, avatar_url')
            .inFilter('user_id', followerIds);

        followers.value =
            List<Map<String, dynamic>>.from(profilesResponse ?? []);
      }
    } catch (e) {
      print('Error fetching followers: $e');
    }
  }

  Future<void> fetchFollowing() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // جلب بيانات المتابعين بناءً على user_id
      final response = await supabase
          .from('friends')
          .select('friend_id') // جلب friend_id للمستخدمين الذين يتابعون
          .eq('user_id', user.id); // البحث عن المتابعين بناءً على user_id

      if (response != null) {
        final followingList = List<Map<String, dynamic>>.from(response);

        // جلب معلومات المستخدمين الذين يتابعهم المستخدم
        final followingIds =
            followingList.map((following) => following['friend_id']).toList();
        final profilesResponse = await supabase
            .from('users_profile')
            .select('user_id,username, avatar_url')
            .inFilter('user_id', followingIds);

        following.value =
            List<Map<String, dynamic>>.from(profilesResponse ?? []);
      }
    } catch (e) {
      print('Error fetching following: $e');
    }
  }
}
