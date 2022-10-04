import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/form_error.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/components/suffix_icon.dart';
import 'package:taxi4hire/constants.dart';
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
                  "as Customer",
                  style: TextStyle(
                    fontSize: getProportionateScreenWidth(12),
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              FadeAnimation(
                1.2,
                SignUpCustomerForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpCustomerForm extends StatefulWidget {
  const SignUpCustomerForm({Key? key}) : super(key: key);

  @override
  State<SignUpCustomerForm> createState() => _SignUpCustomerFormState();
}

class _SignUpCustomerFormState extends State<SignUpCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  late String email;
  String? password;
  String? confirm_password;
  late String mobile_no;
  final List<String> errors = [];

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileNoController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    mobileNoController.dispose();
    super.dispose();
  }

  saveUserInfo() async {
    print("Test 1");

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return ProgressDialog(message: "Signing up.. Please wait..");
        });

    print("Test 2");
    final User firebaseUser;
    try {
      print("Test 4");
      final UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      firebaseUser = userCredential.user!;

      if (firebaseUser != null) {
        print("Test 5");
        Map userMap = {
          "id": firebaseUser.uid,
          "email": emailController.text.trim(),
          "mobile": mobileNoController.text.trim(),
          "license_plate": "",
          "role": 1
          //role : 1 as passenger
        };

        DatabaseReference taxiDriversRef =
            FirebaseDatabase.instance.ref().child('users');

        taxiDriversRef.child(firebaseUser.uid).set(userMap);

        currentFirebaseUser = firebaseUser;

        Fluttertoast.showToast(msg: "Registration successful, Redirecting..");

        Navigator.popAndPushNamed(context, SignInScreen.routeName);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Fluttertoast.showToast(msg: "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: "The account already exists for that email.");
      }
      print("Inside FirebaseAuthException catch (e) " + e.toString());
      Navigator.pop(context);
    } catch (e) {
      print("Test 8");
      print(e);
      Navigator.pop(context);
    }

    print("Test 3");
  }

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
          FormError(errors: errors),
          SizedBox(
            height: getProportionateScreenHeight(30),
          ),
          DefaultButton(
            text: "Sign Up",
            press: () {
              if (_formKey.currentState!.validate()) {
                saveUserInfo();
                // Go to Login Page
              }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildMobileNoFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: mobileNoController,
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
      onSaved: (newValue) => confirm_password = newValue!,
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
      controller: passwordController,
      onSaved: (newValue) => password = newValue!,
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
      controller: emailController,
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
