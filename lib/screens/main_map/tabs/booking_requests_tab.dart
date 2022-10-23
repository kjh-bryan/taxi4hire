import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/booking_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/models/user_ride_request.dart';
import 'package:taxi4hire/screens/ride_request/driver_new_ride_request.dart';

class BookingRequestsTabPage extends StatefulWidget {
  const BookingRequestsTabPage({Key? key}) : super(key: key);

  @override
  State<BookingRequestsTabPage> createState() => _BookingRequestsTabPageState();
}

class _BookingRequestsTabPageState extends State<BookingRequestsTabPage> {
  final ride_request_reference = FirebaseDatabase.instance.ref("ride_request");

  List<UserRideRequest> _userRideRequestList = [];

  bool _tileExpanded = false;
  int _expandedTile = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ride_request_reference.onChildAdded.listen(_childAdded);
    ride_request_reference.onChildRemoved.listen(_childRemoved);
    ride_request_reference.onChildChanged.listen(_childChanged);
  }

  _childAdded(DatabaseEvent event) {
    if (event.snapshot.child("driverId").value == "waiting") {
      setState(() {
        _userRideRequestList.add(UserRideRequest.fromSnapshot(event.snapshot));
      });
    }
  }

  _childRemoved(DatabaseEvent event) {
    var deletingRideRequest = _userRideRequestList.singleWhere((rideRequest) {
      return rideRequest.rideRequestId == event.snapshot.key;
    });
    setState(() {
      _userRideRequestList
          .removeAt(_userRideRequestList.indexOf(deletingRideRequest));
    });
  }

  _childChanged(DatabaseEvent event) {
    print("DEBUG : CHILDCHANGED");
    if (event.snapshot.child("driverId").value == "waiting") {
      setState(() {
        _userRideRequestList.add(UserRideRequest.fromSnapshot(event.snapshot));
      });
    } else {
      var deletingRideRequest = _userRideRequestList.singleWhere((rideRequest) {
        return rideRequest.rideRequestId == event.snapshot.key;
      });
      setState(() {
        _userRideRequestList
            .removeAt(_userRideRequestList.indexOf(deletingRideRequest));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: double.infinity,
        child: (_userRideRequestList.isEmpty)
            ? SizedBox(
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "No available booking requests",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              )
            : FirebaseAnimatedList(
                query: ride_request_reference
                    .orderByChild("driverId")
                    .equalTo("waiting"),
                itemBuilder: (context, snapshot, animation, index) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                      child: ExpansionTile(
                        iconColor: kPrimaryColor,
                        collapsedBackgroundColor: Colors.grey[200],
                        childrenPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        title: Text(
                          "To: " +
                              snapshot
                                  .child("destinationAddress")
                                  .value
                                  .toString(),
                          style: TextStyle(color: kPrimaryColor),
                        ),
                        subtitle: Text(
                          "From: " +
                              snapshot.child("sourceAddress").value.toString(),
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From: " +
                                snapshot
                                    .child("sourceAddress")
                                    .value
                                    .toString(),
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
                                  acceptRideRequest(
                                      context,
                                      snapshot.child("userId").value.toString(),
                                      snapshot.key!);
                                },
                                icon: const Icon(Icons.check,
                                    color: kPrimaryColor),
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
