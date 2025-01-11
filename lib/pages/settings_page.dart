// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uicons/uicons.dart';

import '../Theme/color.dart';
import '../controller/theme_controller.dart';
import '../main_screen.dart';

class SettingsPage extends StatelessWidget {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: themeController.switchValue.value
            ? themeController.lightBackground
            : themeController.darkBackground,
        appBar: AppBar(
          backgroundColor: themeController.switchValue.value
              ? themeController.lightBackground
              : themeController.darkBackground,
          foregroundColor: themeController.switchValue.value
              ? themeController.darkBackground
              : themeController.lightBackground,
          title: Text(
            'Settings',
            style: TextStyle(fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                "Other Settings",
                style: TextStyle(
                  color: themeController.switchValue.value
                      ? themeController.lightText
                      : themeController.darkText,
                  fontSize: 24,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: themeController.switchValue.value
                        ? themeController.postbackgroundlight
                        : themeController.postbackgrounddark,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeController.switchValue.value
                              ? UIcons.regularStraight.sun
                              : UIcons.regularStraight.moon,
                          color: themeController.switchValue.value
                              ? buttonb
                              : buttonc,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          themeController.switchValue.value
                              ? "Light Mode"
                              : "Dark Mode",
                          style: TextStyle(
                            color: themeController.switchValue.value
                                ? themeController.lightText
                                : themeController.darkText,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      inactiveThumbColor: buttoncb,
                      activeColor: buttonb,
                      inactiveTrackColor: buttonc,
                      value: themeController.switchValue.value,
                      onChanged: themeController.toggleTheme,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.off(MainScreen());
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  decoration: BoxDecoration(
                    color: buttonb,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: buttonb.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
