import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:taxi4hire/animation/FadeAnimation.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/booking_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/screens/main_map/widget/taxi_list_tile_widget.dart';
import 'package:taxi4hire/size_config.dart';

class BookRequestPanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;

  const BookRequestPanelWidget({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

  @override
  State<BookRequestPanelWidget> createState() => _BookRequestPanelWidgetState();
}

class _BookRequestPanelWidgetState extends State<BookRequestPanelWidget> {
  DatabaseReference? referenceRideRequest;
  DatabaseReference? userReference;
  int selectedTaxi = 0;

  bool bookingRequest = false;
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: (Provider.of<AppInfo>(context, listen: false)
                      .userDropOffLocation !=
                  null) &&
              (Provider.of<AppInfo>(context, listen: false).taxiList != null)
          ? bookingRequest == false
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: getProportionateScreenHeight(10),
                      ),
                      const Text(
                        "Select a ride",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(200),
                        child: ListView.builder(
                          itemCount:
                              (Provider.of<AppInfo>(context, listen: false)
                                          .taxiList !=
                                      null)
                                  ? Provider.of<AppInfo>(context, listen: false)
                                      .taxiList!
                                      .length
                                  : 0,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedTaxi != index)
                                    selectedTaxi = index;
                                });
                              },
                              child: Card(
                                color: selectedTaxi == index
                                    ? kPrimaryColor
                                    : Colors.grey[300],
                                elevation: 1,
                                shadowColor: Colors.grey,
                                margin: const EdgeInsets.all(4.0),
                                child: ListTile(
                                  leading: Image.asset(
                                    Provider.of<AppInfo>(context)
                                        .taxiList![index]
                                        .imgUrl!,
                                    width: 70,
                                  ),
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        Provider.of<AppInfo>(context)
                                            .taxiList![index]
                                            .type!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: selectedTaxi == index
                                              ? Colors.white
                                              : kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "\$" +
                                            Provider.of<AppInfo>(context)
                                                .taxiList![index]
                                                .price!,
                                        style: TextStyle(
                                            height: 1.1,
                                            fontWeight: FontWeight.bold,
                                            color: selectedTaxi == index
                                                ? Colors.white
                                                : kPrimaryColor),
                                      ),
                                      Text(
                                        Provider.of<AppInfo>(context)
                                            .taxiList![index]
                                            .duration!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          height: 1.1,
                                          color: selectedTaxi == index
                                              ? Colors.white70
                                              : kPrimaryColor,
                                        ),
                                      ),
                                      Text(
                                        Provider.of<AppInfo>(context)
                                            .taxiList![index]
                                            .distance!,
                                        style: TextStyle(
                                          height: 1.1,
                                          fontWeight: FontWeight.normal,
                                          color: selectedTaxi == index
                                              ? Colors.white70
                                              : kPrimaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DefaultButton(
                            text: "Request a ride",
                            press: () {
                              if (Provider.of<AppInfo>(context, listen: false)
                                      .userDropOffLocation !=
                                  null) {
                                //saveRideRequestInformation();
                                setState(() {
                                  bookingRequest = true;
                                  print(
                                      "DEBUG : panel_widget.dart > DefaultButton > bookRideRequest");
                                  referenceRideRequest = bookRideRequest(
                                      referenceRideRequest,
                                      context,
                                      Provider.of<AppInfo>(context,
                                              listen: false)
                                          .taxiList![selectedTaxi]);

                                  userReference = FirebaseDatabase.instance
                                      .ref()
                                      .child("users")
                                      .child(currentFirebaseUser!.uid)
                                      .child("ride_request");

                                  userReference!.set("waiting");
                                  userReference!.onValue.listen((event) {
                                    print(
                                        "DEBUG : user ride_request changed to : " +
                                            event.snapshot.value.toString());
                                  });

                                  Future.delayed(Duration(seconds: 10), () {
                                    print(
                                        "DEBUG : booking_request_panel_widget > Future");
                                    if (userReference != null) {}
                                  });
                                });
                                Provider.of<AppInfo>(context, listen: false)
                                    .updateRequestRideStatus(true);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Please select a destination");
                              }
                            }),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: getProportionateScreenHeight(10),
                      ),
                      const Text(
                        "Finding a ride..",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(50),
                      ),
                      SizedBox(
                        child: Card(
                          color: kPrimaryColor,
                          elevation: 1,
                          shadowColor: Colors.grey,
                          margin: const EdgeInsets.all(4.0),
                          child: ListTile(
                            leading: Image.asset(
                              Provider.of<AppInfo>(context)
                                  .taxiList![selectedTaxi]
                                  .imgUrl!,
                              width: 70,
                            ),
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  Provider.of<AppInfo>(context)
                                      .taxiList![selectedTaxi]
                                      .type!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "\$" +
                                      Provider.of<AppInfo>(context)
                                          .taxiList![selectedTaxi]
                                          .price!,
                                  style: TextStyle(
                                      height: 1.1,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                      .taxiList![selectedTaxi]
                                      .duration!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    height: 1.1,
                                    color: selectedTaxi == selectedTaxi
                                        ? Colors.white70
                                        : kPrimaryColor,
                                  ),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                      .taxiList![selectedTaxi]
                                      .distance!,
                                  style: TextStyle(
                                    height: 1.1,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: getProportionateScreenHeight(80),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DefaultButton(
                            text: "Cancel ride request",
                            press: () {
                              if (Provider.of<AppInfo>(context, listen: false)
                                      .userDropOffLocation !=
                                  null) {
                                Provider.of<AppInfo>(context, listen: false)
                                    .updateRequestRideStatus(false);
                                setState(() {
                                  print(
                                      "DEBUG : booking_request_panel_widget > Cancel Click");
                                  userReference!.set("idle");
                                  bookingRequest = false;
                                  referenceRideRequest!.remove();
                                  userReference!.onDisconnect();
                                  userReference = null;
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Ride cannot be cancelled");
                              }
                            }),
                      ),
                    ],
                  ),
                )
          : Container(
              child: Center(
                child: Text("Please specify a destination"),
              ),
            ),
    );
  }
}
