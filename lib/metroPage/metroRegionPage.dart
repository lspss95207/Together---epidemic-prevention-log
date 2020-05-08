import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:virus_tracker/locationPage/locationForm.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/locationPage/locationList.dart';
import 'package:virus_tracker/thsrPage/thsrList.dart';
import 'package:virus_tracker/trPage/trList.dart';
import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroList.dart';
import 'package:virus_tracker/metroPage/kaohsiungMetro/kaohsiungMetroList.dart';
import 'package:virus_tracker/busPage/busList.dart';

class MetroRegionPage extends StatefulWidget {
  @override
  State createState() => MetroRegionPageState();
}

class MetroRegionPageState extends State<MetroRegionPage> {

  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Metro')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _selectButton(allTranslations.text('Taipei Metro'), Icons.location_on,
                    TaipeiMetroList(), Theme.of(context).accentColor)
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _selectButton(allTranslations.text('Kaohsiung Metro'), Icons.location_on,
                    KaohsiungMetroList(), Theme.of(context).accentColor)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectButton(
      String title, IconData icon, Widget navTo, Color icon_color) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.width * 0.4,
      child: RaisedButton(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(icon,
                  size: MediaQuery.of(context).size.width * 0.15,
                  color: icon_color),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      // color: Theme.of(context).dividerColor,
                      // fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Theme.of(context).dividerColor, width: 3),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => navTo));
          }),
    );
  }
}
