import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:convert' show json;

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;

import 'package:virus_tracker/busPage/bus.dart';
import 'package:virus_tracker/busPage/busService.dart';
import 'package:virus_tracker/busPage/busForm.dart';

import 'package:virus_tracker/all_translations.dart';

class BusFav extends StatefulWidget {
  @override
  State createState() => BusFavState();
}

class BusFavState extends State<BusFav> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _busfavlist = <Map<String, String>>[];

  var updatePeriod;

  @override
  void initState() {
    super.initState();
    BusService().getFavorite();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _busfavlist = globals.busFavList;
        // print(_buslist);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('Favorite Bus Routes'), textAlign: TextAlign.center),
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
    if (_busfavlist.isEmpty) {
      // showMessage('There is currently no location in the list yet');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _busfavlist.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_busfavlist[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(var favRoute) {
    return Dismissible(
      direction: DismissDirection.endToStart,      child: ListTile(
        title: Text(favRoute['city'] + ': ' + favRoute['route']),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  BusForm(favRoute['city'], favRoute['route'])));
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
      key: ValueKey(favRoute['city'] + ': ' + favRoute['route']),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, favRoute) == true;
        }
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, var favRoute) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "${allTranslations.text('Do you want to delete')} ${favRoute['city'] + ': ' + favRoute['route']}?"),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                // BusService().deleteBus(bus);
                BusService().deleteFavorite(favRoute);
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
