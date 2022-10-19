import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi4hire/screens/main_map/widget/current_location_data.dart';
import 'package:taxi4hire/screens/main_map/widget/source_destination_map_data.dart';

class StateContainer extends StatefulWidget {
  final Widget child;

  CurrentLocation? currentLocation;
  SourceDestinationMap? sourceDestinationMap;

  StateContainer(
      {Key? key,
      required this.child,
      this.currentLocation,
      this.sourceDestinationMap})
      : super(key: key);

  static StateContainerState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<TabInheritedWidget>()
            as TabInheritedWidget)
        .data;
  }

  @override
  State<StateContainer> createState() => StateContainerState();
}

class StateContainerState extends State<StateContainer> {
  CurrentLocation? currentLocation;
  SourceDestinationMap? sourceDestinationMap;

  void updateCurrentLocation(Position position) {
    if (currentLocation == null) {
      currentLocation = new CurrentLocation(currentLocation: position);
      setState(() {
        currentLocation = currentLocation;
      });
    } else {
      setState(() {
        currentLocation!.currentLocation = position;
      });
    }
  }

  void updateSourceDestination(
      Position sourceLocation, Position destinationLocation) {
    if (sourceDestinationMap == null) {
      sourceDestinationMap = new SourceDestinationMap(
          sourceLocation: sourceLocation,
          destinationLocation: destinationLocation);
      setState(() {
        sourceDestinationMap = sourceDestinationMap;
      });
    } else {
      setState(() {
        sourceDestinationMap!.destinationLocation = destinationLocation;
        sourceDestinationMap!.sourceLocation = sourceLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

class TabInheritedWidget extends InheritedWidget {
  final StateContainerState data;

  TabInheritedWidget({
    Key? key,
    required this.child,
    required this.data,
  }) : super(key: key, child: child);

  final Widget child;

  @override
  bool updateShouldNotify(TabInheritedWidget oldWidget) {
    return true;
  }
}
