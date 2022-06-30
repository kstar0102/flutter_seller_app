import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eshopmultivendor/Localization/Demo_Localization.dart';
import 'package:flutter/material.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Color.dart';
import 'Constant.dart';
import 'String.dart';
import 'package:shimmer/shimmer.dart';

//oredrlist
String capitalize(String s) {
  if (s == null || s == "") {
    return "";
  } else {
    return s[0].toUpperCase() + s.substring(1);
  }
}

//==============================================================================
//============================= name verification ==============================

String? validateUserName(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "USER_REQUIRED")!;
  }
  if (value.length <= 1) {
    return getTranslated(context, "USER_LENGTH")!;
  }
  return null;
}

//==============================================================================
//============================= container decoration ===========================

shadow() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: white,
        //  offset: Offset(0, 0),
        // blurRadius: 30,
      )
    ],
  );
}

//===========
Future<String?> getPrefrence(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

setPrefrence(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

//------------------------------------------------------------------------------
//======================= Shimmer Effect =======================================

Widget shimmer() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
              .map((_) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80.0,
                          height: 80.0,
                          color: white,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 18.0,
                                color: white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: double.infinity,
                                height: 8.0,
                                color: white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 100.0,
                                height: 8.0,
                                color: white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                              ),
                              Container(
                                width: 20.0,
                                height: 8.0,
                                color: white,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    ),
  );
}

//------------------------------------------------------------------------------
//======================= Show Dialog animation  ==================================

dialogAnimate(BuildContext context, Widget dialge) {
  return showGeneralDialog(
    barrierColor: Colors.black.withOpacity(0.5),
    transitionBuilder: (context, a1, a2, widget) {
      return Transform.scale(
        scale: a1.value,
        child: Opacity(
          opacity: a1.value,
          child: dialge,
        ),
      );
    },
    transitionDuration: Duration(milliseconds: 200),
    barrierDismissible: true,
    barrierLabel: '',
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Container();
    },
  );
}

//------------------------------------------------------------------------------
//======================= Container Decoration  ==================================

back() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [grad1Color, grad2Color],
      stops: [0, 1],
    ),
  );
}

//------------------------------------------------------------------------------
//======================= Language Translate  ==================================

String? getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context)!.translate(key);
}

//------------------------------------------------------------------------------
//======================= internet not awailable ===============================

noIntImage() {
  return Image.asset(
    'assets/images/no_internet.png',
    fit: BoxFit.contain,
  );
}

noIntText(BuildContext context) {
  return Container(
      child: Text(getTranslated(context, "NO_INTERNET")!,
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: primary, fontWeight: FontWeight.normal)));
}

noIntDec(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
    child: Text(
      getTranslated(context, "NO_INTERNET_DISC")!,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.headline6!.copyWith(
            color: lightBlack2,
            fontWeight: FontWeight.normal,
          ),
    ),
  );
}

//------------------------------------------------------------------------------
//======================= AppBar Widget ========================================

getAppBar(String title, BuildContext context) {
  return AppBar(
    titleSpacing: 0,
    backgroundColor: white,
    leading: Builder(
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),
          decoration: shadow(),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_left,
                color: primary,
                size: 30,
              ),
            ),
          ),
        );
      },
    ),
    title: Text(
      title,
      style: TextStyle(
        color: grad2Color,
      ),
    ),
  );
}

String? validateField(String? value, BuildContext context) {
  if (value!.length == 0)
    return getTranslated(context, "FIELD_REQUIRED")!;
  else
    return null;
}

//mobile verification

String? validateMob(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "MOB_REQUIRED")!;
  }
  if (value.length < 9) {
    return getTranslated(context, "VALID_MOB");
  }
  return null;
}

// product name velidatation

String? validateProduct(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return getTranslated(context, "ProductNameRequired")!;
  }
  if (value.length < 3) {
    return getTranslated(context, "VALID_PRO_NAME")!;
  }
  return null;
}

// product name velidatation

String? validateThisFieldRequered(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return "This Field is Required!";
  }

  return null;
}

// sort detail velidatation

String? sortdescriptionvalidate(String? value, BuildContext context) {
  if (value!.isEmpty) {
    return "Sort Description is required";
  }
  if (value.length < 3) {
    return "minimam 5 character is required ";
  }
  return null;
}

// password verification

String? validatePass(String? value, BuildContext context) {
  if (value!.length == 0)
    return getTranslated(context, "PWD_REQUIRED")!;
  else if (value.length <= 5)
    return getTranslated(context, "PWD_LENGTH")!;
  else
    return null;
}

//for no iteam
Widget getNoItem(BuildContext context) {
  return Center(
    child: Text(
      getTranslated(context, "noItem")!,
    ),
  );
}

placeHolder(double height) {
  return AssetImage(
    'assets/images/placeholder.png',
  );
}

erroWidget(double size) {
  return Image.asset(
    'assets/images/placeholder.png',
    height: size,
    width: size,
  );
}

// progress
Widget showCircularProgress(bool _isProgress, Color color) {
  if (_isProgress) {
    return Center(
        child: CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color),
    ));
  }
  return Container(
    height: 0.0,
    width: 0.0,
  );
}

//------------------------------------------------------------------------------
//======================= height & width of device =============================

double height = 0;
double width = 0;

//------------------------------------------------------------------------------
//============ connectivity_plus for checking internet connectivity ============

Future<bool> isNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

//------------------------------------------------------------------------------
//=======================  Shared Preference List ==============================

//1. for Login -----------------------------------------------------------------
setPrefrenceBool(String key, bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}

Future<bool> getPrefrenceBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

//------------------------------------------------------------------------------
//======================== User Detaile Save in funvtion =======================

Future<void> saveUserDetail(
  String userId,
  String name,
  String email,
  String mobile,
  String address,
  String storename,
  String storeurl,
  String storeDesc,
  String accNo,
  String accname,
  String bankCode,
  String bankName,
  String latitutute,
  String longitude,
  String taxname,
  String tax_number,
  String pan_number,
  String status,
  String storelogo,
) async {
  final waitList = <Future<void>>[];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  waitList.add(prefs.setString(Id, userId));
  waitList.add(prefs.setString(Username, name));
  waitList.add(prefs.setString(Email, email));
  waitList.add(prefs.setString(Mobile, mobile));
  waitList.add(prefs.setString(Address, address));
  waitList.add(prefs.setString(StoreName, storename));
  waitList.add(prefs.setString(Storeurl, storeurl));
  waitList.add(prefs.setString(storeDescription, storeDesc));
  waitList.add(prefs.setString(accountNumber, accNo));
  waitList.add(prefs.setString(accountName, accname));
  waitList.add(prefs.setString(BankCOde, bankCode));
  waitList.add(prefs.setString(bankNAme, bankName));
  waitList.add(prefs.setString(Latitude, latitutute));
  waitList.add(prefs.setString(Longitude, longitude));
  waitList.add(prefs.setString(taxName, taxname));
  waitList.add(prefs.setString(taxNumber, tax_number));
  waitList.add(prefs.setString(panNumber, pan_number));
  waitList.add(prefs.setString(StoreLogo, storelogo));
  await Future.wait(waitList);
}

//for login
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
//------------------------------------------------------------------------------
//============= jaguar_jwt for token, header for post request ==================

String getToken() {
  final claimSet = new JwtClaim(
    issuer: 'eshop',
    maxAge: const Duration(days: 365),
  );

  String token = issueJwtHS256(claimSet, jwtKey);
  print(token);
  return token;
}

Map<String, String> get headers => {
      "Authorization": 'Bearer ' + getToken(),
    };

//==============================================================================

// for log out

Future<void> clearUserSession() async {
  final waitList = <Future<void>>[];

  SharedPreferences prefs = await SharedPreferences.getInstance();

  waitList.add(prefs.remove(Id));
  waitList.add(prefs.remove(Mobile));
  waitList.add(prefs.remove(Email));
  CUR_USERID = '';
  CUR_USERNAME = "";

  await prefs.clear();
}
