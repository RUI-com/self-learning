// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/profile_controller.dart';

class GridviewPosts extends StatefulWidget {
  @override
  State<GridviewPosts> createState() => _GridviewPostsState();
}

class _GridviewPostsState extends State<GridviewPosts>
    with TickerProviderStateMixin {
  final ProfileController controller = Get.put(ProfileController());
  final supabaseClient = Supabase.instance.client;
  late TabController _tabController;
  RxString selectedCategory = 'All Posts'.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'All Posts'),
            Tab(text: 'Photos'),
            Tab(text: 'Videos'),
            Tab(text: 'Favorites'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                selectedCategory.value = 'All Posts';
                break;
              case 1:
                selectedCategory.value = 'Photos';
                break;
              case 2:
                selectedCategory.value = 'Videos';
                break;
              case 3:
                selectedCategory.value = 'Favorites';
                break;
            }
          },
        ),
      ],
    );
  }
}
