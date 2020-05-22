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

import 'package:virus_tracker/taxiPage/taxiService.dart';
import 'package:virus_tracker/taxiPage/taxi.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

class TaxiForm extends StatefulWidget {
  @override
  final Taxi taxi;
  const TaxiForm(this.taxi);

  State createState() => TaxiFormState();
}

class TaxiFormState extends State<TaxiForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Taxi _submitTaxi = Taxi();

  bool editMode;
  Taxi taxi;

  GoogleMapController mapController;
  Marker _marker;
  final Set<Marker> _markers = {};
  LatLng _submitLatlng;

  String _darkMapStyle;

  @override
  void initState() {
    super.initState();
    taxi = widget.taxi;
    if(taxi != null){
      _submitTaxi.datetime_from = taxi.datetime_from;
      _submitTaxi.datetime_to = taxi.datetime_to;
      editMode = true;
    }else{
      _submitTaxi.datetime_from = DateTime.now();
      _submitTaxi.datetime_to = DateTime.now();
      editMode = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Add Taxi')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      key: _scaffoldKey,
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: _build_form(),
          ),
        ],
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
          //-----------taxi name------------------
          TextFormField(
            initialValue: editMode?taxi.plate:null,
            decoration: InputDecoration(
              icon: Icon(Icons.local_taxi),
              hintText: allTranslations.text('Please enter Taxi Plate'),
              labelText: allTranslations.text('Taxi Plate'),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return allTranslations.text('Taxi Plate cannot be empty');
              }
              return null;
            },
            onChanged: (val) => _submitTaxi.plate = val,
            onSaved: (val) => _submitTaxi.plate = val,
          ),
          TextFormField(
            initialValue: editMode?taxi.departure:null,
            decoration: InputDecoration(
              icon: Icon(Icons.local_taxi),
              hintText: allTranslations.text('Please enter Departure-taxi'),
              labelText: allTranslations.text('Departure-taxi'),
            ),
            onChanged: (val) => _submitTaxi.departure = val,
            onSaved: (val) => _submitTaxi.departure = val,
          ),
          TextFormField(
            initialValue: editMode?taxi.destination:null,
            decoration: InputDecoration(
              icon: Icon(Icons.local_taxi),
              hintText: allTranslations.text('Please enter Destination-taxi'),
              labelText: allTranslations.text('Destination-taxi'),
            ),
            onChanged: (val) => _submitTaxi.destination = val,
            onSaved: (val) => _submitTaxi.destination = val,
          ),

          //-----------datetime from------------------
          DateTimeField(
            initialValue: editMode?taxi.datetime_from:_submitTaxi.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText:
                  allTranslations.text('Please enter Date Time from-taxi'),
              labelText: allTranslations.text('Date Time From-taxi'),
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
            onSaved: (val) => _submitTaxi.datetime_from = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date time from cannot be empty-taxi');
              }
              return null;
            },
          ),
          //-----------datetime to------------------

          DateTimeField(
            initialValue: editMode?taxi.datetime_to:_submitTaxi.datetime_from,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText: allTranslations.text('Please enter date time to-taxi'),
              labelText: allTranslations.text('Date Time To-taxi'),
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
            onSaved: (val) => _submitTaxi.datetime_to = val,
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Date time to cannot be empty-taxi');
              } else if (_submitTaxi.datetime_from != null &&
                  value.isBefore(_submitTaxi.datetime_from)) {
                return allTranslations.text(
                    'Date time to cannot be earlier than Date time from-taxi');
              }
              return null;
            },
          ),

          //-------------people with-----------------------
          TextFormField(
            initialValue: editMode?taxi.note:null,
            decoration: InputDecoration(
              icon: Icon(Icons.edit),
              hintText: allTranslations.text('Please enter Note'),
              labelText: allTranslations.text('Note'),
            ),
            onSaved: (val) => _submitTaxi.note = val,
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

  void _submitForm() {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      if(editMode){
        TaxiService().deleteTaxi(taxi);
      }
      //This invokes each onSaved event
      _submitTaxi.note = (_submitTaxi.note == null) ? '' : _submitTaxi.note;
      print(_submitTaxi.toJson());
      TaxiService().createTaxi(_submitTaxi);
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
