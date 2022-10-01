import 'package:flutter/material.dart';
import 'package:taxi4hire/LandingScreen/choice.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/routes.dart';
import 'package:taxi4hire/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp(
      child: MaterialApp(
        title: 'Taxi 4 Hire',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "Muli",
          textTheme: const TextTheme(
            bodyText1: TextStyle(color: kTextColor),
            bodyText2: TextStyle(color: kTextColor),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //home: const SplashScreen(),
        initialRoute: SplashScreen.routeName,
        routes: routes,
        debugShowCheckedModeBanner: false,
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
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
