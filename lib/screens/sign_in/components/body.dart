import 'package:flutter/material.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/no_account_text.dart';
import 'package:taxi4hire/constants.dart';
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
                FadeAnimation(
                  0.8,
                  Image.asset(
                    "assets/images/app-logo.png",
                    width: getProportionateScreenWidth(100),
                  ),
                ),
                FadeAnimation(
                  1,
                  Text(
                    "TAXI4HIRE",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: getProportionateScreenWidth(24),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                FadeAnimation(
                  1.2,
                  const Text(
                    "Sign in with your username and password",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.04,
                ),
                FadeAnimation(
                  1.4,
                  SignForm(),
                ),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.04,
                ),
                FadeAnimation(
                  1.6,
                  NoAccountText(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
