import 'package:flutter_doctor_web_app/en.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class TermAndConditions extends StatefulWidget {
  @override
  _TermAndConditionsState createState() => _TermAndConditionsState();
}

class _TermAndConditionsState extends State<TermAndConditions> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: header(),
          leading: Container(),
        ),
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Doctor Finder",style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),),
                        Text(
                          "\nThese terms and conditions outline the rules and regulations for the use of Medic Finder Website."
                              "\n\nBy accessing this website we assume you accept these terms and conditions in full. Do not continue to use FoodDelivery's website if you do not accept all of the terms and conditions stated on this page."
                              "\n\nThe following terminology applies to these Terms and Conditions, Privacy Statement and Disclaimer Notice and any or all Agreements: Client, You and Your refers to you, the person accessing this website and accepting the Companys terms and conditions. The Company, Ourselves, We, Our and Us, refers to our Company. Party, Parties, or Us, refers to both the Client and ourselves, or either the Client or ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner, whether by formal meetings of a fixed duration, or any other means, for the express purpose of meeting the Clients needs in respect of provision of the Companys stated services/products, in accordance with and subject to, prevailing law of . Any use of the above terminology or other words in the singular, plural, capitalisation and/or he/she or they, are taken as interchangeable and therefore as referring to same."
                              "\n\n",style: TextStyle(
                          fontSize: 13,),
                          textAlign: TextAlign.justify,
                        ),
                        Text(
                          "Reservation of Rights",style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),),
                        Text(
                          "\nWe reserve the right at any time and in its sole discretion to request that you remove all links or any particular link to our Web site. You agree to immediately remove all links to our Web site upon such request. We also reserve the right to amend these terms and conditions and its linking policy at any time. By continuing to link to our Web site, you agree to be bound to and abide by these linking terms and conditions.\n\n",style: TextStyle(
                          fontSize: 13,),
                          textAlign: TextAlign.justify,
                        ),

                        Text(
                          "Disclaimer",style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),),
                        Text(
                          "\nTo the maximum extent permitted by applicable law, we exclude all representations, warranties and conditions relating to our website and the use of this website (including, without limitation, any warranties implied by law in respect of satisfactory quality, fitness for purpose and/or the use of reasonable care and skill). Nothing in this disclaimer will:\n\n"
                              "\n1.) limit or exclude our or your liability for death or personal injury resulting from negligence"
                              "\n2.) limit or exclude our or your liability for fraud or fraudulent misrepresentation"
                              "\n3.) limit any of our or your liabilities in any way that is not permitted under applicable law"
                              "\n4.) exclude any of our or your liabilities that may not be excluded under applicable law."
                              "\n\nThe limitations and exclusions of liability set out in this Section and elsewhere in this disclaimer: (a) are subject to the preceding paragraph; and (b) govern all liabilities arising under the disclaimer or in relation to the subject matter of this disclaimer, including liabilities arising in contract, in tort (including negligence) and for breach of statutory duty."
                              "\nTo the extent that the website and the information and services on the website are provided free of charge, we will not be liable for any loss or damage of any nature.",
                          style: TextStyle(
                            fontSize: 13,),
                          textAlign: TextAlign.justify,
                        ),

                        Text(
                          "\n\nCredit & Contact Information",style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),),
                        Text(
                          "\nThis Terms and conditions page was created at termsandconditionstemplate.com generator. If you have any queries regarding any of our terms, please contact us.",
                          style: TextStyle(
                            fontSize: 13,),
                          textAlign: TextAlign.justify,
                        ),

                        SizedBox(height: 20,),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
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
                TERM_AND_CONDITIONS,
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

}
