import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Terms_And_Condition extends StatefulWidget {
  const Terms_And_Condition({Key? key}) : super(key: key);

  @override
  _Terms_And_ConditionState createState() => _Terms_And_ConditionState();
}

class _Terms_And_ConditionState extends State<Terms_And_Condition> {
  bool _isLoading = true;
  bool _isNetworkAvail = true;
  String? termCondition;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  @override
  void initState() {
    super.initState();
    getSettings();
  }

  getSettings() async {
    var parameter = {};
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      apiBaseHelper.postAPICall(getSettingsApi, parameter).then(
        (getdata) async {
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            termCondition = getdata["data"]["terms_conditions"][0].toString();
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

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return _isLoading
        ? Scaffold(
            appBar: getAppBar(
              getTranslated(context, "TERM_CONDITIONS")!,
              context,
            ),
            body: Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : termCondition != null
            ? Scaffold(
                appBar: getAppBar(
                  getTranslated(context, "TERM_CONDITIONS")!,
                  context,
                ),
                body: SingleChildScrollView(
                  child: Html(
                    data: termCondition!,
                  ),
                ),
              )
            // WebviewScaffold(
            //     appBar: getAppBar(
            //       getTranslated(context, "TERM_CONDITIONS")!,
            //       context,
            //     ),
            //     withJavascript: true,
            //     appCacheEnabled: true,
            //     scrollBar: false,
            //     url: new Uri.dataFromString(termCondition!,
            //             mimeType: 'text/html', encoding: utf8)
            //         .toString(),
            //   )
            : Scaffold(
                appBar: getAppBar(
                  getTranslated(context, "TERM_CONDITIONS")!,
                  context,
                ),
                body: _isNetworkAvail ? Container() : noInternet(context),
              );
  }
}

noInternet(BuildContext context) {
  return Container(
    child: Center(
      child: Text(getTranslated(context, "NoInternetAwailable")!),
    ),
  );
}
