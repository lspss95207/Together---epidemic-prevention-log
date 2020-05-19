import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/locationPage/location.dart';
import 'package:virus_tracker/locationPage/locationService.dart';
import 'package:virus_tracker/locationPage/locationForm.dart';
import 'package:virus_tracker/locationPage/locationFav.dart';

class LocationList extends StatefulWidget {
  @override
  State createState() => LocationListState();
}

class LocationListState extends State<LocationList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Location> _locationlist = <Location>[];

  var updatePeriod;

  @override
  void initState() {
    super.initState();
    LocationService().getLocation();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _locationlist = globals.locationList;
        // print(_locationlist);
      });
    });
    // updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(allTranslations.text('Location Record'),
              textAlign: TextAlign.center),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: _buildLocationList(),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        
        // SpeedDial(
        //   animatedIcon: AnimatedIcons.menu_close,
        //   animatedIconTheme: IconThemeData(size: 22.0),
        //   // child: Icon(Icons.add),
        //   curve: Curves.bounceIn,
        //   children: [
        //     SpeedDialChild(
        //       child: Icon(Icons.add, color: Colors.white),
        //       backgroundColor: Colors.deepOrange,
        //       onTap: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //             builder: (BuildContext context) =>
        //                 LocationForm(null, null, null)));
        //       },
        //       label: '新增紀錄',
        //       labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //       labelBackgroundColor: Colors.deepOrangeAccent,
        //     ),
        //     SpeedDialChild(
        //       child: Icon(Icons.brush, color: Colors.white),
        //       backgroundColor: Colors.green,
        //       onTap: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //             builder: (BuildContext context) => LocationFav()));
        //       },
        //       label: '常用地點',
        //       labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //       labelBackgroundColor: Colors.green,
        //     ),
        //   ],
        // )
        );
  }



  Widget _buildFloatingActionButton() {
    if (_locationlist.isEmpty) {
      return null;
    } else {
      return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => LocationForm(null,null,null)));
          });
    }
  }
  Widget _buildLocationList() {
    if (_locationlist.isEmpty) {
      return _buildCenterAddButton();
      // showMessage('There is currently no location in the list yet');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _locationlist.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_locationlist[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(Location location) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      child: ListTile(
        // leading: _infectLevelIcon(location.infection_level),
        title: Text(location.location_name),
        subtitle: Text('${DateFormat('MM/dd HH:mm').format(location.datetime_from)} - ${DateFormat('MM/dd HH:mm').format(location.datetime_to)}\n${location.note}'),
        onTap: null,
      ),
      background: Container(
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete),
        ),
        color: Colors.red,
      ),
      // secondaryBackground: Container(
      //   padding: EdgeInsets.all(10.0),
      //   child: Align(
      //     alignment: Alignment.centerLeft,
      //     child: Icon(Icons.edit),
      //   ),
      //   color: Colors.green,
      // ),
      key: ValueKey(location.local_id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, location) == true;
        }
      },
    );
  }

  Widget _buildCenterAddButton() {
    return Container(
        alignment: Alignment.center,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
          child: RaisedButton(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    Icons.add,
                    size: MediaQuery.of(context).size.width * 0.15,
                  ),
                  Text(allTranslations.text('Add Location'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          // color: Theme.of(context).accentColor,
                          // fontWeight: FontWeight.bold,
                          fontSize: 16.0)),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side:
                    BorderSide(color: Theme.of(context).dividerColor, width: 3),
              ),
              onPressed: () {
                print(allTranslations.locale);
                print(Localizations.localeOf(context).toString());
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => LocationForm(null,null,null)));
              }),
        ));
  }

  Future<bool> _deleteCheck(BuildContext context, Location location) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("${allTranslations.text('Do you want to delete')} ${location.location_name}?"),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                LocationService().deleteLocation(location);
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

  Icon _infectLevelIcon(infect_level) {
    Color levelColor;
    if (infect_level == 3) {
      levelColor = Colors.red;
    } else if (infect_level == 2) {
      levelColor = Colors.orange;
    } else if (infect_level == 1) {
      levelColor = Colors.yellow;
    } else {
      levelColor = Colors.green;
    }
    return Icon(Icons.brightness_1, color: levelColor);
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
