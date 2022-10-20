import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/models/user_ride_request.dart';
import 'package:taxi4hire/screens/ride_request/driver_new_ride_request.dart';

class BookingRequestsTabPage extends StatefulWidget {
  const BookingRequestsTabPage({Key? key}) : super(key: key);

  @override
  State<BookingRequestsTabPage> createState() => _BookingRequestsTabPageState();
}

class _BookingRequestsTabPageState extends State<BookingRequestsTabPage> {
  List<UserRideRequest> _userRideRequestList = [];
  final ref = FirebaseDatabase.instance.ref("ride_request");

  Future getBookingRequestList() async {
    var data = await FirebaseDatabase.instance.ref().child("ride_request");
  }

  bool _tileExpanded = false;
  int _expandedTile = -1;

  void acceptBookRequest(String userId, String rideRequestId) async {
    print(
        "DEBUG > booking_request_tab > accept Request > userId : $userId > rideRequestId : $rideRequestId");

    DatabaseReference rideRequestDetailsReference = FirebaseDatabase.instance
        .ref()
        .child("ride_request")
        .child(rideRequestId);

    final rideRequestDetailsSnapshot = await rideRequestDetailsReference.get();

    DatabaseReference requesterReference = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(userId)
        .child("ride_request");
    final requestSnapshot = await requesterReference.get();

    DatabaseReference driverUserReference = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(userModelCurrentInfo!.id!)
        .child("ride_request");
    final userSnapshot = await driverUserReference.get();

    DatabaseReference rideRequestDriverIdReference = FirebaseDatabase.instance
        .ref()
        .child("ride_request")
        .child(rideRequestId)
        .child("driverId");
    final rideRequestSnapshot = await rideRequestDriverIdReference.get();

    //print(
    //    "DEBUG > booking_request_tab > acceptRequest > requestSnapShot : ${requestSnapshot.value} > userSnapShot : ${userSnapshot.value}> rideRequestSnapshot : ${rideRequestSnapshot.value}");

    if (requestSnapshot.value.toString() == "waiting" &&
        userSnapshot.value.toString() == "idle" &&
        rideRequestSnapshot.value.toString() == "waiting") {
      if (rideRequestSnapshot.value != null) {
        //driverUserReference.set("accepted");

        double sourceLat = double.parse(
            (rideRequestDetailsSnapshot.value! as Map)["source"]["latitude"]);

        double sourceLng = double.parse(
            (rideRequestDetailsSnapshot.value! as Map)["source"]["longitude"]);

        String sourceAddress =
            (rideRequestDetailsSnapshot.value! as Map)["sourceAddress"];

        double destinationLat = double.parse((rideRequestDetailsSnapshot.value!
            as Map)["destination"]["latitude"]);

        double destinationLng = double.parse((rideRequestDetailsSnapshot.value!
            as Map)["destination"]["longitude"]);

        String destinationAddress =
            (rideRequestDetailsSnapshot.value! as Map)["destinationAddress"];

        String userName = (rideRequestDetailsSnapshot.value! as Map)["email"];
        String userPhone = (rideRequestDetailsSnapshot.value! as Map)["mobile"];

        UserRideRequest userRideRequest = UserRideRequest();

        userRideRequest.sourceLatLng = LatLng(sourceLat, sourceLng);
        userRideRequest.sourceAddress = sourceAddress;
        userRideRequest.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        userRideRequest.destinationAddress = destinationAddress;
        userRideRequest.userName = userName;
        userRideRequest.userPhone = userPhone;
        userRideRequest.rideRequestId = rideRequestId;
        globalRideRequestDetail = userRideRequest;

        Navigator.pushNamed(context, DriverNewRideRequestScreen.routeName,
            arguments: userRideRequest);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: double.infinity,
        child: FirebaseAnimatedList(
          query: ref,
          itemBuilder: (context, snapshot, animation, index) {
            return Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                child: ExpansionTile(
                  iconColor: kPrimaryColor,
                  collapsedBackgroundColor: Colors.grey[200],
                  childrenPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  title: Text(
                    "To: " +
                        snapshot.child("destinationAddress").value.toString(),
                    style: TextStyle(color: kPrimaryColor),
                  ),
                  subtitle: Text(
                    "From: " + snapshot.child("sourceAddress").value.toString(),
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "From: " +
                          snapshot.child("sourceAddress").value.toString(),
                    ),
                    Text("Distance: " +
                        snapshot.child("distance").value.toString()),
                    Text("Duration: " +
                        snapshot.child("duration").value.toString()),
                    Text("Estimated Earnings: S\$" +
                        snapshot.child("price").value.toString()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Accept",
                        ),
                        IconButton(
                          onPressed: () {
                            acceptBookRequest(
                                snapshot.child("userId").value.toString(),
                                snapshot!.key!);
                          },
                          icon: const Icon(Icons.check, color: kPrimaryColor),
                        ),
                      ],
                    )
                  ],
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _tileExpanded = expanded;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
