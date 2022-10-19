import 'package:flutter/widgets.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/screens/forget_password/forget_password_screen.dart';
import 'package:taxi4hire/screens/main_map/main_map.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';
import 'package:taxi4hire/screens/sign_up/sign_up_screen_customer.dart';
import 'package:taxi4hire/screens/sign_up/sign_up_screen_taxidriver.dart';
import 'package:taxi4hire/screens/sign_up_selection/sign_up_selection.dart';
import 'package:taxi4hire/screens/splash/splash_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgetPasswordScreen.routeName: (context) => const ForgetPasswordScreen(),
  SignUpCustomerScreen.routeName: (context) => const SignUpCustomerScreen(),
  SignUpTaxiDriverScreen.routeName: (context) => const SignUpTaxiDriverScreen(),
  SignUpSelectionScreen.routeName: (context) => SignUpSelectionScreen(),
  MainMap.routeName: (context) => const MainMap()
  // MainMap.routeName: (context) => MainMap(
  //       checkUserRole: userModelCurrentInfo!.role!,
  //     ),
};
