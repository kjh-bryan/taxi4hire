import 'dart:async';

import 'package:flutter/material.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/user_controller.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';
import 'package:taxi4hire/size_config.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to Taxi 4 Hire, Book a taxi!",
      "image": "assets/images/book_taxi_nobg.png"
    },
    {
      "text": "Easily and efficiently get a taxi",
      "image": "assets/images/board_taxi_nobgv2.png"
    },
    {
      "text": "Check nearby taxi all around you!",
      "image": "assets/images/nearby_taxi_nobg.png"
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      signInExistingUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: FadeAnimation(
                1.5,
                PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                      text: splashData[index]["text"]!,
                      image: splashData[index]["image"]!),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(20),
                ),
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    FadeAnimation(
                      1.5,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => buildDot(index),
                        ),
                      ),
                    ),
                    Spacer(flex: 3),
                    FadeAnimation(
                      1.8,
                      DefaultButton(
                        text: "Get Started",
                        press: () {
                          Navigator.popAndPushNamed(
                              context, SignInScreen.routeName);
                          // Timer(Duration(seconds: 3), () async {
                          //   if (await firebaseAuth.currentUser != null) {
                          //     currentFirebaseUser = firebaseAuth.currentUser;
                          //     // Navigator.popAndPushNamed(context, MainMapView.routeName);
                          //     Navigator.popAndPushNamed(
                          //         context, MainMap.routeName);
                          //   } else {
                          //     Navigator.popAndPushNamed(
                          //         context, SignInScreen.routeName);
                          //   }
                          // });
                        },
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key? key,
    required this.text,
    required this.image,
  }) : super(key: key);

  final String text, image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Spacer(),
        FadeAnimation(
          1.3,
          Text(
            "TAXI 4 HIRE",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(36),
              color: kPrimaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        FadeAnimation(
          1.5,
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Spacer(),
        FadeAnimation(
          1.7,
          Image.asset(
            image,
            height: getProportionateScreenHeight(250),
            width: getProportionateScreenWidth(350),
          ),
        ),
      ],
    );
  }
}
