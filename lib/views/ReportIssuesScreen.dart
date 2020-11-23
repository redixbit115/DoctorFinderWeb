
import 'dart:convert';

import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter_doctor_web_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportIssuesScreen extends StatefulWidget {
  @override
  _ReportIssuesScreenState createState() => _ReportIssuesScreenState();
}

class _ReportIssuesScreenState extends State<ReportIssuesScreen> {

  List<String> issuesList = [
    "1","2","3","4","5","6","7","8","9","10"
  ];
  List<bool> selectedIssues = [];
  String description = "";
  bool isDescriptionError = false;
  bool isIssuePublibshed = false;
  String userId;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        userId = pref.getString("userId");
      });
    });
    for(int i=0; i<issuesList.length; i++){
      selectedIssues.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
              checks(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    fillColor: Theme.of(context).backgroundColor,
                    filled: true,
                    hintText: "Describe your issue",
                    errorText: isDescriptionError ? "Description is necessary" : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    )
                  ),
                  onChanged: (val){
                    setState(() {
                      description = val;
                      isDescriptionError = false;
                    });
                  },
                ),
              ),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  checks(){
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemCount: issuesList.length,
      itemBuilder: (context, index){
        return  Container(
          margin: EdgeInsets.fromLTRB(15, 5, 15, 5),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: Checkbox(
              onChanged: (val){
                print(val);
              },
              value: selectedIssues[index],
            ),
            title: Text(issuesList[index]),
            onTap: (){
              setState(() {
                selectedIssues[index] = !selectedIssues[index];
              });
            },
          )
        );
      },
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

                },
                child: Image.asset("assets/moreScreenImages/back.png",
                  height: 25,
                  width: 22,
                ),
              ),
              SizedBox(width: 10,),
              Text(
                  REPORT_ISSUES,
                  style: Theme.of(context).textTheme.headline5.apply(color: Theme.of(context).backgroundColor)
              )
            ],
          ),
        ),
      ],
    );
  }

  reportissue() async{

    String title = "";
    for(int i=0; i<issuesList.length; i++){
      if(selectedIssues[i]){
        title = issuesList[i] +", ";
      }
    }

    if(description.isEmpty){
      setState(() {
        isDescriptionError = true;
      });
    }else if(userId == null){
      //Navigator.pop(context);
      messageDialog(ERROR, "You are not logged in");
    }else if(title.isEmpty){
      //Navigator.pop(context);
      messageDialog(ERROR, "No issue selected");
    }else{
      dialog();
      final response = await post("$SERVER_ADDRESS/api/Reportspam",
          body: {
            "user_id": userId,
            "title": title,
            "description": description,
          }
      );
      if(response.statusCode == 200){
        final jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        if(jsonResponse['success'] == "1"){
          print("Success");
          Navigator.pop(context);
          setState(() {
            isIssuePublibshed = true;
          });
          messageDialog(SUCCESSFUL, jsonResponse['register']);
        }else{
          print("failure");
        }
      }
    }
  }

  Widget button(){
    return Container(
      height: 50,
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      //width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: (){
          reportissue();
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
                REPORT,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 18
                ),
              ),
            )
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
            title: Text(PROCESSING,
              style: GoogleFonts.poppins(),
            ),
            content: Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Text(PLEASE_WAIT_WHILE_REPORTING_ISSUE,
                      style: GoogleFonts.poppins(
                          fontSize: 12
                      ),
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
        barrierDismissible: false,
        builder: (context){
          return AlertDialog(
            title: Text(s1,style: GoogleFonts.comfortaa(
              fontWeight: FontWeight.bold,
            ),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s2,style: GoogleFonts.poppins(
                  fontSize: 14,
                ),)
              ],
            ),
            actions: [
              FlatButton(
                onPressed: (){
                  if(isIssuePublibshed) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }else{
                    Navigator.pop(context);
                  }
                },
                color: Colors.cyanAccent,
                child: Text(OK,style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),),
              ),
            ],
          );
        }
    );
  }


}

