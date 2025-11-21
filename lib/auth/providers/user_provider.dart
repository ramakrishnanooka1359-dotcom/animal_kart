import 'dart:convert';
import 'dart:io';
import 'package:animal_kart_demo2/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

final userProfileProvider = ChangeNotifierProvider<UserProfileNotifier>(
  (ref) => UserProfileNotifier(),
);

class UserProfileNotifier extends ChangeNotifier {
  Future<Map<String, String>> saveAdharDetailsToDb({
    required File aadhaarFront,
    File? aadhaarBack,
    required String userId,
  }) async {
    final now = DateTime.now();
    final dateFolder =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Prepare JSON payload with bucket info + base64 images
    final payload = <String, dynamic>{
      'bucket_name': 'markwave-kart',
      'folder_path': 'userpics/$dateFolder',
      'user_id': userId,
      'aadhaar_front_base64': base64Encode(await aadhaarFront.readAsBytes()),
    };

    if (aadhaarBack != null) {
      payload['aadhaar_back_base64'] = base64Encode(
        await aadhaarBack.readAsBytes(),
      );
    }

    final response = await http.post(
      Uri.parse('${AppConstants.apiUrl}/markwave-kart'),
      headers: {HttpHeaders.contentTypeHeader: AppConstants.applicationJson},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      return {};
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final urls = <String, String>{};

    if (data['aadhaar_front_url'] is String) {
      urls['aadhaar_front_url'] = data['aadhaar_front_url'] as String;
    }
    if (data['aadhaar_back_url'] is String) {
      urls['aadhaar_back_url'] = data['aadhaar_back_url'] as String;
    }

    return urls;
  }
}
