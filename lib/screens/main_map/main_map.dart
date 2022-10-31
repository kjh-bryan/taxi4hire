import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:taxi4hire/assistants/assistant_methods.dart';
import 'package:taxi4hire/constants.dart';
import 'package:taxi4hire/controller/booking_controller.dart';
import 'package:taxi4hire/global/global.dart';
import 'package:taxi4hire/infohandler/app_info.dart';
import 'package:taxi4hire/models/user_model.dart';
import 'package:taxi4hire/screens/main_map/tabs/book_request_tab.dart';
import 'package:taxi4hire/screens/main_map/tabs/booking_requests_tab.dart';
import 'package:taxi4hire/screens/main_map/tabs/home_tab.dart';
import 'package:taxi4hire/screens/main_map/tabs/profile_tab.dart';
import 'package:taxi4hire/size_config.dart';
import 'dart:developer' as developer;

class MainMap extends StatefulWidget {
  static String routeName = "/main_map";
  const MainMap({Key? key}) : super(key: key);

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 3, vsync: this);
  int selectedIndex = 0;
  var geoLocation = Geolocator();
  UserModel? localUserModel;

  onItemClicked(int index) {
    setState(() {
      selectedIndex = index;
      tabController.index = selectedIndex;
    });
  }

  LocationPermission? _locationPermission;

  checkIfLocationPermissionAllowed() async {
    localUserModel = await AssistantMethods.readCurrentOnlineUserInfo();
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    tabController.addListener(() {
      developer.log(
          "printing tabController listner " + tabController.index.toString(),
          name: "Main Map");

      Provider.of<AppInfo>(context, listen: false)
          .updateTabIndex(tabController.index);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
    streamSubscriptionLivePosition!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          HomeTabPage(tabNumber: tabController.index),
          (userModelCurrentInfo!.role.toString() == "0")
              ? const BookingRequestsTabPage()
              : const BookRequestsTabPage(),
          const ProfileTabPage(),
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
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
        ),
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: kPrimaryColor,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: getProportionateScreenWidth(12),
          fontWeight: FontWeight.bold,
        ),
        selectedFontSize: getProportionateScreenWidth(12),
        unselectedFontSize: getProportionateScreenWidth(10),
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
