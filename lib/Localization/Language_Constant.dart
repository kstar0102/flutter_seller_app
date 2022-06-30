import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

const String LAGUAGE_CODE = 'languageCode';

// Global Language Variable
String? languageFlag;

//languages code
const String ENGLISH = 'en';
const String HINDI = 'hi';
const String CHINESE = 'zh';
const String SPANISH = 'es';
const String ARABIC = 'ar';
const String RUSSIAN = 'ru';
const String JAPANESE = 'ja';
const String DEUTSCH = 'de';

Locale? loc;
int lang = 0;
Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  languageFlag = languageCode;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');
    case HINDI:
      return Locale(HINDI, "IN");
    case CHINESE:
      return Locale(CHINESE, "CN");
    case SPANISH:
      return Locale(SPANISH, "ES");
    case ARABIC:
      return Locale(ARABIC, "DZ");
    case RUSSIAN:
      return Locale(RUSSIAN, "RU");
    case JAPANESE:
      return Locale(JAPANESE, "JP");
    case DEUTSCH:
      return Locale(DEUTSCH, "DE");
    default:
      return Locale(ENGLISH, 'US');
  }
}

void changeLanguage(BuildContext context, String language) async {
  languageFlag = language;
  Locale loc = await setLocale(language);
  MyApp.setLocale(context, loc);
}
