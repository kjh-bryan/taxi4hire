import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi4hire/models/direction_details_info.dart';
import 'package:taxi4hire/models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
DirectionDetailsInfo? tripDirectionDetailsInfo;
