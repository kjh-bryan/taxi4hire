import 'package:flutter/material.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/size_config.dart';

class Body extends StatefulWidget {
  Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
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
            child: Column(),
          ),
        ),
      ),
    );
  }
}

serviceContainer(String name, String image, int index) {
  return AnimatedContainer(
      duration: kAnimationDuration,
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Image.network(
            image,
            height: getProportionateScreenHeight(30),
          ),
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: getProportionateScreenWidth(14),
            ),
          ),
        ],
      ));
}
