import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appearance/appearance.dart'; // استيراد المكتبة

import '../Theme/color.dart';

class ThemeController extends GetxController {
  final box = GetStorage();

  // ملاحظات الثيم
  final switchValue = false.obs;

  final lightBackground = background;
  final lightText = Colors.black;
  final darkBackground = backgrounddark;
  final darkText = background;
  final postbackgrounddark = postcolor;
  final postbackgroundlight = Colors.white;

  ThemeData get themeData => ThemeData(
        brightness: switchValue.value ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor:
            switchValue.value ? lightBackground : darkBackground,
        cardColor: switchValue.value ? postbackgrounddark : postbackgroundlight,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: switchValue.value ? darkText : lightText),
        ),
      );

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void toggleTheme(bool isDark) {
    switchValue.value = isDark;
    Get.changeTheme(themeData); // تغيير الثيم مباشرة
    _saveTheme(isDark);
  }

  void _saveTheme(bool isDark) {
    box.write('isDarkTheme', isDark); // تخزين في GetStorage
  }

  void _loadTheme() {
    final context = Get.context;
    if (context != null) {
      final systemTheme = Appearance.of(context)?.mode ?? ThemeMode.system;
      final isDark = box.read('isDarkTheme') ?? (systemTheme == ThemeMode.dark);
      switchValue.value = isDark;
      Get.changeTheme(themeData);
    } else {
      final isDark = box.read('isDarkTheme') ??
          false; // افتراض وضع فاتح إذا لم يتوفر السياق
      switchValue.value = isDark;
      Get.changeTheme(themeData);
    }
  }

  @override
  void onReady() {
    super.onReady();
    _loadTheme();
  }
}
