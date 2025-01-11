// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, sort_child_properties_last, prefer_const_declarations, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:appearance/appearance.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/auth_gate.dart';
import 'controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Supabase
  await Supabase.initialize(
    url: 'https://gqkxntfezmzdtwfbynmz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdxa3hudGZlem16ZHR3ZmJ5bm16Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ1MjI0ODUsImV4cCI6MjA1MDA5ODQ4NX0.5O899MSH7B_UVoAlvOd9tjYqeoTPO4TVXgr7XZab3mw',
  );

  await GetStorage.init(); // تهيئة GetStorage
  Get.put(ThemeController()); // استدعاء ThemeController
  await SharedPreferencesManager.instance.init(); // تهيئة Appearance

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AppearanceState {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return BuildWithAppearance(
      initial: ThemeMode.system,
      builder: (context) => Obx(
        () => GetMaterialApp(
          title: 'App Name',
          debugShowCheckedModeBanner: false,
          theme: themeController.themeData,
          themeMode: Appearance.of(context)?.mode ?? ThemeMode.system,
          home: AuthGate(),
        ),
      ),
    );
  }
}
