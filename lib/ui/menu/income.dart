import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';

import '../../helpers/HexColor.dart';
import '../../internet_services/ApiClient.dart';
import '../../models/DriverModel.dart';
import 'package:untitled/helpers/CurrencyFormat.dart';

class Income extends StatefulWidget {
  const Income({super.key});

  @override
  State<Income> createState() => _IncomeState();
}

class _IncomeState extends State<Income> {
  final ApiClient _apiClient = ApiClient();

  var collection = FirebaseFirestore.instance;

  Future<DriverModel> getUserData() async {
    dynamic token = await SessionManager().get("token");

    dynamic userRes = await _apiClient.getUserProfileData(token.toString());

    return DriverModel.fromJson(userRes as Map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
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
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          late String policeNumber;
          if (snapshot.hasData) {
            policeNumber = snapshot.data!.police_number;
          }
          return StreamBuilder(
              stream: collection
                  .collection("orders")
                  .where("driver_police_number", isEqualTo: policeNumber)
              .orderBy("date_order",descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Card(
                      elevation: 6,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                var orders = snapshot.data!.docs;


                var now = DateTime.now();
                var firstDayMonth = DateTime(now.year, now.month, 1);
                // var sortExpData = List<Map<String, dynamic>>.from(orders);
                // sortExpData.removeWhere((e) => (e['date_order'] as DateTime).isBefore(firstDayMonth));
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: ListView(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 1,
                                child: totalCard(
                                    true,
                                    "Total Pendapatan Hari Ini:",
                                    policeNumber)),
                            Expanded(
                                flex: 1,
                                child: totalCard(
                                    false, "Total Pendapatan:", policeNumber))
                          ],
                        ),
                        ListView.builder(
                            itemCount: orders.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return finishedOrderCard(orders, index);
                            })
                      ],
                    ),
                  );
                }

                return Container();
              });
        },
      ),
    );
  }
}

Widget totalCard(today, String istoday, String policeNumber) {
  var collection = FirebaseFirestore.instance;
  var dateFormat = DateFormat("dd/MM/yyyy").format(DateTime.now());
  String dateOrder = dateFormat;
  double income = 0.0;
  if (today == true) {

    return StreamBuilder(
        stream: collection
            .collection("orders")
            .where("isOrder", isEqualTo: "Finished")
            .where("date_order", isEqualTo: dateOrder)
            .where("driver_police_number", isEqualTo: policeNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Card(
                elevation: 6,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var orders = snapshot.data!.docs;

          if (orders.isNotEmpty) {
            for (int i = 0; i < orders.length; i++) {
              var totalIncome = snapshot.data!.docs[i]['price_order'];

              income += totalIncome!;
            }
          }

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    istoday,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(currencyFormat.convertToIdr(income),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: HexColor("#ef9904")))
                ],
              ),
            ),
          );
        });




  } else {
     return StreamBuilder(
        stream: collection
            .collection("orders")
            .where("isOrder", isEqualTo: "Finished")
            .where("driver_police_number", isEqualTo: policeNumber)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Card(
                elevation: 6,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var orders = snapshot.data!.docs;

          if (orders.isNotEmpty) {
            for (int i = 0; i < orders.length; i++) {
              var totalIncome = snapshot.data!.docs[i]['price_order'];

              income += totalIncome!;
            }
          }

            return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    istoday,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(currencyFormat.convertToIdr(income),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: HexColor("#ef9904")))
                ],
              ),
            ),
          );
        });
  }


}

Widget finishedOrderCard(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders, int index) {
  String statusOrder = orders[index]['isOrder'];
  String typeOrder = orders[index]['type_order'];
  String type;
  String dateOrder = orders[index]['date_order'];
  double priceOrder = orders[index]['price_order'];
  String status;
  IconData icons;

  if (statusOrder == "Finished") {
    status = "Selesai";
  } else if (statusOrder == "Decline") {
    status = "Dibatalkan";
  } else {
    status = "Berjalan";
  }

  if (typeOrder == "kin_ride") {
    type = "Kin Ride";
    icons = Icons.motorcycle_outlined;
  } else if (typeOrder == "kin_car") {
    type = "Kin Car";
    icons = Icons.directions_car_outlined;
  } else if (typeOrder == "kin_food") {
    type = "Kin Food";
    icons = Icons.restaurant_menu_outlined;
  } else {
    type = "Kin Send";
    icons = Icons.gif_box;
  }

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    margin: const EdgeInsets.all(8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                decoration: BoxDecoration(
                    color: HexColor("#ef9904"),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  status,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          "Lihat Detail",
                          style: TextStyle(color: HexColor("#ef9904")),
                        ),
                      )
                    ],
                  ))
            ],
          ),
          Container(
              margin: const EdgeInsets.only(top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                            color: HexColor("#ef9904"),
                            borderRadius: BorderRadius.circular(50)),
                        child: Icon(
                          icons,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            dateOrder,
                            style: const TextStyle(fontSize: 13),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            currencyFormat.convertToIdr(priceOrder),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ))
                ],
              ))
        ],
      ),
    ),
  );
}
