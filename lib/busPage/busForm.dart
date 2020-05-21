import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

import 'package:virus_tracker/motc.dart';
import 'package:virus_tracker/busPage/bus.dart';
import 'package:virus_tracker/busPage/busFav.dart';
import 'package:virus_tracker/busPage/busService.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

class BusForm extends StatefulWidget {
  final String city;
  final String route;
  final Bus bus;

  const BusForm(this.city, this.route, this.bus);
  @override
  State createState() => BusFormState();
}

class BusFormState extends State<BusForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, Map> _cityRoutes = {};

  final Bus _submitBus = Bus();
  Bus bus;

  bool editMode;

  String city;
  String route;
  String direction;
  String note;

  Map<String, Bus> _busDropdownMap = {};
  List<String> _busDropdownList = [];
  List<String> _destinationDropdownList = [];

  @override
  void initState() {
    super.initState();

    bus = widget.bus;

    _readBusRoutes();

    if (bus != null) {
      _submitBus.datetime_from = bus.datetime_from;
      _submitBus.datetime_to = bus.datetime_to;
      note = bus.note;
      editMode = true;
    } else {
      _submitBus.datetime_from = DateTime.now();
      editMode = false;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        if (bus != null) {
          city = bus.city;
        } else {
          city = (widget.city == null) ? null : widget.city;
        }

        _submitBus.city = city;
      });
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _getRoute();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (bus != null) {
        route = bus.route;
        direction = bus.direction;
      } else {
        route = widget.route;
      }

      _submitBus.route = route;
      _getDestination();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Add Bus Records')),
      ),
      key: _scaffoldKey,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: _build_form(),
          ),
        ),
      ),
    );
  }

  Widget _build_form() {
    return Form(
      key: _formKey,
      autovalidate: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(allTranslations.text('Favorite Routes')),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => BusFav()));
                },
              ),
            ),
          ),

          //-----------stations------------------

          SearchableDropdown.single(
            label: Text(allTranslations.text('City')),
            hint: Text(allTranslations.text('Please enter City')),
            value: city,
            icon: Icon(Icons.train, color: Colors.grey),
            items: (['全部All'] + _cityRoutes.keys.toList()).map((item) {
              return DropdownMenuItem(child: Text(item), value: item);
            }).toList(),
            onChanged: (dynamic newValue) {
              city = newValue;
              setState(() {
                _getRoute();
              });
              _submitBus.city = newValue;
            },
            isExpanded: true,
            displayClearIcon: false,
          ),
          SearchableDropdown.single(
            label: Text(allTranslations.text('Route')),
            hint: Text(allTranslations.text('Please enter Route')),
            value: route,
            icon: Icon(Icons.train, color: Colors.grey),
            items: _busDropdownList.map((item) {
              return DropdownMenuItem(child: Text(item), value: item);
            }).toList(),
            onChanged: (dynamic newValue) {
              route = newValue;
              setState(() {
                direction = '';
                _getDestination();
                print(_destinationDropdownList);
              });
              _submitBus.route = newValue;
            },
            isExpanded: true,
            displayClearIcon: false,
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(allTranslations.text('Add to Favorite Route')),
                onPressed: _submitFavoriteRoute,
              ),
            ),
          ),
          SizedBox(height: 10),

          SearchableDropdown.single(
            label: Text(allTranslations.text('Direction')),
            hint: Text(allTranslations.text('Please enter Direction')),
            value: direction,
            items: _destinationDropdownList.map((item) {
              print(item);
              return DropdownMenuItem(child: Text(item), value: item);
            }).toList(),
            onChanged: (dynamic newValue) {
              _submitBus.direction = newValue;
              setState(() {
                direction = newValue;
              });
              _submitBus.direction = newValue;
            },
            isExpanded: true,
            displayClearIcon: false,
          ),

          //-----------datetime from------------------
          DateTimeField(
            initialValue: _submitBus.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText: allTranslations.text('Enter Date Time from-bus'),
              labelText: allTranslations.text('Date Time From-bus'),
            ),
            format: DateFormat('yyyy-MM-dd HH:mm'),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            onSaved: (val) => _submitBus.datetime_from = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date Time from cannot be empty-bus');
              }
              return null;
            },
          ),

          //-----------datetime to------------------

          DateTimeField(
            initialValue: editMode?bus.datetime_to:_submitBus.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText: allTranslations.text('Enter Date Time to-bus'),
              labelText: allTranslations.text('Date Time To-bus'),
            ),
            format: DateFormat('yyyy-MM-dd HH:mm'),
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            onSaved: (val) => _submitBus.datetime_to = val,
            validator: (value) {
              if (value == null) {
                return allTranslations.text('Date time to cannot be empty-bus');
              } else if (_submitBus.datetime_from != null &&
                  value.isBefore(_submitBus.datetime_from)) {
                return allTranslations.text(
                    'Date time to cannot be earlier than Date time from-bus');
              }
              return null;
            },
          ),

          TextFormField(
            initialValue: note,
            decoration: InputDecoration(
              icon: Icon(Icons.edit),
              hintText: allTranslations.text('Please enter Note'),
              labelText: allTranslations.text('Note'),
            ),
            onSaved: (val) => _submitBus.note = val,
            onChanged: (val) => _submitBus.note = val,
          ),

          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(allTranslations.text('Submit')),
                onPressed: _submitForm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _readBusRoutes() async {
    var data = await rootBundle.loadString('assets/busRoutes.json');
    print(data);
    final city_raw = json.decode(data);
    setState(() {
      for (var city in city_raw) {
        print(city["City"]);
        Map<String, dynamic> tmpRoute = {};
        for (var routes in city['Routes']) {
          String key =
              "${routes['RouteName']['Zh_tw']}${(routes['RouteName']['En'] == routes['RouteName']['Zh_tw']) ? ' ' : ' ' + routes['RouteName']['En']}";
          tmpRoute[key] = routes;
        }
        _cityRoutes[city["City"]] = tmpRoute;
      }
    });

    // print(_cityRoutes);
  }

  void _getRoute() {
    _busDropdownList = [];
    if (city == '全部All') {
      for (var city in _cityRoutes.keys) {
        _busDropdownList += (_cityRoutes[city].keys.toList());
      }
    } else {
      _busDropdownList = _cityRoutes[city].keys.toList();
    }
  }

  void _getDestination() {
    _destinationDropdownList = [];
    String departure;
    String destination;

    if (city == '全部All') {
      for (var city in _cityRoutes.keys) {
        var value = _cityRoutes[city][route];
        if (value == null) {
          continue;
        } else {
          print(value);
        }
        departure = value['DepartureStopNameZh'] + value['DepartureStopNameEn'];
        destination =
            value['DestinationStopNameZh'] + value['DestinationStopNameEn'];
        break;
      }
    } else {
      var value = _cityRoutes[city][route];
      print(value);
      departure = value['DepartureStopNameZh'] + value['DepartureStopNameEn'];
      destination =
          value['DestinationStopNameZh'] + value['DestinationStopNameEn'];
    }
    _destinationDropdownList.add(departure);
    if (departure != destination) {
      _destinationDropdownList.add(destination);
    }
    _destinationDropdownList.forEach((element) {
      if (element == null) {
        _destinationDropdownList.remove(element);
      }
    });
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        )));
  }

  void _submitForm() {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      if (city == null) {
        showMessage(allTranslations.text('Please enter City'));
      } else if (route == null) {
        showMessage(allTranslations.text('Please enter Route'));
      } else if (_submitBus.direction == null) {
        showMessage(allTranslations.text('Please enter Direction'));
      } else {
        //This invokes each onSaved event
        if(editMode){
          BusService().deleteBus(bus);
        }
        _submitBus.note = (_submitBus.note == null) ? '' : _submitBus.note;
        print(_submitBus.note);
        print(_submitBus.toJson());
        BusService().createBus(_submitBus);
        Navigator.of(context).pop();
      }
    }
  }

  void _submitFavoriteRoute() {
    _formKey.currentState.save();
    if (_submitBus.city == null || _submitBus.route == null) {
      showMessage(allTranslations.text('Please enter Route'));
    } else {
      BusService().addFavorite(_submitBus.city, _submitBus.route);
      showMessage(
          '${_submitBus.route} ${allTranslations.text('is added to favorite routes.')}.',
          Colors.blue);
    }
  }
}
