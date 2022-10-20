import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:taxi4hire/components/default_button.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/models/user_ride_request.dart';

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
              child: ExpansionTile(
                title: Text(
                  "To: " +
                      snapshot.child("destinationAddress").value.toString(),
                ),
                style: TextStyle(
                  color: kPrimaryColor,
                ),
                subtitle: Text(
                  "From: " + snapshot.child("sourceAddress").value.toString(),
                ),
                iconColor: kPrimaryColor,
                backgroundColor: kPrimaryColor,
                textColor: Colors.white,
                children: [
                  Text(
                    "From: " + snapshot.child("sourceAddress").value.toString(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Accept",
                      ),
                      IconButton(
                        onPressed: () {},
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
            );
          },
        ),
      ),
    );
  }
}
