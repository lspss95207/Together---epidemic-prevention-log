import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/metroPage/metro.dart';
import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroService.dart';
import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroForm.dart';
import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroFav.dart';

class TaipeiMetroList extends StatefulWidget {
  @override
  State createState() => TaipeiMetroListState();
}

class TaipeiMetroListState extends State<TaipeiMetroList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Metro> _metrolist = <Metro>[];

  var updatePeriod;

  @override
  void initState() {
    super.initState();
    TaipeiMetroService().getMetro();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _metrolist = globals.taipeiMetroList;
        // print(_metrolist);
      });
    });
    // updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('Taipei Metro Record'),
            textAlign: TextAlign.center),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildMetroList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => TaipeiMetroForm(null, null)));
        },
      ),
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
      //             builder: (BuildContext context) => TaipeiMetroForm(null, null)));
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
      //             builder: (BuildContext context) => MetroFav()));
      //       },
      //       label: '常用起訖站',
      //       labelStyle: TextStyle(fontWeight: FontWeight.w500),
      //       labelBackgroundColor: Colors.green,
      //     ),
      //   ],
      // )
    );
  }

  Widget _buildMetroList() {
    if (_metrolist.isEmpty) {
      // showMessage('There is currently no location in the list yet');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _metrolist.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_metrolist[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(Metro metro) {
    // print(metro.toJson());
    return Dismissible(
      direction: DismissDirection.endToStart,
      child: ListTile(
        // leading: _infectLevelIcon(metro.infection_level),
        title: Text(metro.departure + ' - ' + metro.destination),
        subtitle: Text('${DateFormat('MM/dd HH:mm').format(metro.datetime_from)} - ${DateFormat('MM/dd HH:mm').format(metro.datetime_to)}\n${metro.note}'),
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
      key: ValueKey(metro.local_id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, metro) == true;
        }
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, Metro metro) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(allTranslations.text('Do you want to delete Metro record?')),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                TaipeiMetroService().deleteMetro(metro);
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
