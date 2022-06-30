import 'dart:async';
import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/ContainerDesing.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'Login.dart';

class SetPass extends StatefulWidget {
  final String mobileNumber;

  SetPass({
    Key? key,
    required this.mobileNumber,
  })  : assert(mobileNumber != null),
        super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<SetPass> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final confirmpassController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? password, comfirmpass;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getResetPass();
    } else {
      Future.delayed(Duration(seconds: 2)).then(
        (_) async {
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
          await buttonController!.reverse();
        },
      );
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: fontColor),
        ),
        backgroundColor: lightWhite,
        elevation: 1.0,
      ),
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: kToolbarHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, "TRY_AGAIN_INT_LBL")!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(Duration(seconds: 2)).then(
                  (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    } else {
                      await buttonController!.reverse();
                      setState(
                        () {},
                      );
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> getResetPass() async {
    var data = {
      mobileno: widget.mobileNumber,
      NEWPASS: password,
    };
    apiBaseHelper.postAPICall(forgotPasswordApi, data).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (!error) {
          setSnackbar(getTranslated(context, "PASS_SUCCESS_MSG")!);
          Future.delayed(
            Duration(seconds: 1),
          ).then(
            (_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ),
              );
            },
          );
        } else {
          setSnackbar(msg!);
        }
      },
      onError: (error) {
        setSnackbar(error.toString());
      },
    );
  }

  forgotpassTxt() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: new Text(
          getTranslated(context, "FORGOT_PASSWORDTITILE")!,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  setPass() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 30.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        style: Theme.of(this.context)
            .textTheme
            .subtitle2!
            .copyWith(color: fontColor, fontWeight: FontWeight.normal),
        controller: passwordController,
        validator: (val) => validatePass(val, context),
        onSaved: (String? value) {
          password = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: SvgPicture.asset(
            "assets/images/password.svg",
            color: lightBlack2,
          ),
          hintText: getTranslated(context, "PASSHINT_LBL")!,
          hintStyle: TextStyle(
            color: lightBlack2,
            fontWeight: FontWeight.normal,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 25,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: lightBlack2,
            ),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setConfirmpss() {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 20.0),
      child: TextFormField(
        keyboardType: TextInputType.text,
        obscureText: true,
        style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: fontColor,
              fontWeight: FontWeight.normal,
            ),
        controller: confirmpassController,
        validator: (value) {
          if (value!.length == 0)
            return getTranslated(context, "CON_PASS_REQUIRED_MSG")!;
          if (value != password) {
            return getTranslated(context, "CON_PASS_NOT_MATCH_MSG")!;
          } else {
            return null;
          }
        },
        onSaved: (String? value) {
          comfirmpass = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: SvgPicture.asset(
            "assets/images/password.svg",
            color: lightBlack2,
          ),
          hintText: getTranslated(context, "CONFIRMPASSHINT_LBL")!,
          hintStyle: TextStyle(
            color: lightBlack2,
            fontWeight: FontWeight.normal,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 25,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    buttonController = new AnimationController(
      duration: new Duration(milliseconds: 2000),
      vsync: this,
    );

    buttonSqueezeanimation = new Tween(
      begin: width * 0.7,
      end: 50.0,
    ).animate(
      new CurvedAnimation(
        parent: buttonController!,
        curve: new Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setPassBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: AppBtn(
        title: getTranslated(context, "SET_PASSWORD")!,
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          validateAndSubmit();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      key: _scaffoldKey,
      body: _isNetworkAvail
          ? Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: back(),
                ),
                Image.asset(
                  'assets/images/doodle.png',
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
                getLoginContainer(),
                getLogo(),
              ],
            )
          : noInternet(context),
    );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      top: MediaQuery.of(context).size.height * 0.2, //original
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      forgotpassTxt(),
                      setPass(),
                      setConfirmpss(),
                      setPassBtn(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) - 50,
      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      child: SizedBox(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          'assets/images/loginlogo.svg',
        ),
      ),
    );
  }
}
