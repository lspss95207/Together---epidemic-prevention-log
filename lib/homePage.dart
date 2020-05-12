import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;

import 'package:virus_tracker/locationPage/locationForm.dart';
// import 'package:virus_tracker/feedbackPage.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart' as globals;
import 'all_translations.dart';

import 'package:virus_tracker/locationPage/locationList.dart';
import 'package:virus_tracker/thsrPage/thsrList.dart';
import 'package:virus_tracker/trPage/trList.dart';
import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroList.dart';
import 'package:virus_tracker/metroPage/kaohsiungMetro/kaohsiungMetroList.dart';
import 'package:virus_tracker/metroPage/metroRegionPage.dart';
import 'package:virus_tracker/busPage/busList.dart';
import 'package:virus_tracker/taxiPage/taxiList.dart';
import 'package:virus_tracker/completeListPage.dart';
import 'package:virus_tracker/settingPage.dart';

class HomePage extends StatefulWidget {
  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;

  HomePageState() {
    // print(Localizations.localeOf(context));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // var buttonColor = Color.fromRGBO(0, 0xCC, 0xFF, 1);
  // var backgroundColor = Color.fromRGBO(0, 0x51, 0x64, 1);
  // var appbarColor = Color.fromRGBO(0, 0xFF, 0xCC, 1);

  // var buttonColor = Color.fromRGBO(0x00, 0xFF, 0xCC, 1);
  // var backgroundColor = Color.fromRGBO(0x00, 0x51, 0x64, 1);
  // var appbarColor = Color.fromRGBO(0x07, 0x61, 0x5B, 1);

  var buttonColor = Color.fromRGBO(5, 67, 62, 1);

  final pages = [
    LocationList(),
    THSRList(),
    TRList(),
    TaipeiMetroList(),
    BusList()
  ];
  //UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Stack(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(children: <Widget>[
                  SizedBox(height: 7),
                  Center(
                    child: Text(allTranslations.text('Together'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                          // fontFamily: 'Arial'
                        )),
                  ),
                ]),
                Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<String>(
                      onSelected: (val) async {
                        if (val == 'feedback') {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (BuildContext context) =>
                          //         FeedbackPage()));
                          Email email = Email(
                            body: '',
                            subject: '意見回覆',
                            recipients: ['togetherfightepidemic@gmail.com'],
                            isHTML: false,
                          );
                          String platformResponse;
                          try {
                            await FlutterEmailSender.send(email);
                            platformResponse = '傳送成功';
                            Navigator.pop(context);
                          } catch (error) {
                            platformResponse = error.toString();
                          }
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(platformResponse),
                          ));
                        } else if (val == 'completeList') {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  CompleteListPage()));
                        } else if (val == 'setting') {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SettingPage()));
                        } else if (val == 'privacy') {
                          const url =
                              'https://together-epidemic-pr.flycricket.io/privacy.html';
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        } else if (val == 'facebook') {
                          // const url =
                          //     'https://www.facebook.com/%E4%B8%80%E8%B5%B7-%E5%BF%AB%E9%80%9F%E7%B4%80%E9%8C%84%E8%A1%8C%E8%B9%A4%E6%88%B0%E5%8B%9Dcovid-19-115060663529087';
                          // if (await canLaunch(url)) {
                          //   await launch(url);
                          // } else {
                          //   throw 'Could not launch $url';
                          // }
                        } else if (val == 'instagram') {
                          // const url =
                          //     'https://www.instagram.com/2020.fightcovid19/';
                          // if (await canLaunch(url)) {
                          //   await launch(url);
                          // } else {
                          //   throw 'Could not launch $url';
                          // }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'completeList',
                          child: Text(allTranslations.text('Complete List')),
                        ),
                        PopupMenuItem<String>(
                          value: 'setting',
                          child: Text(allTranslations.text('Setting')),
                        ),
                        PopupMenuItem<String>(
                          value: 'feedback',
                          child: Text(allTranslations.text('Feedback')),
                        ),
                        PopupMenuItem<String>(
                          value: 'privacy',
                          child: Text(allTranslations.text('Privacy Policy')),
                        ),
                        // PopupMenuItem<String>(
                        //   value: 'tutorial',
                        //   child: Text(allTranslations.text('Tutorial')),
                        // ),
                        // PopupMenuItem<String>(
                        //   value: 'facebook',
                        //   child: Row(children: <Widget>[
                        //     Image(
                        //         image: AssetImage(
                        //             (Theme.of(context).brightness ==
                        //                     Brightness.dark)
                        //                 ? 'assets/fb_night.png'
                        //                 : 'assets/fb_day.png'),
                        //         height: 20.0),
                        //     Padding(
                        //         padding: const EdgeInsets.only(left: 15),
                        //         child: Text('Facebook',
                        //             style: TextStyle(
                        //                 color: (Theme.of(context).brightness ==
                        //                         Brightness.dark)
                        //                     ? Theme.of(context).indicatorColor
                        //                     : Theme.of(context).primaryColor))),
                        //   ]),
                        // ),
                        // PopupMenuItem<String>(
                        //   value: 'instagram',
                        //   child: Row(children: <Widget>[
                        //     Image(
                        //         image: AssetImage(
                        //             (Theme.of(context).brightness ==
                        //                     Brightness.dark)
                        //                 ? 'assets/IG_night.png'
                        //                 : 'assets/IG_day.png'),
                        //         height: 20.0),
                        //     Padding(
                        //         padding: const EdgeInsets.only(left: 15),
                        //         child: Text('Instagram',
                        //             style: TextStyle(
                        //                 color: (Theme.of(context).brightness ==
                        //                         Brightness.dark)
                        //                     ? Theme.of(context).accentColor
                        //                     : Theme.of(context).primaryColor))),
                        //   ]),
                        // ),
                      ],
                    )),
              ]),
        ),
        // backgroundColor: backgroundColor,
        body: Container(
            child: ListView(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _selectButton(
                          allTranslations.text('Location'),
                          Icons.location_on,
                          LocationList(),
                          Theme.of(context).indicatorColor),
                      _selectButton(
                          allTranslations.text('Metro'),
                          Icons.directions_subway,
                          MetroRegionPage(),
                          Theme.of(context).accentColor),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _selectButton(allTranslations.text('Taiwan Railways'),
                          Icons.train, TRList(), Theme.of(context).accentColor),
                      _selectButton(
                          allTranslations.text('Bus'),
                          Icons.directions_bus,
                          BusList(),
                          Theme.of(context).accentColor),
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _selectButton(
                            allTranslations.text('THSR'),
                            Icons.directions_railway,
                            THSRList(),
                            Theme.of(context).accentColor),
                        _selectButton(
                            allTranslations.text('Taxi'),
                            Icons.local_taxi,
                            TaxiList(),
                            Theme.of(context).accentColor),
                      ],
                    ))
              ],
            ),
          ],
        )));
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
                      // color: Theme.of(context).accentColor,
                      // fontWeight: FontWeight.bold,
                      fontSize: 16.0)),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Theme.of(context).dividerColor, width: 3),
          ),
          onPressed: () {
            print(allTranslations.locale);
            print(Localizations.localeOf(context).toString());
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => navTo));
          }),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Virus Tracker'),
  //     ),
  //     drawer: Drawer(
  //         child: ListView(
  //       children: <Widget>[
  //         ListTile(
  //           leading: Icon(Icons.location_on),
  //           title: Text('Locations'),
  //           onTap: () {
  //             _onItemClick(0);
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.directions_railway),
  //           title: Text('Taiwan High Speed Rail'),
  //           onTap: () {
  //             _onItemClick(1);
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.train),
  //           title: Text('Taiwan Railways'),
  //           onTap: () {
  //             _onItemClick(2);
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.train),
  //           title: Text('Taipei Metro'),
  //           onTap: () {
  //             _onItemClick(3);
  //           },
  //         ),
  //         ListTile(
  //           leading: Icon(Icons.directions_bus),
  //           title: Text('Bus'),
  //           onTap: () {
  //             _onItemClick(4);
  //           },
  //         ),
  //       ],
  //     )),
  //     body: pages[_currentIndex],
  //   );
  // }

  // void _onItemClick(int index) {
  //   setState(() {
  //     _currentIndex = index;
  //     Navigator.of(context).pop();
  //   });
  // }

}
