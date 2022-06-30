import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:eshopmultivendor/Helper/AppBtn.dart';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/ContainerDesing.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SellerRegister extends StatefulWidget {
  const SellerRegister({Key? key}) : super(key: key);

  @override
  _SellerRegisterState createState() => _SellerRegisterState();
}

class _SellerRegisterState extends State<SellerRegister>
    with TickerProviderStateMixin {
//==============================================================================
//============================= Variables Declaration ==========================

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobilenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController storeController = TextEditingController();
  TextEditingController storeUrlController = TextEditingController();
  TextEditingController storeDescriptionController = TextEditingController();
  TextEditingController taxNameController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  FocusNode? nameFocus,
      emailFocus,
      passFocus,
      confirmPassFocus,
      addressFocus,
      storeFocus,
      storeUrlFocus,
      storeDescriptionFocus,
      taxNameFocus,
      taxNumberFocus,
      panNumberFocus,
      accountNumberFocus,
      accountNameFocus,
      bankCodeFocus,
      bankNameFocus,
      monumberFocus = FocusNode();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  final mobileController = TextEditingController();
  bool _isNetworkAvail = true;
  var addressProfFile, nationalIdentityCardFile, storeLogoFile;
  String? mobile,
      name,
      email,
      password,
      confirmpassword,
      address,
      addressproof,
      nationalidentitycard,
      storename,
      storelogo,
      storeurl,
      storedescription,
      taxname,
      taxnumber,
      pannumber,
      accountnumber,
      accountname,
      bankcode,
      bankname;

//==============================================================================
//============================= INIT Method ====================================

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
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
//==============================================================================
//============================= For API Call ==================================

  Future<void> sellerRegisterAPI() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var request = http.MultipartRequest("POST", registerApi);
        request.headers.addAll(headers);
        request.fields[Name] = name!;
        request.fields[Mobile] = mobile!;
        request.fields[Password] = password!;
        request.fields[Email] = email!;
        request.fields[ConfirmPassword] = confirmpassword!;
        request.fields[Address] = address!;
        // address proff
        if (addressProfFile != null) {
          final mimeType = lookupMimeType(addressProfFile.path);
          var extension = mimeType!.split("/");
          var addproff = await http.MultipartFile.fromPath(
            AddressProof,
            addressProfFile.path,
            contentType: new MediaType('image', '${extension[1]}'),
          );
          request.files.add(addproff);
        } else {
          setSnackbar(
            getTranslated(context, "please upload address prof")!,
          );
        }
        // nationalIdentityCard
        if (nationalIdentityCardFile != null) {
          final mimeType = lookupMimeType(nationalIdentityCardFile.path);
          var extension = mimeType!.split("/");
          var nationalproff = await http.MultipartFile.fromPath(
            NationalIdentityCard,
            nationalIdentityCardFile.path,
            contentType: new MediaType('image', '${extension[1]}'),
          );
          request.files.add(nationalproff);
        } else {
          setSnackbar(
            getTranslated(context, "please upload natinal Identity Card")!,
          );
        }
        // store Logo File
        if (storeLogoFile != null) {
          final mimeType = lookupMimeType(storeLogoFile.path);
          var extension = mimeType!.split("/");
          var storelogo = await http.MultipartFile.fromPath(
            "store_logo",
            storeLogoFile.path,
            contentType: new MediaType('image', '${extension[1]}'),
          );
          request.files.add(storelogo);
        } else {
          setSnackbar(
            getTranslated(context, "please upload store logo")!,
          );
        }
        request.fields[StoreName] = storename!;
        request.fields[Storeurl] = storeurl!;
        request.fields[storeDescription] = storedescription!;
        request.fields[tax_name] = taxname!;
        request.fields[tax_number] = taxnumber!;
        request.fields[pan_number] = pannumber!;
        request.fields[account_number] = accountnumber!;
        request.fields[account_name] = accountname!;
        request.fields[bank_name] = bankname!;
        request.fields["bank_code"] = bankcode!;
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];
        if (!error) {
          ShowMsgDialog(msg!);
          await buttonController!.reverse();
        } else {
          await buttonController!.reverse();
          //    setSnackbar(msg!);
          ShowMsgDialog(msg!);
        }
      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, 'somethingMSg')!,
        );
      }
    } else {
      if (mounted) {
        setState(
          () {
            _isNetworkAvail = false;
          },
        );
      }
    }
  }

  ShowMsgDialog(String msg) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStater) {
            //    taxesState = setStater;
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            msg,
                            style: Theme.of(this.context)
                                .textTheme
                                .subtitle1!
                                .copyWith(color: fontColor),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

//==============================================================================
//============================= For Animation ==================================

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

//==============================================================================
//============================= Network Checking ===============================

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      sellerRegisterAPI();
    } else {
      Future.delayed(
        Duration(seconds: 2),
      ).then(
        (_) async {
          await buttonController!.reverse();
          setState(
            () {
              _isNetworkAvail = false;
            },
          );
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

//==============================================================================
//============================= Dispose Method =================================

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: fontColor,
          ),
        ),
        duration: Duration(
          milliseconds: 3000,
        ),
        backgroundColor: lightWhite,
        elevation: 1.0,
      ),
    );
  }

//==============================================================================
//============================= No Internet Widget =============================

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: kToolbarHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
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
                            builder: (BuildContext context) => super.widget),
                      );
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

//==============================================================================
//============================= Build Method ===================================

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
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
      ),
    );
  }

//==============================================================================
//============================= Login Container widget =========================

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
            bottom: MediaQuery.of(context).viewInsets.bottom * 0.8,
          ),
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
                    maxHeight: MediaQuery.of(context).size.height * 5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      setSignInLabel(),
                      setName(),
                      setEmail(),
                      setMobileNo(),
                      setPass(),
                      confirmPassword(),
                      setaddress(),
                      storeName(),
                      storeUrl(),
                      setStoreDescription(),
                      taxName(),
                      taxNumber(),
                      panNumber(),
                      accountNumber(),
                      accountName(),
                      bankCode(),
                      bankName(),
                      uploadStoreLogo(getTranslated(context, "Store Logo")!, 1),
                      selectedMainImageShow(addressProfFile),
                      uploadStoreLogo(
                          getTranslated(context, "National Identity Card")!, 2),
                      selectedMainImageShow(nationalIdentityCardFile),
                      uploadStoreLogo(
                          getTranslated(context, "Address Proof")!, 3),
                      selectedMainImageShow(storeLogoFile),
                      loginBtn(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
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

  uploadStoreLogo(String title, int number) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
          ),
          InkWell(
            child: Container(
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(5),
              ),
              width: 90,
              height: 40,
              child: Center(
                child: Text(
                  getTranslated(context, "Upload")!,
                  style: TextStyle(
                    color: white,
                  ),
                ),
              ),
            ),
            onTap: () {
              mainImageFromGallery(number);
            },
          ),
        ],
      ),
    );
  }

  mainImageFromGallery(int number) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'eps'],
    );
    if (result != null) {
      File image = File(result.files.single.path!);
      if (image != null) {
        setState(() {
          if (number == 1) {
            addressProfFile = image;
          }
          if (number == 2) {
            nationalIdentityCardFile = image;
          }
          if (number == 3) {
            storeLogoFile = image;
          }
        });
      }
    } else {
      // User canceled the picker
    }
  }

  selectedMainImageShow(File? name) {
    return name == null
        ? Container()
        : Container(
            child: Image.file(
              name,
              width: 100,
              height: 100,
            ),
          );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, "Seller Registration")!,
          style: const TextStyle(
            color: primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  setName() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(nameFocus);
        },
        keyboardType: TextInputType.text,
        controller: nameController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          name = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.person,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "Name")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  bankCode() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(bankCodeFocus);
        },
        keyboardType: TextInputType.text,
        controller: bankCodeController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: bankCodeFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          bankcode = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.format_list_numbered,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "BankCode")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  bankName() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(bankNameFocus);
        },
        keyboardType: TextInputType.text,
        controller: bankNameController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: bankNameFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          bankname = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.account_balance,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "BankName")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  panNumber() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(panNumberFocus);
        },
        keyboardType: TextInputType.text,
        controller: panNumberController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: panNumberFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          pannumber = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.credit_card,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "PanNumber")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  accountNumber() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(accountNumberFocus);
        },
        keyboardType: TextInputType.number,
        controller: accountNumberController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: accountNumberFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          accountnumber = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.account_box_outlined,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "AccountNumber")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  accountName() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(accountNameFocus);
        },
        keyboardType: TextInputType.text,
        controller: accountNameController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: accountNameFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          accountname = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.account_box_rounded,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "AccountName")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  taxName() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(taxNameFocus);
        },
        keyboardType: TextInputType.text,
        controller: taxNameController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: taxNameFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          taxname = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.person,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "TaxName"),
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  taxNumber() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(taxNumberFocus);
        },
        keyboardType: TextInputType.text,
        controller: taxNumberController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: taxNameFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          taxnumber = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.format_list_numbered_outlined,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "TaxNumber")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setStoreDescription() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(storeDescriptionFocus);
        },
        keyboardType: TextInputType.text,
        controller: storeDescriptionController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: storeDescriptionFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          storedescription = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.description,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "Store Description")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  storeUrl() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(storeUrlFocus);
        },
        keyboardType: TextInputType.text,
        controller: storeUrlController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: storeUrlFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          storeurl = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.link,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "StoreURL")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  storeName() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(storeFocus);
        },
        keyboardType: TextInputType.text,
        controller: storeController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: storeFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          storename = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.store,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "StoreName")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setaddress() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(addressFocus);
        },
        keyboardType: TextInputType.text,
        controller: addressController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: addressFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateThisFieldRequered(val!, context),
        onSaved: (String? value) {
          address = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.location_city,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "Addresh")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setEmail() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(emailFocus);
        },
        keyboardType: TextInputType.text,
        controller: emailController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateMob(val!, context),
        onSaved: (String? value) {
          email = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.email,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "E-mail")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setMobileNo() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(monumberFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: monumberFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
        validator: (val) => validateMob(val!, context),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.phone_android,
            color: lightBlack2,
            size: 20,
          ),
          hintText: getTranslated(context, "Mobile Number")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                color: lightBlack2,
                fontWeight: FontWeight.normal,
              ),
          filled: true,
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  setPass() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        controller: passwordController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: passFocus,
        textInputAction: TextInputAction.next,
        validator: (val) => validatePass(val!, context),
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
          ),
          hintText: getTranslated(context, "PASSHINT_LBL"),
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2!
              .copyWith(color: lightBlack2, fontWeight: FontWeight.normal),
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          suffixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  confirmPassword() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(confirmPassFocus);
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        controller: confirmPasswordController,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: confirmPassFocus,
        textInputAction: TextInputAction.next,
        validator: (val) => validatePass(val!, context),
        onSaved: (String? value) {
          confirmpassword = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: SvgPicture.asset(
            "assets/images/password.svg",
          ),
          hintText: getTranslated(context, "CONFIRMPASSHINT_LBL")!,
          hintStyle: Theme.of(this.context)
              .textTheme
              .subtitle2!
              .copyWith(color: lightBlack2, fontWeight: FontWeight.normal),
          fillColor: white,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          suffixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      title: getTranslated(context, "Apply Now")!,
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
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
