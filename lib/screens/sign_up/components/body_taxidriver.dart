import 'package:flutter/material.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/form_error.dart';
import 'package:taxi4hire/components/suffix_icon.dart';
import 'package:taxi4hire/constants.dart';
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
                    fontWeight: FontWeight.w100,
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
  String? email;
  String? password;
  String? confirm_password;
  String? mobile_no;
  String? license_no;
  final List<String> errors = [];
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(20),
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
          buildMobileNoFormField(),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          buildLicensePlateForm(),
          FormError(errors: errors),
          SizedBox(
            height: getProportionateScreenHeight(30),
          ),
          DefaultButton(
            text: "Sign Up",
            press: () {
              if (_formKey.currentState!.validate()) {
                // Go to Login Page
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildLicensePlateForm() {
    return TextFormField(
      onSaved: (newValue) => license_no = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kLicenseNoNullError)) {
          setState(() {
            errors.remove(kLicenseNoNullError);
          });
        }
      },
      validator: (value) {
        if (value!.isEmpty && !errors.contains(kLicenseNoNullError)) {
          setState(() {
            errors.add(kLicenseNoNullError);
          });
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
      onSaved: (newValue) => mobile_no = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kMobileNoNullError)) {
          setState(() {
            errors.remove(kMobileNoNullError);
          });
        } else if (value.length == 8 &&
            errors.contains(kInvalidMobileNoError)) {
          setState(() {
            errors.remove(kInvalidMobileNoError);
          });
        }
      },
      validator: (value) {
        if (value!.isEmpty && !errors.contains(kMobileNoNullError)) {
          setState(() {
            errors.add(kMobileNoNullError);
          });
          return "";
        } else if (value.length < 8 &&
            value.length > 8 &&
            !errors.contains(kInvalidMobileNoError)) {
          setState(() {
            errors.add(kInvalidMobileNoError);
          });
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
      onSaved: (newValue) => confirm_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kPasswordNullError)) {
          setState(() {
            errors.remove(kPasswordNullError);
          });
        } else if (value.isNotEmpty &&
            password == confirm_password &&
            errors.contains(kMatchPasswordError)) {
          setState(() {
            errors.remove(kMatchPasswordError);
          });
        }
        confirm_password = value;
      },
      validator: (value) {
        if (value!.isEmpty && !errors.contains(kPasswordNullError)) {
          setState(() {
            errors.add(kPasswordNullError);
          });
          return "";
        } else if ((password != value) &&
            !errors.contains(kMatchPasswordError)) {
          setState(() {
            errors.add(kMatchPasswordError);
          });
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
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kPasswordNullError)) {
          setState(() {
            errors.remove(kPasswordNullError);
          });
        } else if (value.length >= 8 && errors.contains(kShortPasswordError)) {
          setState(() {
            errors.remove(kShortPasswordError);
          });
        } else if (value.isNotEmpty &&
            password == confirm_password &&
            errors.contains(kMatchPasswordError)) {
          setState(() {
            errors.remove(kMatchPasswordError);
          });
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty && !errors.contains(kPasswordNullError)) {
          setState(() {
            errors.add(kPasswordNullError);
          });
          return "";
        } else if (value.length < 8 && !errors.contains(kShortPasswordError)) {
          setState(() {
            errors.add(kShortPasswordError);
          });
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

  TextFormField buildEmailFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue!,
      onChanged: (value) {
        if (value.isNotEmpty && errors.contains(kEmailNullError)) {
          setState(() {
            errors.remove(kEmailNullError);
          });
        } else if (emailValidatorRegExp.hasMatch(value) &&
            errors.contains(kInvalidEmailError)) {
          setState(() {
            errors.remove(kInvalidEmailError);
          });
        }
      },
      validator: (value) {
        if (value!.isEmpty && !errors.contains(kEmailNullError)) {
          setState(() {
            errors.add(kEmailNullError);
          });
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value) &&
            !errors.contains(kInvalidEmailError)) {
          setState(() {
            errors.add(kInvalidEmailError);
          });
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
