import 'dart:convert';

import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter_doctor_web_app/modals/NearbyDoctorClass.dart';
import 'package:flutter_doctor_web_app/modals/SpecialityDoctorClass.dart';
import 'package:flutter_doctor_web_app/views/DetailsPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart';
import 'package:loadmore/loadmore.dart';
import 'package:paging/paging.dart';

import '../main.dart';


class SpecialityDoctorsScreen extends StatefulWidget {

  String id;
  SpecialityDoctorsScreen(this.id);

  @override
  _SpecialityDoctorsScreenState createState() => _SpecialityDoctorsScreenState();
}

class _SpecialityDoctorsScreenState extends State<SpecialityDoctorsScreen> {

  bool isErrorInNearby = false;
  bool isNearbyLoading = true;
  List<DoctorData> list = List();
  bool isLoadingMore = false;
  String nextUrl = "";
  SpecialityDoctorsClass specialityDoctorsClass;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocationStart();

    _scrollController.addListener(() {
      //print(_scrollController.position.pixels);
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("Loadmore");
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Container(),
          flexibleSpace: header(),
        ),
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
            controller: _scrollController,
            child: nearByDoctors()),
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
                NEARBY_DOCTORS,
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


  Widget nearByDoctors(){
    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 5),
      child: Column(
        children: [
          SizedBox(height: 10,),
          isNearbyLoading ? Center(
            child: CircularProgressIndicator(),
          ) :
          list == null
              ? isErrorInNearby ? Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Text(TURN_ON_LOCATION_AND_RETRY,
                    style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ) : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.cyanAccent.shade700),
              strokeWidth: 2,
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: list.length,
              itemBuilder: (BuildContext ctx, index) {
                return nearByGridWidget(
                  list[index].image,
                  list[index].name,
                  list[index].departmentName,
                  list[index].id,
                );
              }),
          isLoadingMore ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: LinearProgressIndicator(),
          ) : Container()
        ],
      ),
    );
  }



  Widget nearByGridWidget(img, name, dept, id) {
    return InkWell(
      onTap: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => DetailsPage(id.toString())),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                  width: 250,
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
                    //child: Padding(
                    //   padding: const EdgeInsets.all(20.0),
                    // )
                    //
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Text(name,
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              ),
            ),
            Text(dept,
              style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getLocationStart() async {
    setState(() {
      isNearbyLoading = true;
    });
    final response = await get(
        "$SERVER_ADDRESS/api/getlistofdoctorbyspecialty?department_id=${widget.id}");
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      //print([0].name);
      setState(() {
        specialityDoctorsClass = SpecialityDoctorsClass.fromJson(jsonResponse);
        print("Finished");
        nextUrl = specialityDoctorsClass.data.nextPageUrl;
        print(nextUrl);
        list.addAll(specialityDoctorsClass.data.doctorData);
        isNearbyLoading = false;
      });
    }
  }

  Future<bool> _loadMoreFunc() async {
    if (nextUrl != "null") {
      print('loading');
      setState(() {
        isLoadingMore = true;
      });
      final response = await get(
          "$SERVER_ADDRESS/api/getlistofdoctorbyspecialty?department_id=${widget.id}");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        //print([0].name);
        setState(() {
          specialityDoctorsClass = SpecialityDoctorsClass.fromJson(jsonResponse);
          print("Finished");
          nextUrl = specialityDoctorsClass.data.nextPageUrl;
          print(nextUrl);
          list.addAll(specialityDoctorsClass.data.doctorData);
          isLoadingMore = false;
        });
      }
    }
  }

}
