// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/theme_controller.dart';
import '../pages/login_pages.dart';

class SplashAuth extends StatefulWidget {
  const SplashAuth({super.key});

  @override
  State<SplashAuth> createState() => _SplashAuthState();
}

class _SplashAuthState extends State<SplashAuth> {
  final ThemeController themeController = Get.find();

  @override
  void initState() {
    super.initState();
    _navigatetohome();
  }

  _navigatetohome() async {
    await Future.delayed(Duration(milliseconds: 10000), () {});
    Get.off(LoginPages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية مع خاصية التعتيم
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/52/6b/61/526b61b98d102102dbc9b7ec2bd95d0b.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6), // التعتيم
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // الشعار في منتصف الشاشة
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
