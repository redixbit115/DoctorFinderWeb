import 'dart:convert';

import 'package:flutter_doctor_web_app/main.dart';
import 'package:flutter_doctor_web_app/modals/NearbyDoctorClass.dart';
import 'package:flutter_doctor_web_app/modals/SearchDoctorClass.dart';
import 'package:flutter_doctor_web_app/modals/UserAppointmentsClass.dart';
import 'package:flutter_doctor_web_app/views/AllAppointments.dart';
import 'package:flutter_doctor_web_app/views/AllNearby.dart';
import 'package:flutter_doctor_web_app/views/DetailsPage.dart';
import 'package:flutter_doctor_web_app/views/SearchedScreen.dart';
import 'package:flutter_doctor_web_app/views/SpecialityScreen.dart';
import 'package:flutter_doctor_web_app/views/UserAppointmentDetails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../en.dart';
import '../notificationHelper.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  TextEditingController _textController = TextEditingController();
  SearchDoctorClass searchDoctorClass;
  bool isLoading = false;
  bool isSearching = false;
  bool isErrorInNearby = false;
  bool isNearbyLoading = false;
  NearbyDoctorsClass nearbyDoctorClass;
  String userName = " ";
  TextField textField;
  bool isAppointmentExist = false;
  UserAppointmentsClass userAppointmentsClass;
  Future loadAppointments;
  String userId = "";
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();
  String nextUrl = "";
  String searchKeyword = "";

  var _newData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocationStart();
    getMessages();
    SharedPreferences.getInstance().then((pref){
      setState(() {
        userName = pref.getString("name") ?? USER;
        userId = pref.getString("userId") ?? "";
        loadAppointments = fetchUpcomingAppointments( );
      });
    });
    _scrollController.addListener(() {
      print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        //print("Loadmore");
        _loadMoreFunc();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Stack(
        children: [
          isSearching
              ? Center(
                child: Container(
            constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
            child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _newData.length,
                            itemBuilder: (context, index){
                                return ListTile(
                                  title: Text(
                                    _newData[index].name,
                                    style: GoogleFonts.poppins(
                                        color: Theme.of(context).primaryColorDark,
                                        fontSize: 14
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.search,
                                    size: 18,
                                  ),
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsPage(_newData[index].id.toString())));
                                  },
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 160,),
                upCommingAppointments(),
                nearByDoctors(),
              ],
            ),
          ),
          header(),
        ],
      ),
    );
  }


  void getMessages(){
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    NotificationHelper notificationHelper;
    _firebaseMessaging.configure(
      onMessage: (msg) async{
        print('On Message : $msg');
        setState(() {
          //message = msg["notification"]['title'];
          notificationHelper = NotificationHelper(msg["notification"]['title'], msg["notification"]['body'], null, "Food Explorer");
          notificationHelper.initialize();
        });
      },
      onResume: (msg) async{
        print('On Resume : $msg');
        setState(() {
          //message = msg["notification"]['title'];
        });
      },
      onLaunch: (msg) async{
        print('On Launch : $msg');
        setState(() {
          //message = msg["notification"]['title'];
        });
      },

    );

    print(_firebaseMessaging.toString());

  }

  //--------------widgets--------------------------

  Widget noAppointment(){
    return Container(
      height: 250,
      width: 500,
      margin: EdgeInsets.all(10),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/homeScreenImages/no_appo_img.png"
            ),
            Text(
                YOU_DONOT_HAVE_ANY_UPCOMING_APPOINTMENT,
              style: TextStyle(
                fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget header(){
    return Center(
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        child: Stack(
          children: [
            Image.asset(
              "assets/homeScreenImages/header_bg.png",
              height: 180,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  children: [
                    Row(
                      //crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text("$WELCOME, ",
                          style: Theme.of(context).textTheme.caption.apply(
                            color: Theme.of(context).backgroundColor,
                            fontSizeDelta: 4,
                          )
                        ),
                        Text(userName,
                          style: Theme.of(context).textTheme.headline5.apply(
                            color: Theme.of(context).backgroundColor,
                            fontWeightDelta: 2
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            //margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Theme.of(context).backgroundColor,
                            ),
                            child: textField = TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).backgroundColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                hintText: SEARCH_DOCTOR_BY_NAME,
                                hintStyle: Theme.of(context).textTheme.bodyText2.apply(
                                  color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                                ),
                                suffixIcon: Container(
                                    height: 20,
                                    width: 20,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(13),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: isLoading
                                              ? AlwaysStoppedAnimation(Theme.of(context).accentColor)
                                              : AlwaysStoppedAnimation(Colors.transparent),
                                        ),
                                      ),
                                    ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).backgroundColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).backgroundColor),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).backgroundColor),
                                  borderRadius: BorderRadius.circular(15),
                                )
                              ),
                              onChanged: (val){
                                setState(() {
                                  searchKeyword = val;
                                  _onChanged(val);
                                });
                              },
                              onSubmitted: (val){
                                setState(() {
                                  searchKeyword = val;
                                });
                              },
                            ),


                          ),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          onTap: () async{
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchedScreen(_textController.text)));
                            setState(() {
                              _newData.clear();
                              _textController.clear();
                              _textController.text = "";
                              _onChanged(_textController.text);
                              //_textController = new TextEditingController();
                              //textField.controller.clearComposing();
                              //_textController.selection.end;
                            });
                            },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/homeScreenImages/search_icon.png",
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget upCommingAppointments(){
    return Center(
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(UPCOMING_APPOINTMENTS,
                  style: Theme.of(context).textTheme.bodyText2.apply(
                    fontWeightDelta: 3
                  )
                ),
                isAppointmentExist
                    ? TextButton(onPressed: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllAppointments(userAppointmentsClass)),
                  );
                }, child: Text(SEE_ALL,
                  style: Theme.of(context).textTheme.bodyText1.apply(
                    color: Theme.of(context).accentColor,
                  )
                ),)
                    : Container(height: 40,)
              ],
            ),
            SizedBox(height: 5,),
            FutureBuilder(
              future: loadAppointments,
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  );
                }else if(snapshot.connectionState == ConnectionState.done && isAppointmentExist){
                  return ListView.builder(
                    itemCount: userAppointmentsClass.data.appointmentData.length > 2 ? 2 : userAppointmentsClass.data.appointmentData.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index){
                      return appointmentListWidget(index, userAppointmentsClass.data.appointmentData);
                    },
                  );
                }else{
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        children: [
                          Image.asset(
                              "assets/homeScreenImages/no_appo_img.png"
                          ),
                          SizedBox(height: 15,),
                          Text(
                            YOU_DONOT_HAVE_ANY_UPCOMING_APPOINTMENT,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                              fontSize: 11
                            ),
                          ),
                          SizedBox(height: 3,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                FIND_BEST_DOCTORS_NEAR_YOU_BY_SPECIALITY,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  fontSize: 10
                                ),
                              ),
                              SizedBox(width: 3,),
                              InkWell(
                                onTap: (){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                      builder: (context) => SpecialityScreen(),
                                    )
                                  );
                                },
                                child: Text(
                                  CLICK_HERE,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    color: Colors.amber.shade700
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget appointmentListWidget(int index,List<dynamic> data) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserAppointmentDetails(data[index].id.toString())),
        );
      },
      child: Container(
        height: 90,
        margin: EdgeInsets.fromLTRB(0,5,0,5),
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
                imageUrl: Uri.encodeFull(data[index].image),
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                ),),
                errorWidget: (context,url,err) => Container(color: Theme.of(context).primaryColorLight, child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 20, width: 20,),
                )),
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data[index].name,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(data[index].departmentName,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w400
                          ),
                        ),
                      ],
                    ),
                  ),
                 // SizedBox(height: 10,),
                  Container(
                    child: Text(data[index].address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontSize: 10,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/homeScreenImages/calender.png",
                  height: 17,
                  width: 17,
                ),
                SizedBox(height: 5,),
                Text(
                  data[index].date.toString().substring(8)+"-"+data[index].date.toString().substring(5,7)+"-"+data[index].date.toString().substring(0,4),
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: 11,
                      fontWeight: FontWeight.w400
                  ),
                ),
                Text(data[index].slot,
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  fetchUpcomingAppointments() async{
    final response = await get("$SERVER_ADDRESS/api/usersuappointment?user_id=$userId");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success'] == "1"){
        setState(() {
          isAppointmentExist = true;
          userAppointmentsClass = UserAppointmentsClass.fromJson(jsonResponse);
        });
      }else{
        setState(() {
          isAppointmentExist = false;
        });
      }
    }
  }

  Widget nearByDoctors(){
    return Center(
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(NEARBY_DOCTORS,
                  style: Theme.of(context).textTheme.bodyText2.apply(
                    fontWeightDelta: 3
                  )
                ),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AllNearby()));
                }, child: Text(SEE_ALL,
                  style: Theme.of(context).textTheme.bodyText1.apply(
                    color: Theme.of(context).accentColor
                  )
                )),
              ],
            ),
            SizedBox(height: 5,),
            isNearbyLoading
            ? isErrorInNearby
                ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(TURN_ON_LOCATION_AND_RETRY,
                    style: Theme.of(context).textTheme.bodyText1
                  ),
                  TextButton(
                      onPressed: (){
                        _getLocationStart();
                      },
                      child: Text(RETRY,
                        style: Theme.of(context).textTheme.bodyText1.apply(
                          color: Theme.of(context).accentColor,
                        )
                      ),
                  )
                ],
              ),
            )
                : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Theme.of(context).accentColor),
                strokeWidth: 2,
              ),
            )
            :
            GridView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: nearbyDoctorClass.data.nearbyData.length < 8
                    ? nearbyDoctorClass.data.nearbyData.length
                    : 8,
                itemBuilder: (BuildContext ctx, index) {
                    return nearByGridWidget(
                      nearbyDoctorClass.data.nearbyData[index].image,
                      nearbyDoctorClass.data.nearbyData[index].name,
                      nearbyDoctorClass.data.nearbyData[index].departmentName,
                      nearbyDoctorClass.data.nearbyData[index].id,
                    );
                }),
          ],
        ),
      ),
    );
  }

  Widget nearByGridWidget(img, name, dept, id) {
    print(img);
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(id.toString())),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: Uri.encodeFull(img),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 50, width: 50,),
                    ),

                  ),
                  errorWidget: (context,url,err) => Container(
                    color: Theme.of(context).primaryColorLight,
                    child: Center(
                      child: Image.asset("assets/homeScreenImages/user_unactive.png",height: 50, width: 50,),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(name,
              style: Theme.of(context).textTheme.bodyText1
            ),
            Text(dept,
              style: Theme.of(context).textTheme.caption.apply(
                color: Theme.of(context).primaryColorDark.withOpacity(0.5),
              )
            ),
          ],
        ),
      ),
    );
  }

  //-----------------functions--------------------------

  _onChanged(String value) async{

    if(value.length == 0){
      setState(() {
        _newData.clear();

        isSearching = false;
        print("length 0");
        print(_newData);
      });
    }else {
      setState(() {
        isLoading = true;
        isSearching = true;
      });
      final response = await get(
          "$SERVER_ADDRESS/api/searchdoctor?term=$value");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
        //print([0].name);
        setState(() {
          _newData.clear();
          //print(searchDoctorClass.data.doctorData);
          _newData.addAll(searchDoctorClass.data.doctorData);
          nextUrl = searchDoctorClass.data.links.last.url;
          print(nextUrl);
          isLoading = false;
        });
      }
    }

  }

  _loadMoreFunc() async{
    if(nextUrl == null){
      return;
    }
    setState(() {
      isLoadingMore = true;
    });
    print(searchKeyword);
    final response = await get(
        "$nextUrl&term=$searchKeyword");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      searchDoctorClass = SearchDoctorClass.fromJson(jsonResponse);
      //print([0].name);
      setState(() {
        //print(searchDoctorClass.data.doctorData);
        _newData.addAll(searchDoctorClass.data.doctorData);
        isLoadingMore = false;
        nextUrl = searchDoctorClass.data.links.last.url;
        print(nextUrl);
      });
    }
  }

  void _getLocationStart() async {

    final response = await get(
        "$SERVER_ADDRESS/api/nearbydoctor?lat=21.234567&lon=35.345678");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      //print([0].name);
      setState(() {
        nearbyDoctorClass = NearbyDoctorsClass.fromJson(jsonResponse);
        print("Finished");
        isNearbyLoading = false;
      });
    }

    // setState(() {
    //   isErrorInNearby = false;
    //   isNearbyLoading = true;
    // });
    // print('Started');
    // //Toast.show("loading", context);
    // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) async{
    //   final response = await get(
    //       "$SERVER_ADDRESS/api/nearbydoctor?lat=${value.latitude}&lon=${value.longitude}");
    //   if (response.statusCode == 200) {
    //     final jsonResponse = jsonDecode(response.body);
    //     //print([0].name);
    //     setState(() {
    //       nearbyDoctorClass = NearbyDoctorsClass.fromJson(jsonResponse);
    //       print("Finished");
    //       isNearbyLoading = false;
    //     });
    //   }
    // })
    //     .catchError((e){
    //       //Toast.show(e.toString(), context,duration: 3);
    //   print(e);
    //   setState(() {
    //     isErrorInNearby = true;
    //   });
    // });
  }

}
