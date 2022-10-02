import 'package:flutter/material.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/components/form_error.dart';
import 'package:taxi4hire/components/no_account_text.dart';
import 'package:taxi4hire/components/suffix_icon.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/size_config.dart';

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(35),
          ),
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.screenHeight! * 0.08,
              ),
              Text(
                "Forget Password",
                style: TextStyle(
                    fontSize: getProportionateScreenWidth(28),
                    color: Colors.black,
                    fontWeight: FontWeight.w300),
              ),
              const Text(
                "Please enter your email and we will send \nyou a link to reset your account",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: SizeConfig.screenHeight! * 0.12,
              ),
              ForgetPasswordForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgetPasswordForm extends StatefulWidget {
  const ForgetPasswordForm({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final _formKey = GlobalKey<FormState>();

  List<String> errors = [];
  late String email;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
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
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.add(kInvalidEmailError);
                });
              }
              return null;
            },
            decoration: const InputDecoration(
              floatingLabelStyle: TextStyle(
                color: kPrimaryColor,
              ),
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSuffixIcon(
                suffixIcon: Icon(Icons.mail_rounded, color: kPrimaryColor),
              ),
            ),
          ),
          SizedBox(
            height: getProportionateScreenHeight(30),
          ),
          FormError(errors: errors),
          SizedBox(
            height: SizeConfig.screenHeight! * 0.10,
          ),
          DefaultButton(
            text: "Reset Password",
            press: () {
              if (_formKey.currentState!.validate()) {
                //do stuff
              }
            },
          ),
          SizedBox(
            height: SizeConfig.screenHeight! * 0.15,
          ),
          NoAccountText(),
        ],
      ),
    );
  }
}
