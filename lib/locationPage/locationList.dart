import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  GoogleMapController mapController;
  String _darkMapStyle;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/dark_map_style.json').then((string) {
      _darkMapStyle = string;
    });
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
                builder: (BuildContext context) =>
                    LocationForm(null, null, null, null)));
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
      child: ListTile(
        // leading: _infectLevelIcon(location.infection_level),
        title: Text(location.location_name),
        subtitle: Text(
            '${DateFormat('MM/dd HH:mm').format(location.datetime_from)} - ${DateFormat('MM/dd HH:mm').format(location.datetime_to)}\n${location.note}'),
        onTap: () {
          _showInfoCard(location);
        },
      ),
      secondaryBackground: Container(
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete),
        ),
        color: Colors.red,
      ),
      background: Container(
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.edit),
        ),
        color: Colors.green,
      ),
      key: ValueKey(location.local_id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  LocationForm(null, null, null, location)));
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
                    builder: (BuildContext context) =>
                        LocationForm(null, null, null, null)));
              }),
        ));
  }

  void _showInfoCard(Location location) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Center(
            child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(15.0),
                        child: ListView(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: _build_map(location),
                            ),
                            ListTile(
                              title: Text(allTranslations.text('Location'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              subtitle: Text(
                                location.location_name,
                                style: TextStyle(fontSize: 20),
                              ),
                              leading: Icon(Icons.location_on),
                            ),
                            Divider(),
                            ListTile(
                              title: Text(allTranslations.text('Time Period'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              leading: Icon(Icons.access_time),
                              subtitle: Text(
                                '${DateFormat('yyyy/MM/dd HH:mm').format(location.datetime_from)} - ${DateFormat('yyyy/MM/dd HH:mm').format(location.datetime_to)}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            ListTile(
                              title: Text(allTranslations.text('Note'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              leading: Icon(Icons.edit),
                              subtitle: Text(
                                location.note == ''
                                    ? allTranslations.text('Empty')
                                    : location.note,
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))));
      },
    );
  }

  Widget _build_map(Location location) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 15,
      ),
      gestureRecognizers: Set()
        ..add(Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer()))
        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
        ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
        ..add(Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer())),
      myLocationEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        if (Theme.of(context).brightness == Brightness.dark) {
          mapController.setMapStyle(_darkMapStyle);
        }
      },
      markers: {
        Marker(
          markerId: MarkerId('0'),
          position: LatLng(location.latitude, location.longitude),
        )
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, Location location) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "${allTranslations.text('Do you want to delete')} ${location.location_name}?"),
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
