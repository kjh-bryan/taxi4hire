import 'package:flutter/widgets.dart';
import 'package:taxi4hire/screens/forget_password/forget_password_screen.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';
import 'package:taxi4hire/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgetPasswordScreen.routeName: (context) => ForgetPasswordScreen(),
};
