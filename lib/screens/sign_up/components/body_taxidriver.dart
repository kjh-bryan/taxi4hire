import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/form_error.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/components/suffix_icon.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/user_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/screens/sign_in/sign_in_screen.dart';
import 'package:taxi4hire/size_config.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(35),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              FadeAnimation(
                0.8,
                Text(
                  "Register",
                  style: headingStyle,
                ),
              ),
              FadeAnimation(
                1,
                Text(
                  "as Taxi Driver",
                  style: TextStyle(
                    fontSize: getProportionateScreenWidth(12),
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              FadeAnimation(
                1.2,
                SignUpTaxiDriverForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpTaxiDriverForm extends StatefulWidget {
  const SignUpTaxiDriverForm({Key? key}) : super(key: key);

  @override
  State<SignUpTaxiDriverForm> createState() => _SignUpTaxiDriverFormState();
}

class _SignUpTaxiDriverFormState extends State<SignUpTaxiDriverForm> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  late String name;
  String? password;
  String? confirm_password;
  late String mobile_no;
  late String license_no;
  final List<String?> errors = [];

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileNoController = TextEditingController();
  final licenseNoController = TextEditingController();

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error)) {
      setState(() {
        errors.remove(error);
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    mobileNoController.dispose();
    licenseNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(10),
          ),
          buildEmailFormField(),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          buildPasswordFormField(),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          buildConfirmPasswordFormField(),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          buildNameFormField(),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          buildMobileNoFormField(),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          buildLicensePlateForm(),
          FormError(errors: errors),
          SizedBox(
            height: (errors.length == 0)
                ? getProportionateScreenHeight(60)
                : getProportionateScreenHeight(0),
          ),
          DefaultButton(
            text: "Sign Up",
            press: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                // Go to Login Page
                signUpUser(context, emailController, passwordController,
                    nameController, mobileNoController, licenseNoController, 0);
              }
            },
          ),
        ],
      ),
    );
  }

  //Implement a license plate validator ??
  TextFormField buildLicensePlateForm() {
    return TextFormField(
      controller: licenseNoController,
      onSaved: (newValue) => license_no = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kLicenseNoNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kLicenseNoNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: "Enter your license plate",
        labelText: "License Plate No",
        errorStyle: TextStyle(height: 0),
        floatingLabelStyle: TextStyle(
          color: kPrimaryColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          suffixIcon: Icon(Icons.directions_car, color: kPrimaryColor),
        ),
      ),
    );
  }

  TextFormField buildMobileNoFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: mobileNoController,
      onSaved: (newValue) => mobile_no = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kMobileNoNullError);
        } else if (value.length == 8) {
          removeError(error: kInvalidMobileNoError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kMobileNoNullError);
          return "";
        } else if (value.length < 8 && value.length > 8) {
          addError(error: kInvalidMobileNoError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: "Enter your mobile no.",
        labelText: "Mobile No",
        errorStyle: TextStyle(height: 0),
        floatingLabelStyle: TextStyle(
          color: kPrimaryColor,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          suffixIcon: Icon(Icons.phone, color: kPrimaryColor),
        ),
      ),
    );
  }

  TextFormField buildConfirmPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => confirm_password = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kConfirmPasswordNullError);
        } else if (value.isNotEmpty && password == confirm_password) {
          removeError(error: kMatchPasswordError);
        }
        confirm_password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kConfirmPasswordNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPasswordError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: "Re-enter your password",
        labelText: "Confirm Password",
        floatingLabelStyle: TextStyle(
          color: kPrimaryColor,
        ),
        errorStyle: TextStyle(height: 0),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          suffixIcon: Icon(Icons.lock, color: kPrimaryColor),
        ),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      controller: passwordController,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPasswordNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPasswordError);
        }
        // else if (value.isNotEmpty &&
        //     password == confirm_password
        //     ) {
        //  removeError(error:kMatchPasswordError);
        // }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPasswordNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPasswordError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        hintText: "Enter your password",
        labelText: "Password",
        floatingLabelStyle: TextStyle(
          color: kPrimaryColor,
        ),
        errorStyle: TextStyle(height: 0),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          suffixIcon: Icon(Icons.lock, color: kPrimaryColor),
        ),
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      controller: nameController,
      keyboardType: TextInputType.name,
      onSaved: (newValue) => name = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kUsernameNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kUsernameNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        floatingLabelStyle: TextStyle(
          color: kPrimaryColor,
        ),
        errorStyle: TextStyle(height: 0),
        hintText: "Enter your name",
        labelText: "Name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          suffixIcon: Icon(Icons.badge, color: kPrimaryColor),
        ),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue!,
      controller: emailController,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        floatingLabelStyle: TextStyle(
          color: kPrimaryColor,
        ),
        errorStyle: TextStyle(height: 0),
        hintText: "Enter your email",
        labelText: "Email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSuffixIcon(
          suffixIcon: Icon(Icons.mail_rounded, color: kPrimaryColor),
        ),
      ),
    );
  }
}
