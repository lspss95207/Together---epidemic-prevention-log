import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

import 'package:virus_tracker/motc.dart';

import 'package:virus_tracker/thsrPage/thsr.dart';
import 'package:virus_tracker/thsrPage/thsrService.dart';
import 'package:virus_tracker/thsrPage/thsrFav.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

import 'thsr.dart';

class THSRForm extends StatefulWidget {
  final String departure;
  final String destination;

  const THSRForm(this.departure, this.destination);

  @override
  State createState() => THSRFormState();
}

class THSRFormState extends State<THSRForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, String> _thsrStations = {
    '南港 Nangang': '0990',
    '台北 Taipei': '1000',
    '板橋 Banqiao': '1010',
    '桃園 Taoyuan': '1020',
    '新竹 Hsinchu	': '1030',
    '苗栗 Miaoli': '1035',
    '台中 Taichung	': '1040',
    '彰化 Changhua	': '1043',
    '雲林 Yunlin': '1047',
    '嘉義 Chiayi': '1050',
    '台南 Tainan': '1060',
    '左營 Zuoying': '1070'
  };

  String departure;
  String destination;
  DateTime departure_time;
  String car_number;
  String submitTHSRTrainNo;
  String note;

  Map<String, THSR> _thsrDropdownMap = {};
  List<String> _thsrDropdownList = [];

  @override
  void initState() {
    super.initState();
    departure = widget.departure;
    destination = widget.destination;
    departure_time = DateTime.now();
    Future.delayed(const Duration(milliseconds: 300), () {
      _getTHSRSchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Add THSR')),
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
          Container(
            margin: EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                child: Text(allTranslations.text('Favorite Stations')),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => THSRFav()));
                },
              ),
            ),
          ),
          //-----------stations------------------
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              icon: Icon(Icons.train),
              hintText: allTranslations.text('Please enter Departure'),
              labelText: allTranslations.text('Departure'),
            ),
            value: departure,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              if (!mounted) return;
              setState(() {
                departure = newValue;
                Future.delayed(Duration(milliseconds: 500), () {
                  _getTHSRSchedule();
                });
              });
            },
            items: _thsrStations.keys
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return allTranslations.text('Departure cannot be empty');
              }
              return null;
            },
          ),

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              icon: Icon(Icons.train),
              hintText: allTranslations.text('Please enter Destination'),
              labelText: allTranslations.text('Destination'),
            ),
            value: destination,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              if (!mounted) return;
              setState(() {
                destination = newValue;
                Future.delayed(Duration(milliseconds: 500), () {
                  _getTHSRSchedule();
                });
              });
            },
            items: _thsrStations.keys
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return allTranslations.text('Destination cannot be empty');
              }
              return null;
            },
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

          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              icon: Icon(Icons.train),
              hintText: allTranslations.text('Please enter Car Number'),
              labelText: allTranslations.text('Car Number'),
            ),
            value: car_number,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              if (!mounted) return;
              setState(() {
                car_number = newValue;
              });
            },
            items: <String>[
              '1',
              '2',
              '3',
              '4',
              '5',
              '6',
              '7',
              '8',
              '9',
              '10',
              '11',
              '12'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return allTranslations.text('Car Number cannot be empty');
              }
              return null;
            },
          ),

          //-----------datetime from------------------
          DateTimeField(
            initialValue: departure_time,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              hintText:
                  allTranslations.text('Please enter Estimate Departure Time'),
              labelText: allTranslations.text('Estimate Departure Time'),
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
                _getTHSRSchedule();
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            // onSaved: (val) => departure_time = val,
            onChanged: (DateTime newValue) {
              if (!mounted) return;
              setState(() {
                departure_time = newValue;
                Future.delayed(Duration(milliseconds: 500), () {
                  _getTHSRSchedule();
                });
              });
            },
            validator: (value) {
              if (value == null) {
                return allTranslations
                    .text('Estimate Departure Time cannot be empty');
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
            onSaved: (val) => note = val,
          ),
          SizedBox(height: 20),

          SearchableDropdown.single(
            label: Text(allTranslations.text('Train No.')),
            hint: Text(allTranslations.text('Please enter Train No.')),
            value: submitTHSRTrainNo,
            items:
                _thsrDropdownList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value +
                    '    ' +
                    DateFormat('MM/dd    HH:mm')
                        .format((_thsrDropdownMap[value].datetime_from)) +
                    ' - ' +
                    DateFormat('HH:mm')
                        .format(_thsrDropdownMap[value].datetime_to)),
              );
            }).toList(),
            onChanged: (String newValue) {
              if (!mounted) return;
              setState(() {
                submitTHSRTrainNo = newValue;
              });
            },
            isExpanded: true,
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

  Future<void> _getTHSRSchedule() async {
    if ((departure != null) &&
        (destination != null) &&
        (destination != departure) &&
        departure_time != null) {
      var _serviceUrl =
          'https://ptx.transportdata.tw/MOTC/v2/Rail/THSR/DailyTimetable/OD/' +
              _thsrStations[departure] +
              '/to/' +
              _thsrStations[destination] +
              '/' +
              DateFormat('yyyy-MM-dd').format(departure_time) +
              '?\$top=1000&\$format=JSON';
      print(_serviceUrl);
      try {
        final response = await http.get(_serviceUrl,
            headers: MOTC().GetAuthorizationHeader());
        // final response = await http.get(_serviceUrl, headers: {
        //   'Accept':
        //       'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        //   'Accept-Encoding': 'gzip, deflate, br',
        //   'Accept-Language': 'en-US,en;q=0.9,zh-TW;q=0.8,zh;q=0.7',
        //   'Cache-Control': 'max-age=0',
        //   'Connection': 'keep-alive',
        //   'DNT': '1',
        //   'Host': 'ptx.transportdata.tw',
        //   'Sec-Fetch-Dest': 'document',
        //   'Sec-Fetch-Mode': 'navigate',
        //   'Sec-Fetch-Site': 'none',
        //   'Sec-Fetch-User': '?1',
        //   'Upgrade-Insecure-Requests': '1',
        //   'User-Agent':
        //       'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36'
        // });
        print('Response status: ${response.statusCode}');
        // printWrapped('Response body: ${response.body}');
        var data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          submitTHSRTrainNo = null;
          _thsrDropdownList = [];
          _thsrDropdownMap = {};
          for (var thsr_raw in data) {
            if (DateTime.parse(DateFormat('yyyy-MM-dd').format(departure_time) +
                        ' ' +
                        thsr_raw['OriginStopTime']['ArrivalTime'] +
                        ":00")
                    .isBefore(departure_time.subtract(Duration(hours: 2))) ||
                DateTime.parse(DateFormat('yyyy-MM-dd').format(departure_time) +
                        ' ' +
                        thsr_raw['OriginStopTime']['ArrivalTime'] +
                        ":00")
                    .isAfter(departure_time.add(Duration(hours: 2)))) {
              continue;
            }
            var tmp = THSR();
            tmp.trainNo = thsr_raw['DailyTrainInfo']['TrainNo'];
            tmp.direction = thsr_raw['DailyTrainInfo']['Direction'];
            tmp.departure = thsr_raw['OriginStopTime']['StationName']['Zh_tw'] +
                ' ' +
                thsr_raw['OriginStopTime']['StationName']['En'];
            tmp.destination = thsr_raw['DestinationStopTime']['StationName']
                    ['Zh_tw'] +
                ' ' +
                thsr_raw['DestinationStopTime']['StationName']['En'];
            tmp.datetime_from = DateTime.parse(
                DateFormat('yyyy-MM-dd').format(departure_time) +
                    ' ' +
                    thsr_raw['OriginStopTime']['ArrivalTime'] +
                    ":00");
            tmp.datetime_to = DateTime.parse(
                DateFormat('yyyy-MM-dd').format(departure_time) +
                    ' ' +
                    thsr_raw['DestinationStopTime']['DepartureTime'] +
                    ":00");
            _thsrDropdownMap[tmp.trainNo] = tmp;
            _thsrDropdownList.add(tmp.trainNo);
          }
        });
        _thsrDropdownList.sort((a, b) => _thsrDropdownMap[a]
            .datetime_from
            .compareTo(_thsrDropdownMap[b].datetime_from));
        print(_thsrDropdownList);
      } catch (e) {
        print('Server Exception!!!');
        print(e);
        return null;
      }
    }
  }

  void _submitFavoriteStations() {
    if (departure == null || destination == null) {
      showMessage(
          allTranslations.text('Please enter Departure and Destination.'));
    } else {
      THSRService().addFavorite(departure, destination);
      showMessage(
          "${departure + ' - ' + destination} ${allTranslations.text('is added to favorite stations.')}",
          Colors.blue);
    }
  }

  void _submitForm() {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return;
    } else {
      THSR submitTHSR;
      if (submitTHSRTrainNo != null) {
        submitTHSR = _thsrDropdownMap[submitTHSRTrainNo];
      } else {
        submitTHSR = THSR();
        submitTHSR.trainNo = '';
        submitTHSR.datetime_from = departure_time;
        submitTHSR.datetime_to = departure_time;
        submitTHSR.departure = departure;
        submitTHSR.destination = destination;
      }
      submitTHSR.note = (note == null) ? '' : note;
      submitTHSR.car_number = car_number;

      THSRService().createTHSR(submitTHSR);
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
