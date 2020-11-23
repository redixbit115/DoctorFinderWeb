import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_doctor_web_app/HttpTesting.dart';
import 'package:flutter_doctor_web_app/MapTesing.dart';
import 'package:flutter_doctor_web_app/views/SplashScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_messaging.dart';
import 'views/Doctor/loginAsDoctor.dart';
import 'views/HomeScreen.dart';
import 'views/MoreScreen.dart';
import 'views/UserPastAppointments.dart';

const String SERVER_ADDRESS =
    "https://freaktemplate.com/appointment_book";

const LANGUAGE = "en";

/// More examples see https://github.com/flutterchina/dio/tree/master/example

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
      Container(
        width: 500,
        child: MaterialApp(
          home: TabsScreen(),
          theme: ThemeData(
            timePickerTheme: TimePickerThemeData(
              dayPeriodTextColor: Colors.cyanAccent.shade700,
              //hourMinuteColor: Colors.cyanAccent.shade700,
              helpTextStyle: GoogleFonts.poppins(),
            ),
            accentColor: Colors.cyanAccent.shade700,
            primaryColor: Colors.cyanAccent,
            backgroundColor: Colors.white,
            primaryColorDark: Colors.grey.shade700,
            primaryColorLight: Colors.grey.shade200,
            //highlightColor: Colors.amber.shade700,
            textTheme: TextTheme(
              headline1: GoogleFonts.poppins(),
              headline2: GoogleFonts.poppins(),
              headline3: GoogleFonts.poppins(),
              headline4: GoogleFonts.poppins(),
              headline5: GoogleFonts.poppins(),
              headline6: GoogleFonts.poppins(),
              subtitle1: GoogleFonts.poppins(),
              subtitle2: GoogleFonts.poppins(),
              caption: GoogleFonts.poppins(
                fontSize: 10,
              ),
              bodyText1: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500
              ),
              bodyText2: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w300
              ),
              button: GoogleFonts.poppins(),
            ),
          ),
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''), // English, no country code
            const Locale('he', ''), // Hebrew, no country code
            const Locale('ar', ''), // Hebrew, no country code
            const Locale.fromSubtags(languageCode: 'zh'), // Chinese *See Advanced Locales below*
            // ... other locales the app supports
          ],
        ),
      )
  );
}


class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {

  List<Widget> screens = [
    HomeScreen(),
    UserPastAppointments(),
    LoginAsDoctor(),
    //Container(),
    MoreScreen()
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
                      ? "assets/homeScreenImages/d_l_active.png"
                      : "assets/homeScreenImages/d_l_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "Doctor login",
              ),

              BottomNavigationBarItem(
                icon: Image.asset(
                  index==3
                      ? "assets/homeScreenImages/more_active.png"
                      : "assets/homeScreenImages/more_unactive.png",
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                ),
                label: "More",
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

}
