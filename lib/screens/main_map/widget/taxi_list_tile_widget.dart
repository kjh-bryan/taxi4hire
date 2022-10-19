import 'package:flutter/material.dart';

class TaxiListTileWidget extends StatelessWidget {
  final String taxiType;
  final String taxiImageUrl;
  final String price;
  final bool isSelected;

  const TaxiListTileWidget({
    Key? key,
    required this.taxiType,
    required this.taxiImageUrl,
    required this.price,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile();
  }
}
