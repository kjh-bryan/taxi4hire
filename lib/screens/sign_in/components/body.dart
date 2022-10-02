import 'package:flutter/material.dart';
import 'package:taxi4hire/components/no_account_text.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/screens/forget_password/forget_password_screen.dart';
import 'package:taxi4hire/screens/sign_in/components/sign_in_form.dart';
import 'package:taxi4hire/size_config.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(35),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset(
                  "assets/images/app-logo.png",
                  width: getProportionateScreenWidth(100),
                ),
                Text(
                  "TAXI4HIRE",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: getProportionateScreenWidth(24),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const Text(
                  "Sign in with your username and password",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.08,
                ),
                const SignForm(),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.06,
                ),
                NoAccountText()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
