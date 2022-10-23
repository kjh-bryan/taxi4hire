import 'package:flutter/material.dart';
import 'package:taxi4hire/screens/sign_up/components/body_taxidriver.dart';

class SignUpTaxiDriverScreen extends StatelessWidget {
  const SignUpTaxiDriverScreen({Key? key}) : super(key: key);
  static String routeName = "/sign_up_taxidriver";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sign Up"),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: const Body(),
    );
  }
}
