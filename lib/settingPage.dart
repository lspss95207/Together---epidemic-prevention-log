import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/thsrPage/thsr.dart';
import 'package:virus_tracker/thsrPage/thsrService.dart';
import 'package:virus_tracker/thsrPage/thsrForm.dart';
import 'package:virus_tracker/thsrPage/thsrFav.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  @override
  State createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _language;
  String _theme;
  bool _delete21;

  @override
  void initState() {
    super.initState();
    _delete21 = globals.delete21;
    _language = globals.language;
    _theme = globals.theme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
          },
        ),
        title:
            Text(allTranslations.text('Setting'), textAlign: TextAlign.center),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildSettingList(),
      ),
    );
  }

  Widget _buildSettingList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 5),
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 2)),
          child: ListTile(
            title: Text(allTranslations.text('Language')),
            subtitle: DropdownButton<String>(
              value: _language,
              onChanged: (String newValue) async {
                setState(() {
                  _language = newValue;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('language_setting', _language);
                String language;
                if (_language == 'System') {
                  language = Localizations.localeOf(context).toString();
                } else {
                  language = _language;
                }
                await allTranslations.setNewLanguage(language);
                setState(() {
                  globals.language = _language;
                  Navigator.pushReplacementNamed(context, '/SettingPage');
                });
              },
              items: (<String>['System'] +
                      allTranslations.supportedLanguages.keys.toList())
                  .map<DropdownMenuItem<String>>((String value) {
                if (value == 'System') {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(allTranslations.text(value)),
                  );
                } else {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(allTranslations.supportedLanguages[value]),
                  );
                }
              }).toList(),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Theme.of(context).dividerColor, width: 2)),
          child: ListTile(
            title: Text(allTranslations.text('Theme')),
            subtitle: DropdownButton<String>(
              value: _theme,
              onChanged: (String newValue) async {
                setState(() {
                  _theme = newValue;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme_setting', _theme);
                String theme;
                if (_theme == 'System') {
                  theme = (MediaQuery.of(context).platformBrightness ==
                          Brightness.dark)
                      ? 'Dark'
                      : 'Light';
                } else {
                  theme = _theme;
                }
                if (theme == 'Dark') {
                  DynamicTheme.of(context).setThemeData(globals.darkTheme);
                } else if (theme == 'Light') {
                  DynamicTheme.of(context).setThemeData(globals.lightTheme);
                }
                globals.theme = _theme;
              },
              items: (<String>['System', 'Light', 'Dark']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(allTranslations.text(value)),
                );
              }).toList()),
            ),
          ),
        ),
        Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Theme.of(context).dividerColor, width: 2)),
            child: SwitchListTile(
              title: Text(allTranslations.text('Delete after 21 days?')),
              value: _delete21,
              onChanged: (bool value) async {
                if (value) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(allTranslations.text(
                            'Caution! The data submitted before the past 21 days will be deleted automatically. Are you sure?')),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(allTranslations.text('Confirm')),
                            onPressed: () {
                              setState(() {
                                _delete21 = value;
                                globals.delete21 = value;
                              });
                              Navigator.pop(
                                  context, true); // showDialog() returns true
                            },
                          ),
                          FlatButton(
                            child: Text(allTranslations.text('Cancel')),
                            onPressed: () {
                              Navigator.pop(
                                  context, false); // showDialog() returns false
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  setState(() {
                    _delete21 = value;
                    globals.delete21 = value;
                  });
                }

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('delete21_setting', value);
                globals.delete21 = _delete21;
              },
              secondary: const Icon(Icons.delete),
            )),
      ],
    );
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        )));
  }
}
