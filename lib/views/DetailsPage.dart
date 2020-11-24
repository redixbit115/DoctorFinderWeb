
import 'dart:convert';

import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter_doctor_web_app/main.dart';
import 'package:flutter_doctor_web_app/modals/DoctorDetailsClass.dart';
import 'package:flutter_doctor_web_app/views/MakeAppointment.dart';
import 'package:flutter_doctor_web_app/views/MapWidget.dart';
import 'package:flutter_doctor_web_app/views/ReviewsScreen.dart';
import 'package:flutter_doctor_web_app/views/loginAsUser.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {

  String id;

  DetailsPage(this.id);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
 
  DoctorDetailsClass doctorDetailsClass;
  bool isLoading = true;
  bool isLoggedIn;
 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDoctorDetails();
    print(widget.id);
    SharedPreferences.getInstance().then((pref){
      setState(() {
        isLoggedIn = pref.getBool("isLoggedIn") ?? false;
      });
    });
  }
  
  fetchDoctorDetails() async{
    setState(() {
      isLoading = true;
    });
    final response = await get("$SERVER_ADDRESS/api/viewdoctor?doctor_id=${widget.id}");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      doctorDetailsClass = DoctorDetailsClass.fromJson(jsonResponse);
      print(doctorDetailsClass.data.avgratting);
      print(widget.id);
      setState(() {
        isLoading = false;
        //doctorDetailsClass.data.avgratting = '3';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Stack(
          children: [
            !isLoading
                ? SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
                  child: Column(
                    children: [
                      header(),
                      appointmentListWidget(),
                      doctorDetails(),
                      SizedBox(height: 80,),
                    ],
                  ),
                ),
              ),
            )
                : Center(
              child: CircularProgressIndicator(),
            ),
            header(),
            !isLoading
                ? button()
                : Center(
              child: CircularProgressIndicator(),
            ),

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
                DOCTOR_DETAILS,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 22
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget appointmentListWidget() {
    return Container(
      //height: 110,
      margin: EdgeInsets.fromLTRB(10,10,10,10),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CachedNetworkImage(
              imageUrl: Uri.encodeFull(doctorDetailsClass.data.image),
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).primaryColorLight,
                child: Center(
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                ),

              ),
              errorWidget: (context,url,err) => Container(
                color: Theme.of(context).primaryColorLight,
                child: Center(
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 40, width: 40,),
                ),
              ),
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorDetailsClass.data.name,
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                      Text(doctorDetailsClass.data.departmentName,
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Image.asset(
                                doctorDetailsClass.data.avgratting == null
                                    ? "assets/detailScreenImages/star_no_fill.png"
                                    : doctorDetailsClass.data.avgratting >= 1
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              )
                          ),
                          Expanded(
                              child: Image.asset(
                                doctorDetailsClass.data.avgratting == null
                                    ? "assets/detailScreenImages/star_no_fill.png"
                                    : doctorDetailsClass.data.avgratting >= 2
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              )
                          ),
                          Expanded(
                              child: Image.asset(
                                doctorDetailsClass.data.avgratting == null
                                    ? "assets/detailScreenImages/star_no_fill.png"
                                    : doctorDetailsClass.data.avgratting >= 3
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              )
                          ),
                          Expanded(
                              child: Image.asset(
                                doctorDetailsClass.data.avgratting == null
                                    ? "assets/detailScreenImages/star_no_fill.png"
                                    : doctorDetailsClass.data.avgratting >= 4
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              )
                          ),
                          Expanded(
                              child: Image.asset(
                                doctorDetailsClass.data.avgratting == null
                                    ? "assets/detailScreenImages/star_no_fill.png"
                                    : doctorDetailsClass.data.avgratting >= 5
                                    ? "assets/detailScreenImages/star_fill.png"
                                    : "assets/detailScreenImages/star_no_fill.png",
                                height: 15,
                                width: 15,
                              )
                          ),


                          Text(" (${doctorDetailsClass.data.totalReview} $REVIEWS)",
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 8,
                                fontWeight: FontWeight.w400
                            ),
                          ),
                          SizedBox(
                            width: 10,)
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(widget.id)));
                            },
                            child: Text(SEE_ALL_REVIEW,
                              style: GoogleFonts.poppins(
                                  color: Colors.cyanAccent.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500
                              ),
                            ),)
                        ],
                      ),
                    ),
                  ],
                ),
                //SizedBox(height: 5,),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget doctorDetails(){
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 10, 0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PHONE_NUMBER,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 14
                    ),
                  ),
                  SizedBox(height: 8,),
                  Text(
                    doctorDetailsClass.data.phoneno,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                        fontSize: 10
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: (){
                  launch("tel://${doctorDetailsClass.data.phoneno}");
                },
                child: Image.asset(
                  "assets/detailScreenImages/phone_button.png",
                  height: 50,
                  width: 50,
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ABOUT_US,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              SizedBox(height: 8,),
              Text(
                doctorDetailsClass.data.aboutus,
                 style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    fontSize: 10
                ),
              ),
            ],
          ),
          SizedBox(height: 15,),
          Container(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/detailScreenImages/location_pin.png",
                            height: 15,
                            width: 15,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            ADDRESS,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          doctorDetailsClass.data.address,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                              fontSize: 10
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Image.asset(
                            "assets/detailScreenImages/time.png",
                            height: 15,
                            width: 15,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            WORKING_TIME,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                                fontSize: 15
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: Text(
                          doctorDetailsClass.data.workingTime,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade500,
                              fontSize: 10
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 50,),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    child: Container(
                      height: 180,
                      //width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/detailScreenImages/map_icon.png"
                            ),
                            InkWell(
                              onTap: (){
                                openMap(double.parse(doctorDetailsClass.data.lat), double.parse(doctorDetailsClass.data.lon));
                                //_launchMaps();
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) => MapWidget(
                                //         double.parse(doctorDetailsClass.data.lat),
                                //         double.parse(doctorDetailsClass.data.lon)),)
                                // );
                              },
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ),
              ],
            ),
          ),
          SizedBox(height: 15,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SERVICES,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15
                ),
              ),
              SizedBox(height: 8,),
              Text(
                doctorDetailsClass.data.services,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                    fontSize: 10
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget button(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 50,
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
        //width: MediaQuery.of(context).size.width,
        child: InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                isLoggedIn
                    ? MakeAppointment(widget.id, doctorDetailsClass.data.name)
                    : LoginAsUser())
            );
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
                  isLoggedIn ? MAKE_AN_APPOINTMENT : LOGIN_TO_BOOK_APPOINTMENT,
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
      ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  _launchMaps() async {
    String googleUrl =
        'comgooglemaps://?center=${doctorDetailsClass.data.lat},${doctorDetailsClass.data.lon}';
    String appleUrl =
        'https://maps.apple.com/?sll=${doctorDetailsClass.data.lat},${doctorDetailsClass.data.lon}';
    if (await canLaunch("comgooglemaps://")) {
      print('launching com googleUrl');
      await launch(googleUrl);
    } else if (await canLaunch(appleUrl)) {
      print('launching apple url');
      await launch(appleUrl);
    } else {
      throw 'Could not launch url';
    }
  }

}
