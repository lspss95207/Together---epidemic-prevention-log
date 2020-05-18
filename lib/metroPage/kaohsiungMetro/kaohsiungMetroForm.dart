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
import 'package:photo_view/photo_view.dart';
import 'package:quiver/iterables.dart';
import 'package:positioned_tap_detector/positioned_tap_detector.dart';

import 'package:virus_tracker/motc.dart';
import 'package:virus_tracker/metroPage/metro.dart';
import 'package:virus_tracker/metroPage/kaohsiungMetro/kaohsiungMetroService.dart';
import 'package:virus_tracker/metroPage/kaohsiungMetro/kaohsiungMetroFav.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

class KaohsiungMetroForm extends StatefulWidget {
  final String departure;
  final String destination;

  const KaohsiungMetroForm(this.departure, this.destination);

  @override
  State createState() => KaohsiungMetroFormState();
}

class KaohsiungMetroFormState extends State<KaohsiungMetroForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, dynamic> _metroStations = {};
  Map<Path, String> _metroStationPath = {};

  String departure;
  String destination;
  Metro _submitMetro = Metro();

  Map<String, Metro> _DropdownMap = {};
  List<String> _metroDropdownList = [];

  @override
  void initState() {
    super.initState();
    _submitMetro.datetime_from = DateTime.now();
    _readMetroStations();
    departure = widget.departure;
    destination = widget.destination;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Add Kaohsiung Metro')),
      ),
      key: _scaffoldKey,
      body: ListView(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: _buildMetroMap(), // Mapbox
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: _build_form(),
            ),
          ],
        ),
      ]),
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
                child: Text(allTranslations.text('Favorite Stations')),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => MetroFav()));
                },
              ),
            ),
          ),

          //-----------stations------------------
          SearchableDropdown.single(
            label: Text(allTranslations.text('Departure')),
            hint: Text(allTranslations.text('Please enter Departure')),
            value: departure,
            icon: Icon(Icons.train, color: Colors.grey),
            items: _metroStations.keys.map((item) {
              return DropdownMenuItem(child: Text(item), value: item);
            }).toList(),
            onChanged: (dynamic newValue) {
              departure = newValue;
              _submitMetro.departure = newValue;
            },
            isExpanded: true,
            displayClearIcon: false,
          ),

          SearchableDropdown.single(
            label: Text(allTranslations.text('Destination')),
            hint: Text(allTranslations.text('Please enter Destination')),
            value: destination,
            icon: Icon(Icons.train, color: Colors.grey),
            items: _metroStations.keys.map((item) {
              return DropdownMenuItem(child: Text(item), value: item);
            }).toList(),
            onChanged: (dynamic newValue) {
              destination = newValue;
              _submitMetro.destination = newValue;
            },
            isExpanded: true,
            displayClearIcon: false,
          ),

          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(allTranslations.text('Add to Favorite Stations')),
                onPressed: _submitFavoriteStations,
              ),
            ),
          ),

          SizedBox(height: 10),

          //-----------datetime from------------------
          DateTimeField(
            initialValue: _submitMetro.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText:
                  allTranslations.text('Please enter Date Time from-metro'),
              labelText: allTranslations.text('Date Time From-metro'),
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
            onSaved: (val) => _submitMetro.datetime_from = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date Time from cannot be empty-metro');
              }
              return null;
            },
          ),
          //-----------datetime to------------------

          DateTimeField(
            initialValue: _submitMetro.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText: allTranslations.text('Please enter Date Time to-metro'),
              labelText: allTranslations.text('Date Time To-metro'),
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
            onSaved: (val) => _submitMetro.datetime_to = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date Time to cannot be empty-metro');
              } else if (_submitMetro.datetime_from != null &&
                  value.isBefore(_submitMetro.datetime_from)) {
                return allTranslations.text(
                    'Date Time to cannot be earlier than Date Time from-metro');
              }
              return null;
            },
          ),

          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.edit),
              hintText: allTranslations.text('Please enter Note'),
              labelText: allTranslations.text('Note'),
            ),
            onSaved: (val) => _submitMetro.note = val,
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

  void _readMetroStations() async {
    _metroStationPath = {};
    var data =
        await rootBundle.loadString('assets/kaohsiungMetroStations.json');
    final station_raw = json.decode(data);
    setState(() {
      for (var station in station_raw) {
        _metroStations[station['StationName']['Zh_tw'] +
            ' ' +
            station['StationName']['En']] = station;

        var path = Path();
        if (station['mapIcon'] != null) {
          var offset = Offset(station['mapIcon']['center']['x'].toDouble(),
              station['mapIcon']['center']['y'].toDouble());
          double radius = station['mapIcon']['radius'].toDouble();
          var rect = Rect.fromCircle(center: offset, radius: radius);
          // print(rect);
          path.addOval(rect);
          // print(path);
        }
        _metroStationPath[path] = station['StationName']['Zh_tw'] +
            ' ' +
            station['StationName']['En'];
      }
    });

    // print(_metroStations);
  }

  String selectionStatus = 'departure';

  Widget _buildMetroMap() {
    return PhotoViewGestureDetectorScope(
        axis: Axis.vertical,
        child: ClipRect(
            child: PhotoView.customChild(
          childSize: Size(300, 170),
          child: CustomPaint(
            size: Size(300, 170),
            foregroundPainter:
                MyPainter(_metroStationPath, departure, destination),
            child: ImageMap(
              image: Image.asset(
                  (Theme.of(context).brightness == Brightness.dark)
                      ? 'assets/KaohsiungMetroMap_night.jpg'
                      : 'assets/KaohsiungMetroMap_day.jpg',
                  fit: BoxFit.contain),
              onTap: (val) {
                // _readMetroStations();
                setState(() {
                  print(val);
                  if (selectionStatus == 'departure') {
                    if (val == destination) {
                      return;
                    }
                    departure = val;
                    selectionStatus = 'destination';
                  } else if (selectionStatus == 'destination') {
                    if (val == departure) {
                      return;
                    }
                    destination = val;
                    selectionStatus = 'departure';
                  } else {
                    selectionStatus = 'departure';
                  }
                });
              },
              regions: _metroStationPath,
            ),
          ),
          // imageProvider: AssetImage('assets/metro_map.png'),
          // customSize: MediaQuery.of(context).size,
          backgroundDecoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          minScale: PhotoViewComputedScale.contained * 0.8,
          initialScale: PhotoViewComputedScale.contained * 3,
        )));
  }

  void _submitFavoriteStations() {
    if (departure == null || destination == null) {
      showMessage(
          allTranslations.text('Please enter Departure and Destination.'));
    } else {
      KaohsiungMetroService().addFavorite(departure, destination);
      showMessage(
          "${departure + ' - ' + destination} ${allTranslations.text('is added to favorite stations.')}",
          Colors.blue);
    }
  }

  void _submitForm() {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    } else if (departure == null) {
      showMessage(allTranslations.text('Please enter Departure'));
    } else if (destination == null) {
      showMessage(allTranslations.text('Please enter Destination'));
    } else {
      //This invokes each onSaved event
      _submitMetro.note = (_submitMetro.note == null) ? '' : _submitMetro.note;
      _submitMetro.departure = departure;
      _submitMetro.destination = destination;
      print(_submitMetro.toJson());
      KaohsiungMetroService().createMetro(_submitMetro);
      Navigator.of(context).pop();
    }
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

class ImageMap extends StatelessWidget {
  const ImageMap({
    Key key,
    @required this.image,
    @required this.onTap,
    @required this.regions,
  }) : super(key: key);

  final Image image;
  final Map<Path, String> regions;

  /// Callback that will be invoked with the index of the tapped region.
  final void Function(String) onTap;

  void _onTap(BuildContext context, Offset globalPosition) {
    RenderObject renderBox = context.findRenderObject();
    if (renderBox is RenderBox) {
      final localPosition = renderBox.globalToLocal(globalPosition);
      print(localPosition);
      for (final indexedRegion in regions.keys) {
        if (indexedRegion.contains(localPosition)) {
          onTap(regions[indexedRegion]);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTap(context, details.globalPosition),
      child: image,
    );
  }
}

class MyPainter extends CustomPainter {
  Map<Path, String> _paths;
  String _departure;
  String _destination;

  MyPainter(paths, departure, destination) {
    _paths = paths;
    _departure = departure;
    _destination = destination;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paths.forEach((key, value) {
      if (value == _departure) {
        Paint paint = Paint()
          ..color = Colors.red
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawPath(key, paint);
      } else if (value == _destination) {
        Paint paint = Paint()
          ..color = Colors.yellow
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawPath(key, paint);
      } else {
        Paint paint = Paint()
          ..color = Color(0xFFFFFFFF).withAlpha(0)
          // ..color = Colors.yellow
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawPath(key, paint);
      }
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
