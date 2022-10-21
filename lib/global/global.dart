import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi4hire/models/direction_details_info.dart';
import 'package:taxi4hire/models/user_model.dart';
import 'package:taxi4hire/models/user_ride_request.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
StreamSubscription<Position>? streamSubscriptionLivePosition;
StreamSubscription<Position>? streamSubscriptionRideRequestLivePosition;
DirectionDetailsInfo? tripDirectionDetailsInfo;
UserRideRequest? globalRideRequestDetail;
Position? userCurrentLocation;
