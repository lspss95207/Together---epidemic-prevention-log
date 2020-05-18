import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
// import 'package:place_picker/place_picker.dart';

import 'package:virus_tracker/locationPage/locationService.dart';
import 'package:virus_tracker/locationPage/location.dart';
import 'package:virus_tracker/locationPage/locationFav.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

class LocationForm extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String location_name;

  const LocationForm(this.latitude, this.longitude, this.location_name);

  @override
  State createState() => LocationFormState();
}

class LocationFormState extends State<LocationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Location _submitLocation = Location();

  GoogleMapController mapController;
  Marker _marker;
  final Set<Marker> _markers = {};
  LatLng _submitLatlng;

  String _darkMapStyle;

  @override
  void initState() {
    super.initState();
    _submitLocation.datetime_from = DateTime.now();
    rootBundle.loadString('assets/dark_map_style.json').then((string) {
      _darkMapStyle = string;
    });
    if (widget.latitude != null && widget.longitude != null) {
      double lat = double.tryParse(widget.latitude);
      double lng = double.tryParse(widget.longitude);
      if (lat != null && lng != null) {
        _submitLatlng = LatLng(lat, lng);
        _addMarker(_submitLatlng);
      }
      _submitLocation.location_name = widget.location_name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Add Location')),
      ),
      key: _scaffoldKey,
      body: ListView(children: <Widget>[
        Column(
          children: <Widget>[
            // google map
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: _build_map(),
            ),

            //form
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              child: _build_form(),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _build_map() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(23.0, 121.0),
        zoom: 7,
      ),
      gestureRecognizers: Set()
        ..add(Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer()))
        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
        ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
        ..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
        ..add(Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer())),
      myLocationEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        _getLocation();
        if (Theme.of(context).brightness == Brightness.dark) {
          mapController.setMapStyle(_darkMapStyle);
        }
      },
      onTap: (latlng) {
        _addMarker(latlng);
      },
      markers: _markers,
    );
  }

  void _getLocation() async {
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: (_submitLatlng == null)
                ? LatLng(currentLocation.latitude, currentLocation.longitude)
                : _submitLatlng,
            zoom: 15.0),
      ),
    );
  }

  void _addMarker(latlng) {
    setState(() {
      _submitLatlng = latlng;
      _submitLocation.latitude = _submitLatlng.latitude;
      _submitLocation.longitude = _submitLatlng.longitude;
      _marker = Marker(
        markerId: MarkerId('0'),
        position: latlng,
      );
      _markers.add(_marker);
    });
  }

  Widget _build_form() {
    return Form(
      key: _formKey,
      autovalidate: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(children: <Widget>[
            //map picker (too expensive)
            //   Icon(Icons.location_on,color: Colors.grey,),
            //   SizedBox(width: 20,),
            //   RaisedButton(
            //     child: Text('選擇地點'),
            //     onPressed: () {
            //       _showPlacePicker();
            //     },
            //   ),

            // _build_map(),

            // SizedBox(
            //   width: 20,
            // ),
          ]),
          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                  child: Text(allTranslations.text('Favorite Locations')),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => LocationFav()));
                  }),
            ),
          ),

          //-----------location name------------------
          TextFormField(
            initialValue:
                (widget.location_name == null) ? '' : widget.location_name,
            decoration: InputDecoration(
              icon: Icon(Icons.location_on),
              hintText: allTranslations.text('Please enter Location Name'),
              labelText: allTranslations.text('Location Name'),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return allTranslations.text('Location Name cannot be empty');
              }
              return null;
            },
            onChanged: (val) => _submitLocation.location_name = val,
            onSaved: (val) => _submitLocation.location_name = val,
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(allTranslations.text('Add to Favorite Locations')),
                onPressed: _submitFavoriteLocation,
              ),
            ),
          ),

          //-----------datetime from------------------
          DateTimeField(
            initialValue: _submitLocation.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText:
                  allTranslations.text('Please enter date time from-location'),
              labelText: allTranslations.text('Date Time From-location'),
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
            onSaved: (val) => _submitLocation.datetime_from = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date time from cannot be empty-location');
              }
              return null;
            },
          ),
          //-----------datetime to------------------

          DateTimeField(
            initialValue: _submitLocation.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText:
                  allTranslations.text('Please enter date time to-location'),
              labelText: allTranslations.text('Date Time To-location'),
            ),
            format: DateFormat("yyyy-MM-dd HH:mm"),
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
            onSaved: (val) => _submitLocation.datetime_to = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date time to cannot be empty-location');
              } else if (_submitLocation.datetime_from != null &&
                  value.isBefore(_submitLocation.datetime_from)) {
                return allTranslations.text(
                    'Date time to cannot be earlier than Date time from-location');
              }
              return null;
            },
          ),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              icon: Icon(Icons.location_on),
              hintText: allTranslations.text('Please enter Location Type'),
              labelText: allTranslations.text('Location Type'),
            ),
            value: _submitLocation.type,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              if (!mounted) return;
              setState(() {
                _submitLocation.type = newValue;
              });
            },
            items: <String>[
              '住家 Home',
              '公司 Work',
              '學校 School',
              '餐廳 Restaurant',
              '其他 Other',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return allTranslations.text('Location Type cannot be empty');
              }
              return null;
            },
          ),

          //-------------people with-----------------------
          TextFormField(
            decoration: InputDecoration(
              icon: Icon(Icons.edit),
              hintText: allTranslations.text('Please enter Note'),
              labelText: allTranslations.text('Note'),
            ),
            onSaved: (val) => _submitLocation.note = val,
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

  // void _showPlacePicker() async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PlacePicker(
  //         apiKey: 'AIzaSyBRAqnX5vIqj6ONlaDpWr6UtvNOuMnWxlM',
  //         useCurrentLocation: true,
  //         usePlaceDetailSearch: true,
  //         initialPosition: LatLng(23.0, 121.0),
  //         onPlacePicked: (result) {
  //           print(result.formattedAddress);
  //           setState(() {
  //             result.geometry.toString();
  //             _submitLatlng = LatLng(
  //                 result.geometry.location.lat, result.geometry.location.lng);
  //             print(_submitLatlng);
  //           });
  //           Navigator.of(context).pop();
  //         },
  //       ),
  //     ),
  //   );
  //   // Handle the result in your way
  // }

  void _submitForm() {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    } else if (_submitLocation.latitude == null ||
        _submitLocation.longitude == null) {
      showMessage(allTranslations.text('Please select a location on the map.'));
    } else {
      //This invokes each onSaved event
      _submitLocation.note =
          (_submitLocation.note == null) ? '' : _submitLocation.note;
      print(_submitLocation.toJson());
      LocationService().createLocation(_submitLocation);
      Navigator.of(context).pop();
    }
  }

  void _submitFavoriteLocation() {
    if (_submitLocation.latitude == null || _submitLocation.longitude == null) {
      showMessage(allTranslations.text('Please select a location on the map.'));
    } else if (_submitLocation.location_name == null) {
      showMessage(allTranslations.text('Location Name cannot be empty'));
    } else {
      LocationService().addFavorite(_submitLocation.latitude,
          _submitLocation.longitude, _submitLocation.location_name);
      showMessage(
          '${_submitLocation.location_name} ${allTranslations.text('is added to favorite locations.')}',
          Colors.blue);
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
