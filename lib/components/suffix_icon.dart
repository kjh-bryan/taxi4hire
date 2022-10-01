import 'package:flutter/material.dart';
import 'package:taxi4hire/size_config.dart';

class CustomSuffixIcon extends StatelessWidget {
  const CustomSuffixIcon({
    Key? key,
    required this.suffixIcon,
  }) : super(key: key);

  final Icon suffixIcon;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        getProportionateScreenWidth(25),
        0,
      ),
      child: suffixIcon,
    );
  }
}
