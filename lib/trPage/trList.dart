import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/trPage/tr.dart';
import 'package:virus_tracker/trPage/trService.dart';
import 'package:virus_tracker/trPage/trForm.dart';
import 'package:virus_tracker/trPage/trFav.dart';

class TRList extends StatefulWidget {
  @override
  State createState() => TRListState();
}

class TRListState extends State<TRList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<TR> _trlist = <TR>[];

  var updatePeriod;

  @override
  void initState() {
    super.initState();
    TRService().getTR();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _trlist = globals.trList;
        // print(_trlist);
      });
    });
    // updateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(allTranslations.text('Taiwan Railways Record'),
              textAlign: TextAlign.center),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: _buildTRList(),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => TRForm(null, null)));
          },
        )
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
        //             builder: (BuildContext context) => TRForm(null, null)));
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
        //             builder: (BuildContext context) => TRFav()));
        //       },
        //       label: '常用起訖站',
        //       labelStyle: TextStyle(fontWeight: FontWeight.w500),
        //       labelBackgroundColor: Colors.green,
        //     ),
        //   ],
        // )
        );
  }

  Widget _buildTRList() {
    if (_trlist.isEmpty) {
      // showMessage('There is currently no location in the list yet');
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _trlist.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_trlist[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(TR tr) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      child: ListTile(
        // leading: _infectLevelIcon(tr.infection_level),
        title: Text(
          '${tr.trainNo} ${tr.departure} - ${tr.destination}',
        ),
        subtitle: Text(
          '${DateFormat('MM/dd HH:mm').format(tr.datetime_from)} - ${DateFormat('MM/dd HH:mm').format(tr.datetime_to)}\n${tr.note}',
        ),
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
      key: ValueKey(tr.local_id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edit item
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // delete item
          return await _deleteCheck(context, tr) == true;
        }
      },
    );
  }

  Future<bool> _deleteCheck(BuildContext context, TR tr) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              "${allTranslations.text('Do you want to delete TR Train No')} ${tr.trainNo}?"),
          actions: <Widget>[
            FlatButton(
              child: Text(allTranslations.text('Confirm')),
              onPressed: () {
                TRService().deleteTR(tr);
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
