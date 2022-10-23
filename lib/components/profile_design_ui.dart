import 'package:flutter/material.dart';
import 'package:taxi4hire/constants.dart';

class ProfileDesignUIWidget extends StatefulWidget {
  final String textInfo;
  final IconData iconData;
  const ProfileDesignUIWidget(
      {Key? key, required this.textInfo, required this.iconData})
      : super(key: key);

  @override
  State<ProfileDesignUIWidget> createState() => _ProfileDesignUIWidgetState();
}

class _ProfileDesignUIWidgetState extends State<ProfileDesignUIWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: kPrimaryColor),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: ListTile(
        leading: Icon(
          widget.iconData,
          color: kPrimaryColor,
        ),
        title: Text(
          widget.textInfo,
          style: const TextStyle(
            color: kPrimaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
