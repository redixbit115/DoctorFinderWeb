import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../firebase_messaging.dart';
import '../main.dart';
import 'Doctor/DoctorTabScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isTokenAvailable = false;
  String token;
  String result = "Connecting";

  getToken() async{

    print(kIsWeb);

    if(!kIsWeb){
      await FirebaseMessaging().getToken().then((value){
        //Toast.show(value, context, duration: 2);
        print(value);
        setState(() {
          token = value;
        });

        SharedPreferences.getInstance().then((pref){
          if(pref.getBool("isTokenExist") ?? false){
            Timer(Duration(seconds: 2), (){

              if(pref.getBool("isLoggedInAsDoctor") ?? false) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => DoctorTabsScreen())
                );
              }
              else if(pref.getBool("isLoggedIn") ?? false) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => TabsScreen())
                );
              }
              else{
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => TabsScreen())
                );
              }

            });
          }
          else{
            storeToken();
          }
        });

      });

    }
    else{
      final _messaging = FBMessaging.instance;
      _messaging.init().then((value) {
        _messaging.requestPermission().then((_) async {
          final _token = await _messaging.getToken();
          print('Token: $_token');
          setState(() {
            token = _token;
          });
          SharedPreferences.getInstance().then((pref){
            if(pref.getBool("isTokenExist") ?? false){
              Timer(Duration(seconds: 2), (){

                if(pref.getBool("isLoggedInAsDoctor") ?? false) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => DoctorTabsScreen())
                  );
                }
                else if(pref.getBool("isLoggedIn") ?? false) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => TabsScreen())
                  );
                }
                else{
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => TabsScreen())
                  );
                }

              });
            }
            else{
              storeToken();
            }
          });
        });
      });
      _messaging.stream.listen(
            (event) {
          print('New Message: ${event}');
        },
      );
    }

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
  }

  storeToken() async{
    print("Running store token");

    var response = await post(
        Uri.encodeFull("$SERVER_ADDRESS/api/savetoken?token=$token&type=1"),
      headers: {"Accept" : "application/json"}
    ).catchError((e){
      print(e.toString());
      setState(() {
        result = e.toString();
      });
      //Toast.show(e.toString(), context,duration: 10);
    });
    print(response);
    //Toast.show(response.toString(), context,duration: 10);
    setState(() {
      result = response.toString();
    });
    if(response.statusCode == 200){
      print("Status Code");
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'] == "1"){
        Timer(Duration(seconds: 2), (){
          SharedPreferences.getInstance().then((pref){
            pref.setBool("isTokenExist", true);
            print("token stored");
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TabsScreen())
            );
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
              "assets/splash_bg.png",
            fit: BoxFit.fill,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.all(85),
                child: Center(
                  child: Image.asset(
                      "assets/splash_icon.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
