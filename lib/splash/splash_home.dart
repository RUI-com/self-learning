// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_controller.dart';
import '../main_screen.dart';

class SplashHome extends StatefulWidget {
  const SplashHome({super.key});

  @override
  State<SplashHome> createState() => _SplashHomeState();
}

class _SplashHomeState extends State<SplashHome> {
  final ThemeController themeController = Get.find();

  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 10000), () {});
    Get.off(MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/52/6b/61/526b61b98d102102dbc9b7ec2bd95d0b.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6), // تعتيم الصورة
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // الشعار في المنتصف
          Center(
            child: Image.asset(
              "assets/logo/self learning-logo.png",
              width: 100,
            ),
          ),
        ],
      ),
    );
  }
}
