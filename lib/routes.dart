import 'package:flutter/widgets.dart';
import 'package:taxi4hire/screens/forget_password/forget_password_screen.dart';
import 'package:taxi4hire/screens/main_map_view/main_map_view.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';
import 'package:taxi4hire/screens/sign_up/sign_up_screen_customer.dart';
import 'package:taxi4hire/screens/sign_up/sign_up_screen_taxidriver.dart';
import 'package:taxi4hire/screens/sign_up_selection/sign_up_selection.dart';
import 'package:taxi4hire/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgetPasswordScreen.routeName: (context) => ForgetPasswordScreen(),
  SignUpCustomerScreen.routeName: (context) => SignUpCustomerScreen(),
  SignUpTaxiDriverScreen.routeName: (context) => SignUpTaxiDriverScreen(),
  SignUpSelectionScreen.routeName: (context) => SignUpSelectionScreen(),
  MainMapView.routeName: (context) => MainMapView(),
};
