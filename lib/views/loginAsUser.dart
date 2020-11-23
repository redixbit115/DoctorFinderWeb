import 'dart:convert';

import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter_doctor_web_app/main.dart';
import 'package:flutter_doctor_web_app/views/RegisterAsUser.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';

class LoginAsUser extends StatefulWidget {
  @override
  _LoginAsUserState createState() => _LoginAsUserState();
}

class _LoginAsUserState extends State<LoginAsUser> {

  String phoneNumber = "";
  String pass = "";
  bool isPhoneNumberError = false;
  bool isPasswordError = false;
  String passErrorText = "";
  String token = "xyz";

  getToken() async{
    // FirebaseMessaging().getToken().then((value){
    //   //Toast.show(value, context, duration: 2);
    //   print(value);
    //   setState(() {
    //     token = value;
    //   });
    // });
  }

  loginInto() async{
    if(EmailValidator.validate(phoneNumber) == false){
      setState(() {
        isPhoneNumberError = true;
      });
    }else {
      dialog();
      //Toast.show("Logging in..", context, duration: 2);
      String url = "$SERVER_ADDRESS/api/login?email=$phoneNumber&password=$pass&token=abc";
      var response = await post(url,
          headers: {
            'Accept': 'application/json',
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Credentials": "true",
            "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
            "Access-Control-Allow-Methods": "POST, OPTIONS,GET"
          },
          body: {
        'email': phoneNumber,
        'password': pass,
        'token': "abc",
      });
      print(response.statusCode);
      print(response.body);
      var jsonResponse = await jsonDecode(response.body);
      if (jsonResponse['success'] == "0") {
        setState(() {
          Navigator.pop(context);
          isPasswordError = true;
          passErrorText = EITHER_EMAIL_OR_PASSWORD_IS_INCORRECT;
        });
      }else{
        await SharedPreferences.getInstance().then((pref){
          pref.setBool("isLoggedIn", true);
          pref.setString("userId", jsonResponse['register']['user_id'].toString());
          pref.setString("name", jsonResponse['register']['name']);
          pref.setString("phone", jsonResponse['register']['phone']);
          pref.setString("email", jsonResponse['register']['email']);
          pref.setString("password", pass);
          pref.setString("token", token.toString());
          pref.setString("profile_image", jsonResponse['register']['profile_pic']);
        });
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => TabsScreen())
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            bottom(),
            SingleChildScrollView(
              child: Column(
                children: [
                  header(),
                  loginForm()
                ],
              ),
            ),
            header(),
          ],
        ),
      ),
    );
  }

  Widget header(){
    return Stack(
      children: [
        Image.asset("assets/moreScreenImages/header_bg.png",
          height: 60,
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
        Container(
          height: 60,
          child: Row(
            children: [
              SizedBox(width: 15,),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                LOGIN,
                style: Theme.of(context).textTheme.headline5.apply(
                  color: Theme.of(context).backgroundColor,
                  fontWeightDelta: 2
                )
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget bottom(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DO_NOT_HAVE_AN_ACCOUNT,
              style: Theme.of(context).textTheme.bodyText2
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegisterAsUser())
                );
              },
              child: Text(" $REGISTER_NOW",
                style: Theme.of(context).textTheme.bodyText1.apply(
                  color: Colors.amber.shade700,
                )
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }

  Widget loginForm(){
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
      ),
      height: MediaQuery.of(context).size.height - 150,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Image.asset(
              "assets/loginScreenImages/login_icon.png",
              height: 180,
              width: 180,
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: ENTER_YOUR_EMAIL,
                  labelStyle: Theme.of(context).textTheme.bodyText2.apply(
                    fontSizeDelta: 2,
                    color: Theme.of(context).primaryColorDark
                  ),
                  errorText: isPhoneNumberError ? ENTER_VALID_EMAIL_ADDRESS : null,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColorDark,)
                  )
              ),
              style:  Theme.of(context).textTheme.bodyText2.apply(
                fontWeightDelta: 3,
                fontSizeDelta: 2,
              ),
              onChanged: (val){
                setState(() {
                  phoneNumber =val;
                  isPhoneNumberError = false;
                  isPasswordError = false;
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              obscureText: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: PASSWORD,
                labelStyle: Theme.of(context).textTheme.bodyText2.apply(
                    fontSizeDelta: 2,
                    color: Theme.of(context).primaryColorDark
                ),
                errorText: isPasswordError ? passErrorText : null,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColorDark,)
                ),
              ),
              style: Theme.of(context).textTheme.bodyText2.apply(
                fontWeightDelta: 3,
                fontSizeDelta: 2,
              ),
              onChanged: (val){
                setState(() {
                  pass = val;
                  isPasswordError = false;
                });
              },
            ),
            SizedBox(height: 10),
            SizedBox(height: 20),
            Container(
              height: 50,
              //width: MediaQuery.of(context).size.width,
              child: InkWell(
                onTap: (){
                  loginInto();
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset("assets/moreScreenImages/header_bg.png",
                        height: 50,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ),
                    Center(
                      child: Text(
                        LOGIN,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          fontSizeDelta: 5,
                          color: Theme.of(context).backgroundColor
                        )
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  dialog(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(LOGGING_IN,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(PLEASE_WAIT_LOGGING_IN,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  messageDialog(String s1, String s2){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: Theme.of(context).textTheme.bodyText1),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: Theme.of(context).textTheme.bodyText1,)
              ],
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                color: Theme.of(context).primaryColor,
                child: Text(OK,style: Theme.of(context).textTheme.bodyText1)
              ),
            ],
          );
        }
    );
  }



}
