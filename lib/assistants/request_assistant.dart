import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_config/flutter_config.dart';

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;

        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      } else {
        print("Error occured in request_assistant - > receiveRequest");
        return "error_occured";
      }
    } catch (ex) {
      print(
          "Error occured in request_assistant - > receiveRequest -> try catch " +
              ex.toString());
      return "error_occured";
    }
  }
}
