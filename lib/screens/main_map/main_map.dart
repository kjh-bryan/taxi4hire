import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/components/progress_dialog.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/models/user_model.dart';
import 'package:taxi4hire/screens/main_map/tabs/book_request_tab.dart';
import 'package:taxi4hire/screens/main_map/tabs/booking_requests_tab.dart';
import 'package:taxi4hire/screens/main_map/tabs/home_tab.dart';
import 'package:taxi4hire/screens/main_map/tabs/profile_tab.dart';
import 'package:taxi4hire/size_config.dart';

class MainMap extends StatefulWidget {
  static String routeName = "/main_map";
  const MainMap({Key? key}) : super(key: key);

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with SingleTickerProviderStateMixin {
  TabController? tabController;
  int selectedIndex = 0;
  var geoLocation = Geolocator();

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController!.index = selectedIndex;
    });
  }

  LocationPermission? _locationPermission;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    } else {
      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext c) {
      //       return ProgressDialog(message: "Getting your location..");
      //     });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(),
          (userModelCurrentInfo!.role.toString() == "0")
              ? BookingRequestsTabPage()
              : BookRequestsTabPage(),
          ProfileTabPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          userModelCurrentInfo!.role.toString() == "0"
              ? const BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_rounded),
                  label: "Booking Requests",
                )
              : const BottomNavigationBarItem(
                  icon: Icon(Icons.touch_app),
                  label: "Book Request",
                ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
        unselectedLabelStyle: TextStyle(),
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: kPrimaryColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: getProportionateScreenWidth(11),
        ),
        unselectedFontSize: getProportionateScreenWidth(10),
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
