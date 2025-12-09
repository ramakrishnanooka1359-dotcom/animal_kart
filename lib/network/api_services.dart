import 'dart:convert';
import 'dart:io';

import 'package:animal_kart_demo2/auth/models/device_details.dart';
import 'package:animal_kart_demo2/auth/models/whatsapp_otp_response.dart';
import 'package:animal_kart_demo2/buffalo/models/buffalo.dart';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static Future<DeviceDetails> fetchDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return DeviceDetails(id: info.id, model: info.model);
    }

    if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return DeviceDetails(
        id: info.identifierForVendor.toString(),
        model: info.utsname.machine,
      );
    }

    return const DeviceDetails(id: '', model: '');
  }

  static Future<Buffalo> fetchBuffaloById(String id) async {
    final url = '${AppConstants.apiUrl}/products/$id';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonBody = json.decode(res.body);
      final product = jsonBody["product"];
      return Buffalo.fromJson(product);
    } else {
      throw Exception("Failed to load buffalo details");
    }
  }

  static Future<List<Buffalo>> fetchBuffaloList() async {
    final url = '${AppConstants.apiUrl}/products';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonBody = json.decode(res.body);
      final List products = jsonBody["products"];

      return products.map((e) => Buffalo.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load buffalo list");
    }
  }


  static Future<WhatsappOtpResponse?> sendWhatsappOtp(String phone) async {
  try {
    final response = await http.post(
      Uri.parse(
        "https://markwave-live-apis-couipk45fa-el.a.run.app/otp/send-whatsapp",
      ),
      headers: {
        HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
      },
      body: jsonEncode({"mobile": phone,  "appName":"animalkart"}),
);

    final data = jsonDecode(response.body);
    return WhatsappOtpResponse.fromJson(data);
  } catch (e) {
    return null;
  }
}

static Future<bool> updateUserProfile({
  required String mobile,
  required Map<String, dynamic> body,
}) async {
  try {
    final url =
        "https://markwave-live-apis-couipk45fa-el.a.run.app/users/$mobile";

    final response = await http.put(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: AppConstants.applicationJson,
      },
      body: jsonEncode(body),
    );

    

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["status"] == "success";
    } else {
      return false;
    }
  } catch (e) {
    
    return false;
  }
}


  

  



}