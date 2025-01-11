import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/theme_controller.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class ReelsController extends GetxController {
  late final WebViewController webViewController;
  var isLoading = true.obs;
  final ThemeController themeController = Get.find();

  @override
  void onInit() {
    super.onInit();
    _loadLoadingState(); // تحميل الحالة المحفوظة
    initializeWebView();
  }

  // تحميل الحالة المحفوظة من SharedPreferences
  void _loadLoadingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoading.value = prefs.getBool('isLoading') ??
        true; // إذا كانت القيمة غير موجودة، نضعها على true
  }

  void initializeWebView() async {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              isLoading.value = false;
              _saveLoadingState(false); // حفظ الحالة
              _applyTheme();
            }
          },
          onPageStarted: (String url) {
            isLoading.value = true;
            _saveLoadingState(true); // حفظ الحالة
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            _saveLoadingState(false); // حفظ الحالة
            _applyTheme();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.blackbox.ai/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.blackbox.ai/'));
  }

  // حفظ حالة التحميل في SharedPreferences
  void _saveLoadingState(bool isLoadingState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoading', isLoadingState);
  }

  void _applyTheme() {
    String jsCode = themeController.switchValue.value
        ? '''
          document.body.style.backgroundColor = "#FFFFFF";
          document.body.style.color = "#000000";
        '''
        : '''
          document.body.style.backgroundColor = "#000000";
          document.body.style.color = "#FFFFFF";
        ''';

    webViewController.runJavaScript(jsCode);
  }
}
