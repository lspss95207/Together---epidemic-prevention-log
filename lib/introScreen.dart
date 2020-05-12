import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'all_translations.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:virus_tracker/globals.dart' as globals;

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    allTranslations.init();
    Timer(Duration(seconds: 5), () {
      _setLanguage();
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(0, 81, 100, 1)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Image(image: AssetImage('./assets/introAnimation.gif')),
              ),
              // CircularProgressIndicator(),
            ],
          )
        ],
      ),
    );
  }

  void _setLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String language = await prefs.getString('language_setting') ?? 'System';
    String theme = await prefs.getString('theme_setting') ?? 'Dark';
    bool delete21 = await prefs.getBool('delete21_setting') ?? false;

    globals.language = language;
    globals.theme = theme;
    globals.delete21 = delete21;


    if (language == 'System') {
      await allTranslations
          .setNewLanguage(Localizations.localeOf(context).toString());
    } else {
      await allTranslations.setNewLanguage(language);
    }

    if (theme == 'System') {
      theme = (MediaQuery.of(context).platformBrightness == Brightness.dark)
          ? 'Dark'
          : 'Light';
    }
    if (theme == 'Dark') {
      DynamicTheme.of(context).setThemeData(globals.darkTheme);
    } else if (theme == 'Light') {
      DynamicTheme.of(context).setThemeData(globals.lightTheme);
    }
  }
}
