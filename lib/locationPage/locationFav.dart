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

import 'package:virus_tracker/locationPage/location.dart';
import 'package:virus_tracker/locationPage/locationService.dart';
import 'package:virus_tracker/locationPage/locationForm.dart';

class LocationFav extends StatefulWidget {
  @override
  State createState() => LocationFavState();
}

class LocationFavState extends State<LocationFav> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _locationfavlist = <Map<String, String>>[];

  var updatePeriod;

  @override
  void initState() {
    // super.initState();
    // updateList();
    LocationService().getFavorite();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _locationfavlist = globals.locationFavList;
        // print(_locationlist);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('Favorite Locations'), textAlign: TextAlign.center),
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
    if (_locationfavlist.isEmpty) {
      // showMessage('There is currently no location in the list yet');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _locationfavlist.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_locationfavlist[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(var favLocations) {
    return Dismissible(
      direction: DismissDirection.endToStart,      child: ListTile(
        title: Text(favLocations['location_name']??''),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => LocationForm(
                  favLocations['latitude'],
                  favLocations['longitude'],
                  favLocations['location_name'])));
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
      key: ValueKey(favLocations['location_name'] +
          favLocations['latitude'] +
          favLocations['longitude']),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, favLocations) == true;
        }
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, var favLocations) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('${allTranslations.text('Do you want to delete')} ${favLocations['location_name']}?'),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                // LocationService().deleteLocation(location);
                LocationService().deleteFavorite(favLocations);
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
