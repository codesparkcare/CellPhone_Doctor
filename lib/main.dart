import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:workmanager/workmanager.dart';

import 'screens/splash_screen.dart';
import 'screens/web/web_landing_page.dart';
import 'helpers/background_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();

      // Initialize background sync worker
      Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true,
      );

      Workmanager().registerPeriodicTask(
        "1",
        "backgroundDataPrefetch",
        frequency: const Duration(minutes: 15),
      );

      Workmanager().registerOneOffTask(
        "2",
        "immediateDataPrefetch",
      );

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      debugPrint("Mobile initialization error: $e");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      hideNavigationBar();
      openNavBarFor2Seconds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 850;
        final responsiveDesignSize = isDesktop
            ? Size(
                constraints.maxWidth,
                constraints.maxHeight > 0 ? constraints.maxHeight : 900,
              )
            : const Size(400, 844);

        return ScreenUtilInit(
          designSize: responsiveDesignSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'The CellPhone Doctor - Best Mobile Services Shop in All Over TamilNadu',
              initialRoute: '/',
              theme: ThemeData(
                fontFamily: 'Poppins',
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: Colors.white,
              ),
              builder: (context, widget) {
                if (isDesktop) {
                  return WebLandingPage(child: widget ?? const SizedBox());
                }
                return widget ?? const SizedBox();
              },
              home: child,
            );
          },
          child: const SplashScreen(),
        );
      },
    );
  }
}

/// Hide nav bar, keep status bar visible
Future<void> hideNavigationBar() async {
  if (kIsWeb) return;
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

/// Show nav bar for 2 seconds then hide again
void openNavBarFor2Seconds() async {
  if (kIsWeb) return;
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Future.delayed(const Duration(seconds: 2));
  await hideNavigationBar();
}