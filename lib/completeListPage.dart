import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'package:virus_tracker/thsrPage/thsr.dart';
import 'package:virus_tracker/thsrPage/thsrService.dart';
import 'package:virus_tracker/trPage/tr.dart';
import 'package:virus_tracker/trPage/trService.dart';
import 'package:virus_tracker/busPage/bus.dart';
import 'package:virus_tracker/busPage/busService.dart';
import 'package:virus_tracker/metroPage/metro.dart';
import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroService.dart';
import 'package:virus_tracker/metroPage/kaohsiungMetro/kaohsiungMetroService.dart';
import 'package:virus_tracker/locationPage/location.dart';
import 'package:virus_tracker/locationPage/locationService.dart';
import 'package:virus_tracker/taxiPage/taxi.dart';
import 'package:virus_tracker/taxiPage/taxiService.dart';

class CompleteListPage extends StatefulWidget {
  @override
  State createState() => CompleteListPageState();
}

class CompleteListPageState extends State<CompleteListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var updatePeriod;

  List _completeList = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    THSRService().getTHSR();
    TRService().getTR();
    LocationService().getLocation();
    KaohsiungMetroService().getMetro();
    TaipeiMetroService().getMetro();
    BusService().getBus();
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _updateList();
      });
    });
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(allTranslations.text('Complete List'),
            textAlign: TextAlign.center),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildCompleteList(),
      ),
    );
  }

  Widget _buildCompleteList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 5),
      // padding: const EdgeInsets.all(16),
      itemCount: _completeList.length,
      itemBuilder: (BuildContext _context, int i) {
        return _buildRow(_completeList[i]);
      },
      separatorBuilder: (context, index) {
        return Divider(
          indent: 100,
          endIndent: 100,
        );
      },
    );
  }

  Widget _buildRow(Map map) {
    return ListTile(
      leading: map['icon'],
      title: Text(map['title']),
      subtitle: Text(DateFormat('MM/dd HH:mm').format(map['datetime_from']) +
          ' - ' +
          DateFormat('MM/dd HH:mm').format(map['datetime_to'])),
      onTap: null,
    );
  }

  void _updateList() {
    _completeList = [];
    globals.locationList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.location_on),
        'local_id': _completeList.length,
        'title': element.location_name,
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    globals.thsrList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.directions_railway),
        'local_id': _completeList.length,
        'title':
            '${element.trainNo}  ${element.departure} - ${element.destination}',
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    globals.trList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.train),
        'local_id': _completeList.length,
        'title':
            '${element.trainNo}  ${element.departure} - ${element.destination}',
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    globals.taipeiMetroList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.directions_subway),
        'local_id': _completeList.length,
        'title': '${element.departure} - ${element.destination}',
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    globals.kaohsiungMetroList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.directions_subway),
        'local_id': _completeList.length,
        'title': '${element.departure} - ${element.destination}',
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    globals.busList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.directions_bus),
        'local_id': _completeList.length,
        'title': '${element.route}  ${element.direction}',
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    globals.taxiList.forEach((element) {
      _completeList.add({
        'icon': Icon(Icons.local_taxi),
        'local_id': _completeList.length,
        'title': '${element.plate}',
        'datetime_from': element.datetime_from,
        'datetime_to': element.datetime_to,
        'note': element.note
      });
    });
    setState(() {
      _completeList
          .sort((a, b) => a['datetime_from'].compareTo(b['datetime_from']));
    });
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
