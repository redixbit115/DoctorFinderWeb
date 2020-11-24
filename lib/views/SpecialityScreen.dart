import 'dart:convert';
import 'dart:math';

import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter_doctor_web_app/main.dart';
import 'package:flutter_doctor_web_app/modals/SpecialityClass.dart';
import 'package:flutter_doctor_web_app/views/SpecialityDoctorsScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

class SpecialityScreen extends StatefulWidget {
  @override
  _SpecialityScreenState createState() => _SpecialityScreenState();
}

class _SpecialityScreenState extends State<SpecialityScreen> {

  SpecialityClass specialityClass;
  bool isLoading = true;
  bool isLoadingMore = false;
  ScrollController scrollController = ScrollController();
  List<SpecialityData> list = List();
  String nextUrl = "";

  getSpeciality() async{
    setState(() {
      isLoading = true;
    });
    final response = await get("$SERVER_ADDRESS/api/getspeciality");
    if(response.statusCode == 200){
      final jsonResponse = jsonDecode(response.body);
      specialityClass = SpecialityClass.fromJson(jsonResponse);
      print(specialityClass.data.specialityData.length);
      setState(() {
        list.addAll(specialityClass.data.specialityData);
        nextUrl = specialityClass.data.links.last.url;
        isLoading = false;
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSpeciality();
    scrollController.addListener(() {
      print(scrollController.position.pixels);
      if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        print("Loadmore");
        //_loadMoreFunc();
        loadMore();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    scrollController.dispose();
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
        body: Stack(
          children: [
          isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
          : specialityList(),
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
                SPECIALITY,
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

  Widget specialityList(){
    return Center(
      child: Container(
        constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(10),
                itemCount: list.length,
                //crossAxisCount: 2,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                shrinkWrap: true,
                itemBuilder: (context, index){
                  Color x = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => SpecialityDoctorsScreen(list[index].id.toString()),
                      ));
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: Image.asset(
                                "assets/specialityScreenImages/speciality_bg.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: x.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.all(13),
                                child: Image.network(
                                  list[index].icon,
                                  height: 50,
                                  width: 50,
                                  color: x,
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(
                                list[index].name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                              Text(
                                list[index].totalDoctors.toString() + " specialist",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                    fontSize: 13
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                //crossAxisSpacing: 8,
                //mainAxisSpacing: 8,
                // children: List.generate(list.length, (index){
                //
                // }),
              ),
            ),
            isLoadingMore
                ? Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }

  loadMore() async {
    if (nextUrl != null) {
      print(isLoadingMore);
      setState(() {
        isLoadingMore = true;
      });
      final response = await get(nextUrl);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        specialityClass = SpecialityClass.fromJson(jsonResponse);
        print(specialityClass.data.specialityData.length);
        setState(() {
          list.addAll(specialityClass.data.specialityData);
          isLoadingMore = false;
        });
      }
    }
  }


}
