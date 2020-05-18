import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/taxiPage/taxi.dart';
import 'package:virus_tracker/taxiPage/taxiService.dart';
import 'package:virus_tracker/taxiPage/taxiForm.dart';

class TaxiList extends StatefulWidget {
  @override
  State createState() => TaxiListState();
}

class TaxiListState extends State<TaxiList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Taxi> _taxilist = <Taxi>[];

  var updatePeriod;

  @override
  void initState() {
    super.initState();
    TaxiService().getTaxi();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _taxilist = globals.taxiList;
        // print(_taxilist);
      });
    });
    // updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('Taxi Record'),
            textAlign: TextAlign.center),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildTaxiList(),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_taxilist.isEmpty) {
      return null;
    } else {
      return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => TaxiForm()));
          });
    }
  }

  Widget _buildTaxiList() {
    if (_taxilist.isEmpty) {
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
                    Text(allTranslations.text('Add Taxi'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // color: Theme.of(context).accentColor,
                            // fontWeight: FontWeight.bold,
                            fontSize: 16.0)),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(
                      color: Theme.of(context).dividerColor, width: 3),
                ),
                onPressed: () {
                  print(allTranslations.locale);
                  print(Localizations.localeOf(context).toString());
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => TaxiForm()));
                }),
          ));
      // showMessage('There is currently no taxi in the list yet');
    } else {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 5),
        // padding: const EdgeInsets.all(16),
        itemCount: _taxilist.length,
        itemBuilder: (BuildContext _context, int i) {
          return _buildRow(_taxilist[i]);
        },
        separatorBuilder: (context, index) {
          return Divider(
            indent: 100,
            endIndent: 100,
          );
        },
      );
    }
  }

  Widget _buildRow(Taxi taxi) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      child: ListTile(
        // leading: _infectLevelIcon(taxi.infection_level),
        title: Text(
            '${taxi.plate} ${taxi.departure ?? ""} - ${taxi.destination ?? ""}'),
        subtitle: Text(
            '${DateFormat('MM/dd HH:mm').format(taxi.datetime_from)} - ${DateFormat('MM/dd HH:mm').format(taxi.datetime_to)}\n${taxi.note}'),
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
      key: ValueKey(taxi.local_id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, taxi) == true;
        }
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, Taxi taxi) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "${allTranslations.text('Do you want to delete Taxi')} ${taxi.plate}?"),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                TaxiService().deleteTaxi(taxi);
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
