import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:dynamic_theme/theme_switcher_widgets.dart';

import 'package:virus_tracker/globals.dart' as globals;

import './homePage.dart';
import './introScreen.dart';
import './thsrPage/thsrList.dart';
import './trPage/trList.dart';
import './busPage/busList.dart';
import './metroPage/taipeiMetro/taipeiMetroList.dart';
import './metroPage/kaohsiungMetro/kaohsiungMetroList.dart';
import './taxiPage/taxiList.dart';
import './locationPage/locationList.dart';
// import './feedbackPage.dart';
import './completeListPage.dart';
import 'settingPage.dart';

import 'all_translations.dart';

var routes = <String, WidgetBuilder>{
  '/home': (BuildContext context) => HomePage(),
  '/intro': (BuildContext context) => IntroScreen(),
  '/THSRList': (BuildContext context) => THSRList(),
  '/TRList': (BuildContext context) => TRList(),
  '/TaipeiMetroList': (BuildContext context) => TaipeiMetroList(),
  '/KaohsiungMetroList': (BuildContext context) => KaohsiungMetroList(),
  '/BusList': (BuildContext context) => BusList(),
  '/TaxiList': (BuildContext context) => TaxiList(),
  '/LocationList': (BuildContext context) => LocationList(),
  // '/FeedbackPage': (BuildContext context) => FeedbackPage(),
  '/CompleteListPage': (BuildContext context) => CompleteListPage(),
  '/SettingPage': (BuildContext context) => SettingPage(),
};

void main() {
  runApp(DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness){
        if(brightness == Brightness.light){
          return globals.lightTheme;
        }else if(brightness == Brightness.dark){
          return globals.darkTheme;
        }
      },
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          theme: theme,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: allTranslations.supportedLocales(),
          title: '一起',
          home: IntroScreen(),
          routes: routes,
        );
      }));
}


