library virus_tracker.globals;

import 'package:flutter/material.dart';





import 'package:virus_tracker/locationPage/location.dart';
import 'package:virus_tracker/thsrPage/thsr.dart';
import 'package:virus_tracker/trPage/tr.dart';
import 'package:virus_tracker/busPage/bus.dart';
import 'package:virus_tracker/metroPage/metro.dart';
import 'package:virus_tracker/taxiPage/taxi.dart';




String id_token;


List<THSR> thsrList = <THSR>[];
List<Map<String,String>> thsrFavList = <Map<String,String>>[];

List<TR> trList = <TR>[];
List<Map<String,String>> trFavList = <Map<String,String>>[];

List<Bus> busList = <Bus>[];
List<Map<String,String>> busFavList = <Map<String,String>>[];

List<Metro> taipeiMetroList = <Metro>[];
List<Map<String,String>> taipeiMetroFavList = <Map<String,String>>[];

List<Metro> kaohsiungMetroList = <Metro>[];
List<Map<String,String>> kaohsiungMetroFavList = <Map<String,String>>[];

List<Location> locationList = <Location>[];
List<Map<String,String>> locationFavList = <Map<String,String>>[];

List<Taxi> taxiList = <Taxi>[];
List<Map<String,String>> taxiFavList = <Map<String,String>>[];


ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF005164),
  scaffoldBackgroundColor: Color(0xFF05433E),
  dividerColor: Colors.white,
  indicatorColor: Color(0xFF00CCFF),
  buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary, buttonColor: Color(0xFF00FFCC)),
  fontFamily: 'jfOpen',
  inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.white),
      errorStyle: TextStyle(color: Colors.yellow)),
  errorColor: Colors.yellow,
);
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF6F6363),
  scaffoldBackgroundColor: Color(0xFFF2F2F2),
  dividerColor: Color(0xFF6F6363),
  accentColor: Color(0xFFFFC000),
  indicatorColor: Color(0xFFD8717C),
  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.primary,
    buttonColor: Color(0xFF6F6363),
  ),
  fontFamily: 'jfOpen',
  inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      errorStyle: TextStyle(color: Color(0xFFD8717C))),
  errorColor: Color(0xFFD8717C),
);

String language;
String theme;
bool delete21;
