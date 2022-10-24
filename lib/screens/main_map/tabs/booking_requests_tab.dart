import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/booking_controller.dart';
import 'package:taxi4hire/models/user_ride_request.dart';

class BookingRequestsTabPage extends StatefulWidget {
  const BookingRequestsTabPage({Key? key}) : super(key: key);

  @override
  State<BookingRequestsTabPage> createState() => _BookingRequestsTabPageState();
}

class _BookingRequestsTabPageState extends State<BookingRequestsTabPage> {
  // Get Firebase Instance that shows all childs of ride_request
  final rideRequestReference = FirebaseDatabase.instance.ref("ride_request");

  final List<UserRideRequest> _userRideRequestList = [];
  bool tileExpanded = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Add listening events whenever child is added, removed or changed;
    rideRequestReference.onChildAdded.listen(_childAdded);
    rideRequestReference.onChildRemoved.listen(_childRemoved);
    rideRequestReference.onChildChanged.listen(_childChanged);
  }

  _childAdded(DatabaseEvent event) {
    //Add to list if child was added to ride_request (Passenger request a ride)
    if (event.snapshot.child("driverId").value == "waiting") {
      if (mounted) {
        setState(() {
          _userRideRequestList
              .add(UserRideRequest.fromSnapshot(event.snapshot));
        });
      } else {
        _userRideRequestList.add(UserRideRequest.fromSnapshot(event.snapshot));
      }
    }
  }

  _childRemoved(DatabaseEvent event) {
    //Remove from list if child was removed in ride_request (Passenger cancelled ride)
    var deletingRideRequest = _userRideRequestList.singleWhere((rideRequest) {
      return rideRequest.rideRequestId == event.snapshot.key;
    });
    if (mounted) {
      setState(() {
        _userRideRequestList
            .removeAt(_userRideRequestList.indexOf(deletingRideRequest));
      });
    } else {
      _userRideRequestList
          .removeAt(_userRideRequestList.indexOf(deletingRideRequest));
    }
  }

  _childChanged(DatabaseEvent event) {
    //Handle event when child of ride_request was changed (Ride Request status changed)
    // if (event.snapshot.child("driverId").value == "waiting") {
    //   setState(() {
    //     _userRideRequestList.add(UserRideRequest.fromSnapshot(event.snapshot));
    //   });
    // } else {
    //   var deletingRideRequest = _userRideRequestList.singleWhere((rideRequest) {
    //     return rideRequest.rideRequestId == event.snapshot.key;
    //   });
    //   setState(() {
    //     _userRideRequestList
    //         .removeAt(_userRideRequestList.indexOf(deletingRideRequest));
    //   });
    // }
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
                query: rideRequestReference
                    .orderByChild("driverId")
                    .equalTo("waiting"),
                itemBuilder: (context, snapshot, animation, index) {
                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      side: BorderSide(color: Colors.grey),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 10.0),
                      child: ExpansionTile(
                        iconColor: kPrimaryColor,
                        collapsedBackgroundColor: Colors.grey[200],
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        title: Text(
                          "To: " +
                              snapshot
                                  .child("destinationAddress")
                                  .value
                                  .toString(),
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "From: " +
                              snapshot.child("sourceAddress").value.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        expandedCrossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From: " +
                                snapshot
                                    .child("sourceAddress")
                                    .value
                                    .toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Distance: " +
                                snapshot.child("distance").value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Duration: " +
                                snapshot.child("duration").value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Estimated Earnings: S\$" +
                                snapshot.child("price").value.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                "Accept",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: kPrimaryColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    BookingController().acceptRideRequest(
                                        context,
                                        snapshot
                                            .child("userId")
                                            .value
                                            .toString(),
                                        snapshot.key!);
                                  },
                                  icon: const Icon(Icons.check,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                        onExpansionChanged: (bool expanded) {
                          setState(() {
                            tileExpanded = expanded;
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
