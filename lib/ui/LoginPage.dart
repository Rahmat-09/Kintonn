import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:untitled/internet_services/ApiClient.dart';

import '../helpers/HexColor.dart';
import 'LayoutNavigationBar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  bool _showPassword = true;

  Future<void> loginDriver() async {
    if (_formKey.currentState!.validate()) {
      //show snackbar to indicate loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Processing Data'),
        backgroundColor: Colors.green.shade300,
      ));

      //get response from ApiClient
      dynamic res = await _apiClient.login(
        emailController.text,
        passwordController.text,
      );

      var decodedResponse = jsonDecode(utf8.decode(res.bodyBytes)) as Map;
      var message = decodedResponse['message'];
      var status = decodedResponse['status'];
      var isStatus = decodedResponse['is_status'];

      // ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (status == 1) {
        String token = decodedResponse['token'];

        if (isStatus == "accept") {
          if (!context.mounted) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            var sessionManager = SessionManager();
            sessionManager.set("token", token);
            sessionManager.set("isLoggedIn", true);

            return LayoutNavigationBar(accesstoken: token);
          }));
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text(
                "Akun anda masih dalam proses pengajuan silahakan hubungi admin..."),
            backgroundColor: Colors.green.shade300,
          ));
        }
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade300,
        ));
      }
    }
  }

  Future<void> checkLogin() async {
    dynamic isLoggedIn = SessionManager().get("isLoggedIn");
    dynamic token = SessionManager().get("token");
    if (isLoggedIn == true) {
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        var sessionManager = SessionManager();
        sessionManager.set("token", token);
        sessionManager.set("isLoggedIn", true);

        return LayoutNavigationBar(accesstoken: token);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#ef9904"),
      body: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot) => Stack(
          alignment: Alignment.bottomRight,
          fit: StackFit.loose,
          children: [
            const Positioned(
                top: 150,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Image(
                      width: 150,
                      height: 150,
                      image: AssetImage('icon/driver.png'),
                    ),
                  ),
                )),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Card(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Silahkan Masuk",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  child: TextFormField(
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Masukkan Email"),
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: TextFormField(
                                    obscureText: _showPassword,
                                    controller: passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                    decoration: InputDecoration(
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() =>
                                                _showPassword = !_showPassword);
                                          },
                                          child: Icon(
                                            _showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        border: const OutlineInputBorder(),
                                        isDense: true,
                                        labelText: "Masukkan Password"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                    onPressed: loginDriver,
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(13),
                                        backgroundColor: HexColor("#ef9904")),
                                    child: const Text(
                                      "MASUK",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))),
                ))
          ],
        ),
      ),
    );
  }
}
