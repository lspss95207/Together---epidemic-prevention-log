import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/thsrPage/thsr.dart';
import 'package:virus_tracker/thsrPage/thsrService.dart';
import 'package:virus_tracker/thsrPage/thsrForm.dart';
import 'package:virus_tracker/thsrPage/thsrFav.dart';

class THSRList extends StatefulWidget {
  @override
  State createState() => THSRListState();
}

class THSRListState extends State<THSRList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<THSR> _thsrlist = <THSR>[];

  var updatePeriod;

  @override
  void initState() {
    super.initState();
    THSRService().getTHSR();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _thsrlist = globals.thsrList;
        // print(_thsrlist);
      });
    });
    // updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('THSR Record'),
            textAlign: TextAlign.center),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildTHSRList(),
      ),

      floatingActionButton: _buildFloatingActionButton(),

      // SpeedDial(
      //   animatedIcon: AnimatedIcons.menu_close,
      //   animatedIconTheme: IconThemeData(size: 22.0),
      //   // child: Icon(Icons.add),
      //   curve: Curves.bounceIn,
      //   overlayOpacity: 0.3,
      //   children: [
      //     SpeedDialChild(
      //       child: Icon(Icons.add, color: Colors.white),
      //       backgroundColor: Colors.deepOrange,
      //       onTap: () {
      //         Navigator.of(context).push(MaterialPageRoute(
      //             builder: (BuildContext context) => THSRForm(null, null)));
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
      //             builder: (BuildContext context) => THSRFav()));
      //       },
      //       label: '常用起訖站',
      //       labelStyle: TextStyle(fontWeight: FontWeight.w500),
      //       labelBackgroundColor: Colors.green,
      //     ),
      //   ],
      // )
    );
  }

  Widget _buildFloatingActionButton() {
    if (_thsrlist.isEmpty) {
      return null;
    } else {
      return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => THSRForm(null, null,null)));
          });
    }
  }

  Widget _buildTHSRList() {
    if (_thsrlist.isEmpty) {
      return _buildCenterAddButton();
      // showMessage('There is currently no taxi in the list yet');
    } else {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 5),
        // padding: const EdgeInsets.all(16),
        itemCount: _thsrlist.length,
        itemBuilder: (BuildContext _context, int i) {
          return _buildRow(_thsrlist[i]);
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

  Widget _buildRow(THSR thsr) {
    return Dismissible(
      child: ListTile(
        // leading: _infectLevelIcon(thsr.infection_level),
        title: Text('${thsr.trainNo} ${thsr.departure} - ${thsr.destination}'),
        subtitle: Text(
          '${DateFormat('MM/dd HH:mm').format(thsr.datetime_from)} - ${DateFormat('MM/dd HH:mm').format(thsr.datetime_to)}\n${thsr.note}',
        ),
        onTap: () {
          _showInfoCard(thsr);
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
      key: ValueKey(thsr.local_id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
           Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => THSRForm(null, null, thsr)));
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, thsr) == true;
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
                  Text(allTranslations.text('Add THSR'),
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
                    builder: (BuildContext context) => THSRForm(null, null,null)));
              }),
        ));
  }

  void _showInfoCard(THSR thsr) {
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
                            ListTile(
                              title: Text(allTranslations.text('Train No.'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              subtitle: Text(
                                thsr.trainNo == ''
                                    ? allTranslations.text('Empty')
                                    : thsr.trainNo,
                                style: TextStyle(fontSize: 20),
                              ),
                              leading: Icon(Icons.directions_railway),
                            ),
                            Divider(),
                            ListTile(
                              title: Text(
                                  allTranslations
                                      .text('Depature and Destination'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              leading: Icon(Icons.location_on),
                              subtitle: Text(
                                '${thsr.departure} - ${thsr.destination}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            ListTile(
                              title: Text(allTranslations.text('Time Period'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              leading: Icon(Icons.access_time),
                              subtitle: Text(
                                '${DateFormat('yyyy/MM/dd HH:mm').format(thsr.datetime_from)} - ${DateFormat('yyyy/MM/dd HH:mm').format(thsr.datetime_to)}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            ListTile(
                              title: Text(allTranslations.text('Car Number'),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 25)),
                              leading: Icon(Icons.directions_railway),
                              subtitle: Text(
                                thsr.car_number,
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
                                thsr.note,
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

  Future<bool> _deleteCheck(BuildContext context, THSR thsr) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '${allTranslations.text('Do you want to delete THSR Train No.')} ${thsr.trainNo}?'),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                THSRService().deleteTHSR(thsr);
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
