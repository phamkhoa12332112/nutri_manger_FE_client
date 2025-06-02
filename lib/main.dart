import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nutrients_manager/ui/page/home/home_screen.dart';
import 'package:nutrients_manager/ui/page/login/login_screen.dart';

import 'data/controller/share_pref_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = SharedPrefsController.getInstance();
  await prefs.init();

  final user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(user: user));
}



class MyApp extends StatelessWidget {
  final User? user;
  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: getDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: user == null
              ? const LoginScreen()
              : const HomeScreen(),
        );
      },
    );
  }
}
Size getDesignSize() {
  double width =
      WidgetsBinding
          .instance
          .platformDispatcher
          .views
          .first
          .physicalSize
          .width /
      WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

  if (width < 600) {
    return const Size(430, 932); // Mobile
  } else if (width < 1100) {
    return const Size(768, 1024); // Tablet
  } else {
    return const Size(1200, 800); // Web/Desktop
  }
}
