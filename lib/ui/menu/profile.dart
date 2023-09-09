import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:untitled/internet_services/path.dart';
import 'package:untitled/ui/LoginPage.dart';

import '../../helpers/HexColor.dart';
import '../../internet_services/ApiClient.dart';
import '../../models/DriverModel.dart';
import 'package:untitled/helpers/CurrencyFormat.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ApiClient _apiClient = ApiClient();

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
          late double balanceDriver;
          late String nameDriver;
          late String emailDriver;
          late String phoneDriver;
          late String imageDriver;
          late String ratingDriver;
          if (snapshot.hasData) {
            balanceDriver = double.parse(snapshot.data!.balance_rider);
            nameDriver = snapshot.data!.username_rider;
            emailDriver = snapshot.data!.email_rider;
            phoneDriver = snapshot.data!.phone_rider;
            imageDriver = snapshot.data!.image_rider;
            ratingDriver = snapshot.data!.rating_driver;
          }

          return SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: 200,
                    child: Stack(
                      children: [
                        Container(
                          height: 130,
                          color: HexColor("#ef9904"),
                        ),
                        Positioned(
                            bottom: 5,
                            left: 5,
                            right: 5,
                            child: SizedBox(
                                height: 130,
                                child: Stack(
                                  children: [
                                    Center(
                                        child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2, color: Colors.white),
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          "http://$baseUrl/assets/drivers/$imageDriver",
                                          height: 100,
                                          width: 100,
                                        ),
                                      ),
                                    )),
                                    Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Card(
                                            elevation: 4,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 3, 10, 5),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          color: HexColor(
                                                              "#ef9904"),
                                                        ),
                                                        Text(
                                                          ratingDriver,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )
                                                      ],
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ))
                                  ],
                                )))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Informasi Umum",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Card(
                            elevation: 5,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  const Icon(Icons.alternate_email),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Text(currencyFormat
                                        .convertToIdr(balanceDriver)),
                                  )
                                ],
                              ),
                            )),
                        Card(
                          elevation: 5,
                          margin: const EdgeInsets.only(top: 15),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alternate_email),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Text(nameDriver),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email_outlined),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Text(emailDriver),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    const Icon(Icons.phone_android_outlined),
                                    Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      child: Text(phoneDriver),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          SessionManager().remove("token");
                                          if (!context.mounted) return;
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return const LoginPage();
                                          }));
                                        },
                                        child: (const Text(
                                          "UBAH",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: () {
                                SessionManager().remove("token");
                                if (!context.mounted) return;
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const LoginPage();
                                }));
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(10),
                              ),
                              child: (const Text("KELUAR",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)))),
                        )
                      ],
                    ),
                  )
                ]),
          );
        },
      ),
    );
  }
}
