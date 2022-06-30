import 'dart:async';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/ContainerDesing.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Screen/TermFeed/Terms_Conditions.dart';
import 'package:eshopmultivendor/Screen/Authentication/VerifyOTP.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../TermFeed/Privacy_Policy.dart';

class SendOtp extends StatefulWidget {
  String? title;

  SendOtp({Key? key, this.title}) : super(key: key);

  @override
  _SendOtpState createState() => new _SendOtpState();
}

class _SendOtpState extends State<SendOtp> with TickerProviderStateMixin {
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? mobile, id, countrycode, countryName, mobileno;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      getVerifyUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        setState(() {
          _isNetworkAvail = false;
        });
        await buttonController!.reverse();
      });
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

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: fontColor),
      ),
      backgroundColor: lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
      ),
    );
  }

  Future<void> getVerifyUser() async {
    var data = {Mobile: mobile};
    print(data);
    apiBaseHelper.postAPICall(verifyUserApi, data).then(
      (getdata) async {
        bool error = getdata["error"];
        String? msg = getdata["message"];
        await buttonController!.reverse();
        if (widget.title == getTranslated(context, "SEND_OTP_TITLE")!) {
          if (!error) {
            setSnackbar(msg!);

            setPrefrence(Mobile, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);
            Future.delayed(Duration(seconds: 1)).then(
              (_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtp(
                      mobileNumber: mobile!,
                      countryCode: countrycode,
                      title: getTranslated(context, "SEND_OTP_TITLE")!,
                    ),
                  ),
                );
              },
            );
          } else {
            setSnackbar(msg!);
          }
        }
        if (widget.title == getTranslated(context, "FORGOT_PASS_TITLE")!) {
          if (!error) {
            setPrefrence(Mobile, mobile!);
            setPrefrence(COUNTRY_CODE, countrycode!);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyOtp(
                  mobileNumber: mobile!,
                  countryCode: countrycode,
                  title: getTranslated(context, "FORGOT_PASS_TITLE")!,
                ),
              ),
            );
          } else {
            setSnackbar(msg!);
          }
        }
      },
      onError: (error) async {
        print(error);
        await buttonController!.reverse();
      },
    );
  }

  verifyCodeTxt() {
    return Padding(
      padding:
          EdgeInsets.only(top: 40.0, left: 40.0, right: 40.0, bottom: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: new Text(
          getTranslated(context, "SEND_VERIFY_CODE_LBL")!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  setCodeWithMono() {
    return Container(
      width: width * 0.7,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7.0),
          color: lightWhite,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: setCountryCode(),
            ),
            Expanded(
              flex: 4,
              child: setMono(),
            )
          ],
        ),
      ),
    );
  }

  setCountryCode() {
    return CountryCodePicker(
        showCountryOnly: false,
        flagWidth: 20,
        searchDecoration: InputDecoration(
          hintText: getTranslated(context, "COUNTRY_CODE_LBL")!,
          fillColor: fontColor,
        ),
        showOnlyCountryWhenClosed: false,
        initialSelection: 'IN',
        dialogSize: Size(width, height),
        alignLeft: true,
        textStyle: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
        onChanged: (CountryCode countryCode) {
          countrycode = countryCode.toString().replaceFirst("+", "");
          countryName = countryCode.name;
        },
        onInit: (code) {
          countrycode = code.toString().replaceFirst("+", "");
        });
  }

  setMono() {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: mobileController,
      style: Theme.of(this.context)
          .textTheme
          .subtitle2!
          .copyWith(color: fontColor, fontWeight: FontWeight.normal),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (String? value) {
        mobile = value;
      },
      validator: (val) => validateMob(val!, context),
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primary),
          borderRadius: BorderRadius.circular(7.0),
        ),
        hintText: getTranslated(context, "MOBILEHINT_LBL")!,
        hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: fontColor,
              fontWeight: FontWeight.normal,
            ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: lightWhite,
          ),
        ),
      ),
    );
  }

  verifyBtn() {
    return AppBtn(
      title: widget.title == getTranslated(context, "SEND_OTP_TITLE")
          ? getTranslated(context, "Send OTP")!
          : getTranslated(context, "GET_PASSWORD")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  termAndPolicyTxt() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            getTranslated(context, "CONTINUE_AGREE_LBL")!,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: fontColor,
                  fontWeight: FontWeight.normal,
                ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Terms_And_Condition()));
                  },
                  child: Text(
                    getTranslated(context, "TERMS_SERVICE_LBL")!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        color: fontColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.normal),
                  )),
              SizedBox(
                width: 5.0,
              ),
              Text(
                getTranslated(context, "AND_LBL")!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                      color: fontColor,
                      fontWeight: FontWeight.normal,
                    ),
              ),
              SizedBox(
                width: 5.0,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicy()));
                },
                child: Text(
                  getTranslated(context, "PRIVACY_POLICY_LBL")!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        color: fontColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ),
            ],
          ),
        ],
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
        duration: new Duration(milliseconds: 2000), vsync: this);

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

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
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
      top: MediaQuery.of(context).size.height * 0.2,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.6),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            getTranslated(context, "FORGOT_PASSWORDTITILE")!,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      verifyCodeTxt1(),
                      setCodeWithMono1(),
                      verifyBtn(),
                      termAndPolicyTxt(),
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

  Widget verifyCodeTxt1() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          getTranslated(context, "SEND_VERIFY_CODE_LBL")!,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget setCodeWithMono1() {
    return Container(
      width: width * 0.9,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: setCountryCode(),
          ),
          Expanded(
            flex: 4,
            child: setMono(),
          )
        ],
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
