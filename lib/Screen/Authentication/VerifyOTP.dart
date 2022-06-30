import 'dart:async';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/ContainerDesing.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Screen/Authentication/SetNewPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyOtp extends StatefulWidget {
  final String? mobileNumber, countryCode, title;

  VerifyOtp(
      {Key? key,
      required String this.mobileNumber,
      this.countryCode,
      this.title})
      : assert(mobileNumber != null),
        super(key: key);

  @override
  _MobileOTPState createState() => new _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = new GlobalKey();
  String? password, mobile, countrycode;
  String? otp;
  bool isCodeSent = false;
  late String _verificationId;
  String signature = "";
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getUserDetails();
    getSingature();
    _onVerifyCode();
    Future.delayed(Duration(seconds: 60)).then(
      (_) {
        _isClickable = true;
      },
    );
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

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    await SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    mobile = await getPrefrence(Mobile);
    countrycode = await getPrefrence(COUNTRY_CODE);
    setState(
      () {},
    );
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setSnackbar(getTranslated(context, "OTPWR")!);
      }
    } else {
      setState(
        () {
          _isNetworkAvail = false;
        },
      );

      Future.delayed(Duration(seconds: 60)).then((_) async {
        bool avail = await isNetworkAvailable();
        if (avail) {
          if (_isClickable)
            _onVerifyCode();
          else {
            setSnackbar(getTranslated(context, "OTPWR")!);
          }
        } else {
          await buttonController!.reverse();
          setSnackbar(getTranslated(context, "somethingMSg")!);
        }
      });
    }
  }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, "VERIFY_AND_PROCEED")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        _onFormSubmitted();
      },
    );
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

  void _onVerifyCode() async {
    setState(
      () {
        isCodeSent = true;
      },
    );
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          setSnackbar(getTranslated(context, "OTPMSG")!);
          setPrefrence(Mobile, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          if (widget.title == getTranslated(context, "FORGOT_PASS_TITLE")!) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SetPass(mobileNumber: mobile!),
              ),
            );
          }
        } else {
          setSnackbar(getTranslated(context, "OTPERROR")!);
        }
      }).catchError((error) {
        setSnackbar(error.toString());
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setSnackbar(authException.message!);

      setState(
        () {
          isCodeSent = false;
        },
      );
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      _verificationId = verificationId;
      setState(
        () {
          _verificationId = verificationId;
        },
      );
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(
        () {
          _isClickable = true;
          _verificationId = verificationId;
        },
      );
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    String code = otp!.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential _authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(_authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          await buttonController!.reverse();
          setSnackbar(getTranslated(context, "OTPMSG")!);
          setPrefrence(Mobile, mobile!);
          setPrefrence(COUNTRY_CODE, countrycode!);
          if (widget.title == getTranslated(context, "SEND_OTP_TITLE")) {
          } else if (widget.title ==
              getTranslated(context, "FORGOT_PASS_TITLE")) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SetPass(mobileNumber: mobile!),
                ),
              );
            });
          }
        } else {
          setSnackbar(getTranslated(context, "OTPERROR")!);
          await buttonController!.reverse();
        }
      }).catchError((error) async {
        setSnackbar(error.toString());

        await buttonController!.reverse();
      });
    } else {
      setSnackbar(getTranslated(context, "ENTEROTP")!);
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getImage() {
    return Expanded(
      flex: 4,
      child: Center(
        child: new Image.asset('assets/images/homelogo.png'),
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

  monoVarifyText() {
    return Padding(
        padding: EdgeInsets.only(
          top: 30.0,
        ),
        child: Center(
          child: new Text(getTranslated(context, "MOBILE_NUMBER_VARIFICATION")!,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: fontColor, fontWeight: FontWeight.bold)),
        ));
  }

  otpText() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
      child: Center(
        child: new Text(
          getTranslated(context, "SENT_VERIFY_CODE_TO_NO_LBL")!,
          style: Theme.of(context).textTheme.subtitle2!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  mobText() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 10.0,
        left: 20.0,
        right: 20.0,
        top: 10.0,
      ),
      child: Center(
        child: Text(
          "+$countrycode-$mobile",
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: fontColor,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  otpLayout() {
    return Padding(
      padding: EdgeInsets.only(
        left: 50.0,
        right: 50.0,
      ),
      child: Center(
        child: PinFieldAutoFill(
          decoration: UnderlineDecoration(
            textStyle: TextStyle(
              fontSize: 20,
              color: fontColor,
            ),
            colorBuilder: FixedColorBuilder(lightWhite),
          ),
          currentCode: otp,
          codeLength: 6,
          onCodeChanged: (String? code) {
            otp = code;
          },
          onCodeSubmitted: (String code) {
            otp = code;
          },
        ),
      ),
    );
  }

  resendText() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 30.0,
        left: 25.0,
        right: 25.0,
        top: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslated(context, "DIDNT_GET_THE_CODE")!,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: fontColor,
                  fontWeight: FontWeight.normal,
                ),
          ),
          InkWell(
            onTap: () async {
              await buttonController!.reverse();
              checkNetworkOtp();
            },
            child: Text(
              getTranslated(context, "RESEND_OTP")!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                    color: fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  expandedBottomView() {
    return Expanded(
      flex: 6,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                monoVarifyText(),
                otpText(),
                mobText(),
                otpLayout(),
                verifyBtn(),
                resendText(),
              ],
            ),
          ),
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
      body: Stack(
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
      ),
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
            bottom: MediaQuery.of(context).viewInsets.bottom * 0.6,
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: white,
          child: Form(
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
                      monoVarifyText(),
                      otpText(),
                      mobText(),
                      otpLayout(),
                      verifyBtn(),
                      resendText(),
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
