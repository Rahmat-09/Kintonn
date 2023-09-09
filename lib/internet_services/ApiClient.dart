import 'dart:convert';
import 'dart:io';

import 'package:untitled/internet_services/path.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  var client = http.Client();

  Future login(String driverEmail, String driverPassword) async {
    var url = Uri.http(baseUrl, login_driver);
    try {
      var response = await client.post(
        url,
        body: {
          'driver_email': driverEmail,
          'driver_password': driverPassword,
        },
      );

      return response;
    } on SocketException {
      return "Tidak Ada Koneksi Internet 😑";
    }
  }

  Future<dynamic> drawRoute(currentPosition,destinantionPosition) async{
    var url = Uri.parse("https://router.project-osrm.org/route/v1/driving/${currentPosition!.longitude},${currentPosition!.latitude};${destinantionPosition.longitude},${destinantionPosition.latitude}?steps=true&annotations=true&geometries=geojson&overview=full");
    var response =  await http.get(url);


    return response;
  }

  Future getUserProfileData(String accessToken) async {
    final query = {'token': accessToken};
    var url = Uri.http(baseUrl, driver, query);
    try {
      var response = await client.get(
        url,
      );

      var res = jsonDecode(response.body);
      var drivers = res['dataDrivers'] as List;

      return drivers[0];
    } on SocketException {
      return "Tidak Ada Koneksi Internet 😑";
    }
  }

  Future updateUserStatusData(String accessToken, String isStatus) async {
    var url = Uri.http(baseUrl, updateStatus);
    try {
      var response = await client.post(
        url,
        body: {
          'token': accessToken,
          'is_status': isStatus,
        },
      );

      var res = jsonDecode(response.body);


      return res;
    } on SocketException {
      return "Tidak Ada Koneksi Internet 😑";
    }
  }

  Future updateUserBalance(String accessToken, double balance) async {
    var url = Uri.http(baseUrl, updateBalance);
    try {
      var response = await client.post(
        url,
        body: {
          'token': accessToken,
          'balance': balance.toString(),
        },
      );

      var res = jsonDecode(response.body);
      return res;
    } on SocketException {
      return "Tidak Ada Koneksi Internet 😑";
    }
  }
}
