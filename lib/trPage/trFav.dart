import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' show json;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/trPage/tr.dart';
import 'package:virus_tracker/trPage/trService.dart';
import 'package:virus_tracker/trPage/trForm.dart';

class TRFav extends StatefulWidget {
  @override
  State createState() => TRFavState();
}

class TRFavState extends State<TRFav> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _trfavlist = <Map<String, String>>[];

  var updatePeriod;

  @override
  void initState() {
    // super.initState();
    // updateList();
    TRService().getFavorite();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _trfavlist = globals.trFavList;
        // print(_trlist);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('Favorite Taiwan Railway Stations'),
            textAlign: TextAlign.center),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildFavList(),
      ),
    );
  }

  // Future<void> updateList() async {
  //   await locationService.getLocations().then((val) => setState(() {
  //         updatePeriod.cancel();
  //         if (val != null) {
  //           globals.locationList = val;
  //           _locations = globals.locationList;
  //           updatePeriod = Timer.periodic(Duration(seconds: 60), (timer) {
  //             updateList();
  //           });
  //         } else {
  //           updatePeriod = Timer.periodic(Duration(seconds: 1), (timer) {
  //             updateList();
  //           });
  //         }
  //       }));
  // }

  Widget _buildFavList() {
    if (_trfavlist.isEmpty) {
      // showMessage('There is currently no location in the list yet');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _trfavlist.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_trfavlist[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(var favStations) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      child: ListTile(
        title:
            Text(favStations['departure'] + ' - ' + favStations['destination']),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => TRForm(
                  favStations['departure'], favStations['destination'])));
        },
      ),
      background: Container(
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete),
        ),
        color: Colors.red,
      ),
      key: ValueKey(
          favStations['departure'] + ' - ' + favStations['destination']),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, favStations) == true;
        }
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, var favStations) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "${allTranslations.text('Do you want to delete')} ${favStations['departure'] + ' - ' + favStations['destination']}?"),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                // TRService().deleteTR(tr);
                TRService().deleteFavorite(favStations);
                Navigator.pop(context, true); // showDialog() returns true
              },
            ),
            FlatButton(
              child: Text(allTranslations.text('Cancel')),
              onPressed: () {
                Navigator.pop(context, false); // showDialog() returns false
              },
            ),
          ],
        );
      },
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
