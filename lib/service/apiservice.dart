import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hpackweb/constants/apiconstants.dart';
import 'package:hpackweb/models/customerModel.dart';
import 'package:hpackweb/network/networkclient.dart';
import 'package:hpackweb/network/networkresponse.dart';
import 'package:hpackweb/utils/sharedpref.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<http.Response> getloginRequest(dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}api/Price/PriceListLogin'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<List<CustomerModel>> getpricecustomerlist({
    String filter = "",
  }) async {
    var body = {"salesEmployeeId": Prefs.getEmpID()};
    Map<String, String> headers = {"Content-Type": "application/json"};
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}api/Price/GetPriceListCustomer'),
      body: jsonEncode(body),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['response'];

      if (filter.isEmpty) {
        return data.map((item) => CustomerModel.fromJson(item)).toList();
      }
      return data
          .map((item) => CustomerModel.fromJson(item))
          .where(
            (item) =>
                item.cardCode.toString().toLowerCase().contains(
                  filter.toString().toLowerCase(),
                ) ||
                item.cardName.toString().toLowerCase().contains(
                  filter.toString().toLowerCase(),
                ),
          )
          .toList();
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<http.Response> getpricelistdetails(dynamic body) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}api/Price/GetPriceList'),
        headers: headers,
        body: jsonEncode(body),
      );
      print('🔗 URL: ${ApiConstants.baseUrl}api/Price/GetPriceList');
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<http.Response> postPriceUpdate(dynamic body) async {
    const headers = {
      "Content-Type": "application/json",
      "Accept": "application/json", // ✅ Optional, but recommended
    };

    try {
      final jsonBody = jsonEncode(body);

      // ✅ DEBUG PRINT
      // print("Request Body:\n$jsonBody");

      final response = await http.post(
        Uri.parse('${ApiConstants.mobileURL}api/items/insert-header-details'),
        headers: headers,
        body: jsonBody,
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<http.Response> getAllList(dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.mobileURL}api/items/pending-Approvelist'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<http.Response> getDetailByDocEntry(int docEntry) {
    try {
      final response = http.get(
        Uri.parse('${ApiConstants.mobileURL}api/items/$docEntry'),
        headers: {"Content-Type": "application/json"},
      );
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<http.Response> priceUpdatePendingOrApproved(
    dynamic body,
  ) async {
    const headers = {
      "Content-Type": "application/json",
      "Accept": "application/json", // ✅ Optional, but recommended
    };

    try {
      final jsonBody = jsonEncode(body);

      // ✅ DEBUG PRINT
      // print("Request Body:\n$jsonBody");

      final response = await http.post(
        Uri.parse('${ApiConstants.mobileURL}api/items/updateDocentry'),
        headers: headers,
        body: jsonBody,
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<http.Response> checkCustmerexists(String cardCode) {
    try {
      var body = {"cardCode": cardCode};
      final response = http.post(
        Uri.parse('${ApiConstants.mobileURL}api/items/getcustomer'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }

  static Future<http.Response> updateApproval(dynamic body) async {
    const headers = {
      "Content-Type": "application/json",
      "Accept": "application/json", // ✅ Optional, but recommended
    };

    try {
      final jsonBody = jsonEncode(body);

      // ✅ DEBUG PRINT
      // print("Request Body:\n$jsonBody");

      final response = await http.post(
        Uri.parse('${ApiConstants.mobileURL}api/items/updateApproval'),
        headers: headers,
        body: jsonBody,
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      throw HttpException("Network error: ${e.toString()}");
    }
  }
}
