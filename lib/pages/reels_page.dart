import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../controller/theme_controller.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  late final WebViewController _webViewController;
  final ThemeController themeController = Get.find();

  bool _isLoading = true; // لتتبع حالة التحميل

  @override
  void initState() {
    super.initState();

    // إعداد الـ WebViewController
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
                _applyTheme(); // تطبيق الثيم بعد تحميل الصفحة
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _applyTheme(); // تطبيق الثيم عند انتهاء التحميل
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.blackbox.ai/')) {
              return NavigationDecision.prevent; // منع التنقل غير المرغوب
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.blackbox.ai/'));

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _applyTheme() {
    // JavaScript لتغيير CSS بناءً على الوضع الليلي/النهاري
    String jsCode = themeController.switchValue.value
        ? '''
      document.body.style.backgroundColor = "#FFFFFF";
      document.body.style.color = "#000000";
    '''
        : '''
      document.body.style.backgroundColor = "#000000";
      document.body.style.color = "#FFFFFF";
    ''';

    _webViewController.runJavaScript(jsCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeController.switchValue.value
          ? themeController.lightBackground
          : themeController.darkBackground,
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: themeController.switchValue.value
                    ? Colors.blue
                    : Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
