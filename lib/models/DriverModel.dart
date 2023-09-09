import 'dart:convert';

import '../ui/menu/profile.dart';

class DriverModel {
  String id_driver;
  String username_rider;
  String phone_rider;
  String rider_longitude;
  String rider_latitude;
  String balance_rider;
  String email_rider;
  String password_rider;
  String police_number;
  String type_vehicle;
  String is_active;
  String image_rider;
  String rating_driver;
  String fcm_token;

  String is_status;
  String vehicle_name;
  String location;

  DriverModel(
      {required this.id_driver,
      required this.username_rider,
      required this.phone_rider,
      required this.rider_longitude,
      required this.rider_latitude,
      required this.balance_rider,
      required this.email_rider,
      required this.password_rider,
      required this.police_number,
      required this.type_vehicle,
      required this.is_active,
      required this.image_rider,
      required this.rating_driver,
      required this.fcm_token,
      required this.is_status,
      required this.vehicle_name,
      required this.location});

  DriverModel.fromJson(Map<dynamic, dynamic> json)
      : id_driver = json['id_driver'],
        username_rider = json['username_rider'],
        phone_rider = json['phone_rider'],
        rider_longitude = json['rider_longitude'],
        rider_latitude = json['rider_latitude'],
        balance_rider = json['balance_rider'],
        email_rider = json['email_rider'],
        password_rider = json['password_rider'],
        police_number = json['police_number'],
        type_vehicle = json['type_vehicle'],
        is_active = json['is_active'],
        image_rider = json['image_rider'],
        rating_driver = json['rating_driver'],
        fcm_token = json['fcm_token'],
        is_status = json['is_status'],
        vehicle_name = json['vehicle_name'],
        location = json['location'];

  Map toJson() {
    return {
      'id_rider': id_driver,
      'username_rider': username_rider,
      'phone_rider': phone_rider,
      'rider_longitude': rider_longitude,
      'rider_latitude': rider_latitude,
      'balance_rider': balance_rider,
      'email_rider': email_rider,
      'password_rider': password_rider,
      'police_number': police_number,
      'type_vehicle': type_vehicle,
      'is_active': is_active,
      'image_rider': image_rider,
      'rating_driver': rating_driver,
      'fcm_token': fcm_token,
      'is_status': is_status,
      'vehicle_name': vehicle_name,
      'location': location
    };
  }

  @override
  String toString() {
    return 'DriverModel{id_rider: $id_driver, username_rider: $username_rider, phone_rider: $phone_rider, rider_longitude: $rider_longitude, rider_latitude: $rider_latitude, balance_rider: $balance_rider, email_rider: $email_rider, password_rider: $password_rider, police_number: $police_number, type_vehicle: $type_vehicle, is_active: $is_active, image_rider: $image_rider, rating_driver: $rating_driver, fcm_token: $fcm_token, vehicle_name: $vehicle_name, location: $location}';
  }

  List<DriverModel> driverFromJson(String jsonData) {
    final data = json.decode(jsonData);
    return List<DriverModel>.from(
        data.map((item) => DriverModel.fromJson(item)));
  }

  String driverToJson(DriverModel data) {
    final jsonData = data.toJson();
    return json.encode(jsonData);
  }
}
