import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/routes.dart';
import 'package:taxi4hire/screens/splash/splash_screen.dart';
import 'package:taxi4hire/screens/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FlutterConfig.loadEnvVariables();
  runApp(
    MyApp(
      child: ChangeNotifierProvider(
        create: (context) => AppInfo(),
        child: MaterialApp(
          title: 'Taxi 4 Hire',
          theme: theme(),
          //home: const SplashScreen(),
          initialRoute: SplashScreen.routeName,
          // initialRoute: MainMapView.routeName,
          routes: routes,
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
