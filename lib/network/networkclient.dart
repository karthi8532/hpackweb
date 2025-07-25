// import 'dart:convert';
// import 'package:hpackweb/network/networkresponse.dart';
// import 'package:http/http.dart' as http;

// class NetworkClient {
//   final String baseUrl;

//   NetworkClient({required this.baseUrl});

//   Future<NetworkResponse> get(String endpoint) async {
//     final url = Uri.parse('$baseUrl$endpoint');
//     try {
//       final response = await http.get(url);
//       return _handleResponse(response);
//     } catch (e) {
//       return NetworkResponse.error('Network error: $e');
//     }
//   }

//   Future<NetworkResponse> post(
//     String endpoint,
//     Map<String, dynamic> data,
//   ) async {
//     final url = Uri.parse('$baseUrl$endpoint');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(data),
//       );
//       return _handleResponse(response);
//     } catch (e) {
//       return NetworkResponse.error('Network error: $e');
//     }
//   }

//   NetworkResponse _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       final json = jsonDecode(response.body);
//       return NetworkResponse.success(json);
//     } else {
//       return NetworkResponse.error(
//         'Error ${response.statusCode}: ${response.reasonPhrase}',
//       );
//     }
//   }
// }
import 'dart:convert';

import 'package:hpackweb/network/networkresponse.dart';
import 'package:http/http.dart' as http;

class NetworkClient {
  String baseUrl;

  NetworkClient({required this.baseUrl});

  void setBaseUrl(String newBaseUrl) {
    baseUrl = newBaseUrl;
  }

  Future<NetworkResponse> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url);
      return _handleResponse(response);
    } catch (e) {
      return NetworkResponse.error('Network error: $e');
    }
  }

  Future<NetworkResponse> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return NetworkResponse.error('Network error: $e');
    }
  }

  NetworkResponse _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return NetworkResponse.success(json);
    } else {
      return NetworkResponse.error(
        'Error ${response.statusCode}: ${response.reasonPhrase}',
      );
    }
  }
}
