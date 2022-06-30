import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
//==============================================================================
//============================= Variables Declaration ==========================

  bool _isLoading = true;
  bool _isNetworkAvail = true;
  String? contactUs;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

//==============================================================================
//============================= initState Method ===============================

  @override
  void initState() {
    super.initState();
    getSettings();
  }

//==============================================================================
//========================= getStatics API =====================================

  getSettings() async {
    _isNetworkAvail = await isNetworkAvailable();
    var parameter = {};
    if (_isNetworkAvail) {
      apiBaseHelper.postAPICall(getSettingsApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            contactUs = getdata["data"]["contact_us"][0].toString();
          } else {
            setSnackbar(msg);
          }
          setState(
            () {
              _isLoading = false;
            },
          );
        },
        onError: (error) {
          setSnackbar(error.toString());
        },
      );
    } else {
      setState(
        () {
          _isLoading = false;
          _isNetworkAvail = false;
        },
      );
    }
  }

//==============================================================================
//=============================== Snackbar =====================================

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: black),
        ),
        backgroundColor: white,
        elevation: 1.0,
      ),
    );
  }

//==============================================================================
//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return _isLoading
        ? Scaffold(
            appBar: getAppBar(getTranslated(context, "CONTACTUS")!, context),
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : contactUs! != null
            ? Scaffold(
                appBar: getAppBar(
                  getTranslated(context, "CONTACTUS")!,
                  context,
                ),
                body: SingleChildScrollView(
                    child: Html(
                  data: contactUs!,
                )))
            // WebviewScaffold(
            //     appBar: getAppBar(
            //       getTranslated(context, "CONTACTUS")!,
            //       context,
            //     ),
            //     withJavascript: true,
            //     appCacheEnabled: true,
            //     scrollBar: false,
            //     url: new Uri.dataFromString(contactUs!,
            //             mimeType: 'text/html', encoding: utf8)
            //         .toString(),
            //   )
            : Scaffold(
                appBar: getAppBar(
                  getTranslated(context, "CONTACTUS")!,
                  context,
                ),
                body: _isNetworkAvail ? Container() : noInternet(context),
              );
  }
}

//==============================================================================
//============================ No Internet Widget ==============================

noInternet(BuildContext context) {
  return Container(
    child: Center(
      child: Text(
        getTranslated(context, "NoInternetAwailable")!,
      ),
    ),
  );
}
