import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:untitled/helpers/Constant.dart';
import 'package:untitled/helpers/CurrencyFormat.dart';
import 'package:untitled/helpers/HexColor.dart';
import 'package:untitled/models/DriverModel.dart';
import '../../internet_services/ApiClient.dart';

class Home extends StatefulWidget {
  final String accesstoken;

  const Home({Key? key, required this.accesstoken}) : super(key: key);

  @override
  State<Home> createState() => _UserMapInfoState();
}

class _UserMapInfoState extends State<Home> {
  LatLng? _currentPosition;
  var collection = FirebaseFirestore.instance;
  LatLng basePosition = const LatLng(-3.2087078074640756, 104.64408488084912);
  late Future _getCurrentLocationFuture;

  late List<Map<String, dynamic>> orders;
  bool isLoaded = false;

  late FollowOnLocationUpdate _followOnLocationUpdate;
  late StreamController<double?> _followCurrentLocationStreamController;

  List<LatLng> routePoints = [
    const LatLng(-3.2087078074640756, 104.64408488084912)
  ];

  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationFuture = getLocation();
    _followOnLocationUpdate = FollowOnLocationUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 15));

    LatLng location = LatLng(position.latitude, position.longitude);
    _currentPosition = location;

    return true;
  }

  final ApiClient _apiClient = ApiClient();

  Future<DriverModel> getUserData() async {
    dynamic userRes = await _apiClient.getUserProfileData(widget.accesstoken);
    return DriverModel.fromJson(userRes as Map);
  }

  Future fetchRoute(currentPosition, destinationPosition) async {
    dynamic userRes =
        await _apiClient.drawRoute(currentPosition, destinationPosition);

    routePoints = [];
    var router =
        jsonDecode(userRes.body)['routes'][0]['geometry']['coordinates'];
    for (int i = 0; i < router.length; i++) {
      var reep = router[i].toString();
      reep = reep.replaceAll("[", "");
      reep = reep.replaceAll("]", "");

      var lat1 = reep.split(',');
      var lon1 = reep.split(',');
      routePoints.add(LatLng(double.parse(lat1[1]), double.parse(lon1[0])));
    }

    return routePoints;
  }

  Future<void> updateStatus(String token, String isActive) async {
    //get response from ApiClient
     await _apiClient.updateUserStatusData(
      token,
      isActive,
    );


  }

  Future<void> updateBalance(String token, double balance) async {
    //get response from ApiClient
   await _apiClient.updateUserBalance(
      token,
      balance,
    );


  }

  @override
  void dispose() {
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Card(
                  elevation: 6,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    child: const Text(
                      "Error",
                      style: TextStyle(
                          color: Colors.amber, fontWeight: FontWeight.bold),
                    ),
                  ));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            late double balanceDriver;
            if (snapshot.hasData) {
              balanceDriver = double.parse(snapshot.data!.balance_rider);
            }
            return (Text(currencyFormat.convertToIdr(balanceDriver),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)));
          },
        ),
        backgroundColor: HexColor("#ef9904"),
      ),
      body: FutureBuilder(
        future: _getCurrentLocationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(
              alignment: Alignment.bottomRight,
              fit: StackFit.loose,
              children: [
                FlutterMap(
                  options: MapOptions(
                      minZoom: 5,
                      maxZoom: 19,
                      zoom: 16,
                      center: _currentPosition,
                      onPositionChanged:
                          (MapPosition position, bool hasGesture) {
                        if (hasGesture &&
                            _followOnLocationUpdate !=
                                FollowOnLocationUpdate.never) {
                          setState(
                            () => _followOnLocationUpdate =
                                FollowOnLocationUpdate.never,
                          );
                        }
                      }),
                  nonRotatedChildren: [
                    Positioned(
                      right: 20,
                      top: 20,
                      child: FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: () {
                            // Follow the location marker on the map when location updated until user interact with the map.
                            setState(
                              () => _followOnLocationUpdate =
                                  FollowOnLocationUpdate.always,
                            );
                            // Follow the location marker on the map and zoom the map to level 18.
                            _followCurrentLocationStreamController.add(18);
                          },
                          child: Icon(
                            Icons.my_location,
                            color: HexColor("#ef9904"),
                          )),
                    ),
                  ],
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://api.mapbox.com/styles/v1/kinton/clfnisen4000001rrhl74psie/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoia2ludG9uIiwiYSI6ImNsMmNzb3ptMTAyODczbHA3c2UyMGlpaHkifQ.Y3y9ZhRTEf5pBN1fjlRrrg",
                      additionalOptions: const {
                        'mapStyleId': AppConstants.mapboxStyleId,
                        'accessToken': AppConstants.mapboxAccessToken,
                      },
                    ),
                    FutureBuilder(
                        future: getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Card(
                                elevation: 6,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                color: Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  child: const Text(
                                    "Error",
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Card(
                                elevation: 6,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25))),
                                color: Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  child: const CircularProgressIndicator(),
                                ));
                          }
                          late String policeNumber;

                          if (snapshot.hasData) {
                            policeNumber = snapshot.data!.police_number;
                          }

                          return StreamBuilder(
                              stream: collection
                                  .collection("orders")
                                  .where("isOrder", isEqualTo: "onProcessing")
                                  .where("driver_police_number",
                                      isEqualTo: policeNumber)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Card(
                                      elevation: 6,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      color: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        child: const Text(
                                          "Error",
                                          style: TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ));
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Card(
                                      elevation: 6,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25))),
                                      color: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        child:
                                            const CircularProgressIndicator(),
                                      ));
                                }

                                late LatLng destinationPosition;

                                if (snapshot.hasData) {
                                  var order = snapshot.data!.docs;
                                  if (order.isNotEmpty) {
                                    var destinationLatlng =
                                        order[0]['destination_latlng'];

                                    var pickupLatlng =
                                        order[0]['pickup_latlng'];

                                    var statusDriver =
                                        order[0]['status_driver'];

                                    if (statusDriver != "ongoing") {
                                      destinationPosition = LatLng(
                                          destinationLatlng.latitude,
                                          destinationLatlng.longitude);
                                    } else {
                                      destinationPosition = LatLng(
                                          pickupLatlng.latitude,
                                          pickupLatlng.longitude);
                                    }

                                    return FutureBuilder(
                                        future: fetchRoute(_currentPosition,
                                            destinationPosition),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Card(
                                                elevation: 6,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                color: Colors.white,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  child: const Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ));
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Card(
                                                elevation: 6,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    25))),
                                                color: Colors.white,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  child:
                                                      const CircularProgressIndicator(),
                                                ));
                                          }

                                          return PolylineLayer(
                                            polylineCulling: false,
                                            polylines: [
                                              Polyline(
                                                  points: snapshot.data,
                                                  strokeWidth: 5,
                                                  color: HexColor("#ef9904"))
                                            ],
                                          );
                                        });
                                  }
                                }

                                return Container();
                              });
                        }),
                    FutureBuilder(
                        future: getUserData(),
                        builder: (context, snapshot) {
                          late String policeNumber;
                          if (snapshot.hasError) {
                            return Card(
                                elevation: 6,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                color: Colors.white,
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  child: const Text(
                                    "Error",
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Wrap(
                              children: [
                                Card(
                                    elevation: 6,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                    color: Colors.white,
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      child: const CircularProgressIndicator(),
                                    ))
                              ],
                            );
                          }
                          if (snapshot.hasData) {
                            policeNumber = snapshot.data!.police_number;
                          }

                          return markerPosition(collection, policeNumber);
                        }),
                    CurrentLocationLayer(
                      followCurrentLocationStream:
                          _followCurrentLocationStreamController.stream,
                      followOnLocationUpdate: _followOnLocationUpdate,
                      turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                      style: LocationMarkerStyle(
                        marker: const DefaultLocationMarker(
                          color: Colors.white,
                          child: Icon(
                            Icons.navigation,
                            color: Colors.blue,
                          ),
                        ),
                        markerSize: const Size.square(40),
                        markerDirection: MarkerDirection.heading,
                        accuracyCircleColor: Colors.blue.withOpacity(0.1),
                        showAccuracyCircle: true,
                      ),
                      moveAnimationDuration: Duration.zero,
                    )
                  ],
                ),
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(
                      child: FutureBuilder(
                    future: getUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Card(
                            elevation: 6,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            color: Colors.white,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              child: const Text(
                                "Error",
                                style: TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold),
                              ),
                            ));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                            elevation: 6,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25))),
                            color: Colors.white,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              child: const CircularProgressIndicator(),
                            ));
                      }
                      late String isActive;
                      late String colorStatus;
                      late String token;

                      if (snapshot.hasData) {
                        token = snapshot.data!.id_driver;
                        if (snapshot.data!.is_active == "true") {
                          isActive = "Online";
                          colorStatus = "#ef9904";
                        } else {
                          isActive = "Offline";
                          colorStatus = "#cf1204";
                        }
                      }
                      return Card(
                          elevation: 6,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25))),
                          color: Colors.white,
                          child: Container(
                              padding: const EdgeInsets.fromLTRB(15, 6, 15, 6),
                              child: GestureDetector(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.power_settings_new_rounded,
                                      color: HexColor(colorStatus),
                                    ),
                                    Text(
                                      isActive,
                                      style: TextStyle(
                                          color: HexColor(colorStatus),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  var isLoading = true;
                                  if (isActive == "Online") {
                                    setState(() {
                                      isLoading = false;
                                      updateStatus(token, "false");
                                    });
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                      updateStatus(token, "true");
                                    });
                                  }

                                  if (isLoading) {
                                    const CircularProgressIndicator();
                                  }
                                },
                              )));
                    },
                  )),
                ),
                Positioned(
                    bottom: 20.0,
                    left: 0,
                    right: 0,
                    child: FutureBuilder(
                      future: getUserData(),
                      builder: (context, snapshot) {
                        late String policeNumber;
                        late String balanceDriver;
                        late String typeVehicle;
                        if (snapshot.hasError) {
                          return Card(
                              elevation: 6,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              color: Colors.white,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                child: const Text(
                                  "Error",
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold),
                                ),
                              ));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Wrap(
                            children: [
                              Card(
                                  elevation: 6,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(25))),
                                  color: Colors.white,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    child: const CircularProgressIndicator(),
                                  ))
                            ],
                          );
                        }
                        if (snapshot.hasData) {
                          policeNumber = snapshot.data!.police_number;
                          typeVehicle = snapshot.data!.type_vehicle;
                          balanceDriver = snapshot.data!.balance_rider;

                          return StreamBuilder(
                              stream: collection
                                  .collection("orders")
                                  .where("isOrder", isEqualTo: "onProcessing")
                                  .where("driver_police_number",
                                      isEqualTo: policeNumber)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                List<Widget> cards = [];

                                if (snapshot.hasError) {
                                  return Card(
                                      elevation: 6,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      color: Colors.white,
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        child: const Text(
                                          "Error",
                                          style: TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ));
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Wrap(
                                    children: [
                                      Card(
                                          elevation: 6,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25))),
                                          color: Colors.white,
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            child:
                                                const CircularProgressIndicator(),
                                          ))
                                    ],
                                  );
                                }

                                late String typeOrder;
                                late String userName;
                                late String methodPayment;
                                late String distanceOrder;
                                late int priceOrder;

                                if (snapshot.hasData) {
                                  var order = snapshot.data!.docs;
                                  if (snapshot.data!.docs.isNotEmpty) {
                                    String statusDriver;
                                    String buttonText;
                                    String idOrder;
                                    isVisible = true;
                                    String typeOrderData;

                                    typeOrderData = order[0]['type_order'];
                                    userName = order[0]['user_name'];
                                    methodPayment = order[0]['method_payment'];
                                    priceOrder = order[0]['price_order'];
                                    distanceOrder = order[0]['distance_order'];
                                    statusDriver = order[0]['status_driver'];
                                    idOrder = order[0]['id_order'];

                                    if (typeOrderData == "kin_ride") {
                                      typeOrder = "Kin Ride";
                                    } else if (typeOrderData == "kin_food") {
                                      typeOrder = "Kin Food";
                                    } else if (typeOrderData == "kin_car") {
                                      typeOrder = "Kin Car";
                                    } else {
                                      typeOrder = "Kin Send";
                                    }
                                    if (statusDriver == "ongoing") {
                                      buttonText = "SUDAH SAMPAI";
                                    } else {
                                      buttonText = "SELESAI";
                                    }

                                    return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Card(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          elevation: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    color: HexColor("#d9d9d9"),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15))),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "#$typeOrder",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                decoration: BoxDecoration(
                                                                    color: HexColor(
                                                                        "#ef9904"),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(
                                                                                50))),
                                                                child:
                                                                    GestureDetector(
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .remove_red_eye_rounded,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  onTap: () {},
                                                                ))
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 7, bottom: 7),
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(userName,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                                methodPayment)),
                                                        Expanded(
                                                            flex: 1,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                    "${currencyFormat.convertToIdr(priceOrder)} ($distanceOrder)",
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))
                                                              ],
                                                            ))
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  5, 10, 5, 5),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(7),
                                                          decoration: BoxDecoration(
                                                              color: HexColor(
                                                                  "#ef9904"),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          50))),
                                                          child: const Icon(
                                                            Icons
                                                                .message_rounded,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            showModalBottomSheet(
                                                              shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                                                              ),
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                    decoration: const BoxDecoration(
                                                                        borderRadius: BorderRadius.only(
                                                                            topRight:
                                                                                Radius.circular(15),
                                                                            topLeft: Radius.circular(15))),
                                                                    child:
                                                                        const Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          "data",
                                                                        ),
                                                                        Text(
                                                                          "data",
                                                                        ),
                                                                        Text(
                                                                          "data",
                                                                        )
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(7),
                                                            decoration: BoxDecoration(
                                                                color: HexColor(
                                                                    "#ef9904"),
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            50))),
                                                            child: const Icon(
                                                              Icons.map,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            5),
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          HexColor(
                                                                              "#c70808")),
                                                                  onPressed:
                                                                      () {},
                                                                  child:
                                                                      const Text(
                                                                    "BATALKAN",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              )),
                                                          Expanded(
                                                              flex: 1,
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5),
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (statusDriver ==
                                                                        "ongoing") {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'orders')
                                                                          .doc(
                                                                              idOrder)
                                                                          .update(
                                                                        {
                                                                          'status_driver':
                                                                              'arrived',
                                                                        },
                                                                      );
                                                                    } else {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'orders')
                                                                          .doc(
                                                                              idOrder)
                                                                          .update(
                                                                        {
                                                                          'isOrder':
                                                                              'Finished',
                                                                        },
                                                                      );

                                                                      if (typeOrderData !=
                                                                          "kin_food") {
                                                                        updateBalance(
                                                                            widget
                                                                                .accesstoken,
                                                                            int.parse(balanceDriver) -
                                                                                500);
                                                                      } else {
                                                                        updateBalance(
                                                                            widget
                                                                                .accesstoken,
                                                                            int.parse(balanceDriver) -
                                                                                1000);
                                                                      }
                                                                    }
                                                                  },
                                                                  child: Text(
                                                                    buttonText,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ));
                                  } else {
                                    if (typeVehicle == "car") {
                                      return StreamBuilder(
                                        stream: collection
                                            .collection("orders")
                                            .where("isOrder",
                                                isEqualTo: "onWaiting")
                                            .where("type_order",
                                                isEqualTo: "kin_car")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Card(
                                                elevation: 6,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                color: Colors.white,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  child: const Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ));
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Wrap(
                                              children: [
                                                Card(
                                                    elevation: 6,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    25))),
                                                    color: Colors.white,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7),
                                                      child:
                                                          const CircularProgressIndicator(),
                                                    ))
                                              ],
                                            );
                                          }

                                          if (snapshot.hasData) {
                                            var order = snapshot.data!.docs;
                                            for (int i = 0;
                                                i < order.length;
                                                i++) {
                                              cards.add(Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: orderCard(
                                                    context,
                                                    order,
                                                    i,
                                                    policeNumber,
                                                    balanceDriver),
                                              ));
                                            }
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, bottom: 5),
                                                child: Card(
                                                    elevation: 6,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    color: HexColor("#ef9904"),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          10, 7, 10, 7),
                                                      child: Text(
                                                        "Total Pesanan ${snapshot.data!.size}",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: cards,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else {
                                      return StreamBuilder(
                                        stream: collection
                                            .collection("orders")
                                            .where("isOrder",
                                                isEqualTo: "onWaiting")
                                            .where("type_order",
                                                isNotEqualTo: "kin_car")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Card(
                                                elevation: 6,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    15))),
                                                color: Colors.white,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(7),
                                                  child: const Text(
                                                    "Error",
                                                    style: TextStyle(
                                                        color: Colors.amber,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ));
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Wrap(
                                              children: [
                                                Card(
                                                    elevation: 6,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    25))),
                                                    color: Colors.white,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7),
                                                      child:
                                                          const CircularProgressIndicator(),
                                                    ))
                                              ],
                                            );
                                          }

                                          if (snapshot.hasData) {
                                            var order = snapshot.data!.docs;
                                            for (int i = 0;
                                                i < order.length;
                                                i++) {
                                              cards.add(Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                padding: const EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: orderCard(
                                                    context,
                                                    order,
                                                    i,
                                                    policeNumber,
                                                    balanceDriver),
                                              ));
                                            }
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10, bottom: 5),
                                                child: Card(
                                                    elevation: 6,
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10))),
                                                    color: HexColor("#ef9904"),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          10, 7, 10, 7),
                                                      child: Text(
                                                        "Total Pesanan ${snapshot.data!.size}",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    )),
                                              ),
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: cards,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                }

                                return Container();
                              });
                        }
                        return Container();
                      },
                    ))
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Widget markerPosition(FirebaseFirestore collection, policeNumber) {
  return StreamBuilder(
      stream: collection
          .collection("orders")
          .where("isOrder", isEqualTo: "onProcessing")
          .where("driver_police_number", isEqualTo: policeNumber)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var order = snapshot.data!.docs;
          if (order.isNotEmpty) {
            var destinationLatlng = order[0]['destination_latlng'];

            var pickupLatlng = order[0]['pickup_latlng'];

            return MarkerLayer(
              markers: [
                Marker(
                    point:
                        LatLng(pickupLatlng.latitude, pickupLatlng.longitude),
                    builder: (context) => Icon(
                          Icons.person_pin_circle_sharp,
                          size: 30,
                          color: HexColor("#ef9904"),
                        )),
                Marker(
                    point: LatLng(destinationLatlng.latitude,
                        destinationLatlng.longitude),
                    builder: (context) => Icon(
                          Icons.pin_drop,
                          size: 30,
                          color: HexColor("#c70808"),
                        )),
              ],
            );
          }
        }

        return Container();
      });
}

Widget orderCard(context, order, i, driverPoliceNumber, balanceDriver) {
  var typeOrderData = order[i]['type_order'];
  String typeOrder;
  if (typeOrderData == "kin_ride") {
    typeOrder = "Kin Ride";
  } else if (typeOrderData == "kin_food") {
    typeOrder = "Kin Food";
  } else if (typeOrderData == "kin_car") {
    typeOrder = "Kin Car";
  } else {
    typeOrder = "Kin Send";
  }

  return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: HexColor("#ef9904"),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7), topLeft: Radius.circular(7))),
            height: 120,
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                      child: Text(
                        typeOrder,
                        style: TextStyle(
                          color: HexColor("#ef9904"),
                        ),
                      ),
                    )),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          "http://62.72.3.200/assets/drivers/Vria%20Mitra%20-%203929.jpg",
                          height: 40,
                          width: 40,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order[i]['user_name'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              order[i]['price_order'].toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Penjemputan",
                  style: TextStyle(
                      color: HexColor("#6b6969"), fontWeight: FontWeight.bold),
                ),
                Text(
                  order[i]['username_pickup'],
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tujuan",
                        style: TextStyle(
                            color: HexColor("#6b6969"),
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order[i]['username_destination'],
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (int.parse(balanceDriver) < 1000) {
                            } else {
                              FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(order[i]['id_order'])
                                  .update(
                                {
                                  'isOrder': 'onProcessing',
                                  'driver_police_number': driverPoliceNumber
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor("#ef9904"),
                          ),
                          child: const Text(
                            "AMBIL",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ))
              ],
            ),
          )
        ],
      ));
}
