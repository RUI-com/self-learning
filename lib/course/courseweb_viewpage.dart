import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CourseWebViewPage extends StatelessWidget {
  final String url;

  const CourseWebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    // إعداد الـ WebViewController
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // يمكن تحديث شريط تحميل إذا لزم الأمر
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent; // منع التنقل إلى روابط معينة
            }
            return NavigationDecision.navigate; // السماح بالتنقل
          },
        ),
      )
      ..loadRequest(Uri.parse(url)); // تحميل الرابط الممرر

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Viewer'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
