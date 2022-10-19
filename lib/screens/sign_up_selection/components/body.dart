import 'package:flutter/material.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/models/service_options.dart';
import 'package:taxi4hire/screens/sign_up/sign_up_screen_customer.dart';
import 'package:taxi4hire/screens/sign_up/sign_up_screen_taxidriver.dart';
import 'package:taxi4hire/size_config.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<ServiceOption> services = [
    ServiceOption(
        'Taxi Driver', 'assets/images/taxi_driver_flat_button_transparent.png'),
    ServiceOption(
        'Customer', 'assets/images/customer_flat_button_transparent.png'),
  ];

  int selectedService = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(25),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                FadeAnimation(
                  0.8,
                  Padding(
                    padding: EdgeInsets.only(
                      top: getProportionateScreenHeight(50),
                    ),
                    child: Text(
                      "Which service \do you need?",
                      style: TextStyle(
                          fontSize: getProportionateScreenWidth(26),
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                FadeAnimation(
                  1.2,
                  Padding(
                    padding: EdgeInsets.only(
                      top: getProportionateScreenHeight(100),
                    ),
                    child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: getProportionateScreenWidth(20),
                        ),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return FadeAnimation(
                              1,
                              serviceContainer(services[index].name,
                                  services[index].imageURL, index));
                        }),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.18,
                ),
                FadeAnimation(
                  1.4,
                  DefaultButton(
                      text: "Continue",
                      press: () {
                        if (selectedService == 0) {
                          Navigator.popAndPushNamed(
                              context, SignUpTaxiDriverScreen.routeName);
                        } else if (selectedService == 1) {
                          Navigator.popAndPushNamed(
                              context, SignUpCustomerScreen.routeName);
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  serviceContainer(String name, String image, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedService != index) selectedService = index;
        });
      },
      child: AnimatedContainer(
          duration: kAnimationDuration,
          padding: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
              color: selectedService == index
                  ? Colors.blue.shade50
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selectedService == index
                    ? Colors.blue
                    : Colors.blue.withOpacity(0),
                width: 2.0,
              )),
          child: Column(
            children: [
              Image.asset(
                image,
                height: getProportionateScreenHeight(80),
              ),
              SizedBox(
                height: getProportionateScreenHeight(10),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: getProportionateScreenWidth(18),
                ),
              ),
            ],
          )),
    );
  }
}
