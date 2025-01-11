// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uicons/uicons.dart';
import 'Theme/color.dart';
import 'controller/main_controller.dart';
import 'controller/profile_controller.dart';
import 'controller/theme_controller.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/reels_page.dart';
import 'pages/search_page.dart';
import 'storage/upload_page.dart';

class MainScreen extends StatelessWidget {
  final ThemeController themeController = Get.find();
  final ProfileController profileController = Get.put(ProfileController());
  final MainController controller = Get.put(MainController());
  final authService = Supabase.instance.client.auth;

  final List<Widget> pages = [
    HomePage(),
    SearchPage(),
    ReelsPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => pages[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          backgroundColor:
              themeController.switchValue.value ? Colors.white : Colors.black,
          destinations: [
            NavigationDestination(
              icon: Icon(
                controller.selectedIndex.value == 0
                    ? UIcons.solidRounded.home
                    : UIcons.regularStraight.home,
                color: controller.selectedIndex.value == 0
                    ? buttonb
                    : themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText,
              ),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(
                controller.selectedIndex.value == 1
                    ? UIcons.solidRounded.laptop_code
                    : UIcons.regularStraight.laptop_code,
                color: controller.selectedIndex.value == 1
                    ? buttonb
                    : themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText,
              ),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(
                controller.selectedIndex.value == 2
                    ? UIcons.solidRounded.square_terminal
                    : UIcons.regularRounded.square_terminal,
                color: controller.selectedIndex.value == 2
                    ? buttonb
                    : themeController.switchValue.value
                        ? themeController.lightText
                        : themeController.darkText,
              ),
              label: '',
            ),
            NavigationDestination(
              icon: CircleAvatar(
                radius: 20,
                backgroundImage: profileController.avatarUrl.value.isNotEmpty
                    ? NetworkImage(profileController.avatarUrl.value)
                    : AssetImage('assets/logo/default_avatar.png')
                        as ImageProvider,
              ),
              label: '',
            ),
          ],
          indicatorColor: Colors.transparent,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (int index) {
            controller.updateIndex(index);
          },
        ),
      ),
      floatingActionButton: Container(
        width: 50, // قطر الزر العائم
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [buttonc, buttonb],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Get.to(() => UploadPage());
          },
          elevation: 0, // إزالة الظل لضمان مظهر سلس
          backgroundColor: Colors.transparent, // شفافية لتطبيق التدرج
          child: Icon(
            Icons.add,
            color: Colors.white, // لون الأيقونة
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
    );
  }
}
