import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class RequestAssistant {
  static Future<dynamic> receiveRequest(String url) async {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try {
      if (httpResponse.statusCode == 200) {
        String responseData = httpResponse.body;

        var decodeResponseData = jsonDecode(responseData);

        return decodeResponseData;
      } else {
        return "error_occured";
      }
    } catch (ex) {
      developer.log(
          "Error occured in request_assistant - > receiveRequest -> try catch " +
              ex.toString(),
          name: "RequestAssistant");

      return "error_occured";
    }
  }
}
