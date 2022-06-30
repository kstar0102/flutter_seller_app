import 'package:eshopmultivendor/Helper/ApiBaseHelper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'Session.dart';
import 'String.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
FirebaseMessaging messaging = FirebaseMessaging.instance;

class PushNotificationService {
  late BuildContext context;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  PushNotificationService({required this.context});

//==============================================================================
//============================= initialise =====================================

  Future initialise() async {
    iOSPermission();
    messaging.getToken().then(
      (token) async {
        if (CUR_USERID != null && CUR_USERID != "") _registerToken(token);
      },
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    final MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings();
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
      },
    );

//==============================================================================
//============================= onMessage ======================================
// when app in foreground (running state) (open)

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        var data = message.notification!;
        var title = data.title.toString();
        var body = data.body.toString();
        var type = message.data['type'];
        if (type == "commission") {
          generateSimpleNotication(title, body, type);
        }
      },
    );

//==============================================================================
//============================= onMessage ======================================
// when app in terminated state

    messaging.getInitialMessage().then(
      (RemoteMessage? message) async {
        bool back = await getPrefrenceBool(iSFROMBACK);
        if (message != null && back) {
          var type = message.data['type'] ?? '';
          var id = '';
          if (type == "commission") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          }
        }
      },
    );

//==============================================================================
//========================= onMessageOpenedApp =================================
// when app is background

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (message != null) {
          var type = message.data['type'] ?? '';
          if (type == "commission") {
            // try to add login or not condition here.
            // if login then redirect to home scren else login screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyApp(),
              ),
            );
          }
          setPrefrenceBool(iSFROMBACK, false);
        }
      },
    );
  }

//==============================================================================
//========================= iOSPermission ======================================
//done

  void iOSPermission() async {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

//==============================================================================
//========================= _registerToken =====================================

  void _registerToken(String? token) async {
    var parameter = {
      'user_id': CUR_USERID,
      FCMID: token,
    };
    apiBaseHelper.postAPICall(updateFcmApi, parameter).then(
          (getdata) async {},
          onError: (error) {},
        );
  }
}

//done above

//==============================================================================
//========================= myForgroundMessageHandler ==========================

Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
  await setPrefrenceBool(iSFROMBACK, true);
  bool back = await getPrefrenceBool(iSFROMBACK);
  return Future<void>.value();
}

//==============================================================================
//========================= generateSimpleNotication ===========================

Future<void> generateSimpleNotication(
    String title, String body, String type) async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    channelDescription: 'your channel description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  var iosDetail = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iosDetail);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: type,
  );
}

//==============================================================================
//==============================================================================
