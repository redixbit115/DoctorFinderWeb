import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter_doctor_web_app/views/Doctor/DoctorDashboard.dart';
import 'package:flutter_doctor_web_app/views/Doctor/DoctorPastAppointments.dart';
import 'package:flutter_doctor_web_app/views/Doctor/DoctorProfile.dart';
import 'package:flutter_doctor_web_app/views/Doctor/LogoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppointmentScreen.dart';


class DoctorTabsScreen extends StatefulWidget {
  @override
  _DoctorTabsScreenState createState() => _DoctorTabsScreenState();
}

class _DoctorTabsScreenState extends State<DoctorTabsScreen> {

  List<Widget> screens = [
    DoctorDashboard(),
    DoctorPastAppointments(),
    DoctorProfile(),
    LogOutScreen(),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          //borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==0
                      ? "assets/homeScreenImages/home_active.png"
                      : "assets/homeScreenImages/home_unactive.png",
                  height: 25,
                  width: 25,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==1
                      ? "assets/homeScreenImages/appointment_active.png"
                      : "assets/homeScreenImages/appointment_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Appointment",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==2
                      ? "assets/homeScreenImages/user_active.png"
                      : "assets/homeScreenImages/user_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Edit profile",
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  index==3
                      ? "assets/loginScreenImages/logout-(1).png"
                      : "assets/loginScreenImages/logout.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Logout",
              ),
            ],
            selectedLabelStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 8,
            ),
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 7,
            ),
            unselectedItemColor: Colors.grey.shade500,
            selectedItemColor: Colors.black,
            onTap: (i){
              setState(() {
                index = i;
              });
            },
            currentIndex: index,
          ),
        ),
      ),
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
                onPressed: () async{
                  await SharedPreferences.getInstance().then((pref){
                    pref.setBool("isLoggedInAsDoctor", false);
                  });
                },
                color: Colors.cyanAccent,
                child: Text(YES,style: GoogleFonts.poppins(
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

