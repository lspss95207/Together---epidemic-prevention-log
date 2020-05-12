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
import 'package:virus_tracker/trPage/tr.dart';
import 'package:virus_tracker/trPage/trService.dart';
import 'package:virus_tracker/trPage/trFav.dart';

import 'package:dropdownfield/dropdownfield.dart';

import 'package:virus_tracker/globals.dart' as globals;
import 'package:virus_tracker/all_translations.dart';

class TRForm extends StatefulWidget {
  @override
  final String departure;
  final String destination;

  const TRForm(this.departure, this.destination);

  State createState() => TRFormState();
}

class TRFormState extends State<TRForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, dynamic> _trStations = {};

  List<String> _departureStationList = [];
  List<String> _destinationStationList = [];

  List<String> _cityList = [
    '全部All',
    '臺北市Taipei',
    '新北市NewTaipei',
    '桃園市Taoyuan',
    '臺中市Taichung',
    '臺南市Tainan',
    '高雄市Kaohsiung',
    '基隆市Keelung',
    '新竹市Hsinchu',
    '新竹縣HsinchuCounty',
    '苗栗縣MiaoliCounty',
    '彰化縣ChanghuaCounty',
    '南投縣NantouCounty',
    '雲林縣YunlinCounty',
    '嘉義縣ChiayiCounty',
    '嘉義市Chiayi',
    '屏東縣PingtungCounty',
    '宜蘭縣YilanCounty',
    '花蓮縣HualienCounty',
    '臺東縣TaitungCounty',
    '金門縣KinmenCounty',
    '澎湖縣PenghuCounty',
    '連江縣LienchiangCounty'
  ];

  String departure;
  String departure_city;
  String destination;
  String destination_city;
  DateTime departure_time;
  String car_number;
  String submitTRTrainNo;
  String note;

  Map<String, TR> _trDropdownMap = {};
  List<String> _trDropdownList = [];

  void initState() {
    super.initState();
    _readTRStations();
    departure_time = DateTime.now();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _destinationStationList = [];
        _trStations.forEach((key, value) {
          _departureStationList.add(key);
          _destinationStationList.add(key);
        });
      });

      departure = widget.departure;
      destination = widget.destination;

      if (departure != null && destination != null) {
        departure_city = '全部All';
        destination_city = '全部All';
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        _gettrSchedule();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('Add Taiwan Railways')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/TRList', ModalRoute.withName('/home'));
          },
        ),
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
                child: Text(allTranslations.text('Favorite Stations')),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => TRFav()));
                },
              ),
            ),
          ),

          //-----------stations------------------
          Row(children: <Widget>[
            Flexible(
              child: SearchableDropdown.single(
                label: Text(
                  allTranslations.text('Departure City'),
                ),
                hint: Text(allTranslations.text('Please enter Departure City')),
                value: departure_city,
                items: _cityList.map((item) {
                  return DropdownMenuItem(child: Text(item), value: item);
                }).toList(),
                onChanged: (dynamic newValue) {
                  departure_city = newValue;
                  setState(() {
                    _departureStationList = [];
                    departure = null;
                    _trStations.forEach((key, value) {
                      if (departure_city == '全部All' ||
                          departure_city == value['City']) {
                        _departureStationList.add(key);
                      }
                    });
                  });
                },
                onClear: () {
                  setState(() {
                    _departureStationList = [''];
                    departure = '';
                    _trDropdownList = [''];
                    submitTRTrainNo = '';
                  });
                },
                isExpanded: true,
                displayClearIcon: false,
              ),
            ),
            Flexible(
              child: SearchableDropdown.single(
                label: Text(allTranslations.text('Departure')),
                hint: Text(allTranslations.text('Please enter Departure')),
                value: departure,
                items: _departureStationList.map((item) {
                  return DropdownMenuItem(child: Text(item), value: item);
                }).toList(),
                onChanged: (dynamic newValue) {
                  departure = newValue;
                  submitTRTrainNo = '';
                  setState(() {
                    _gettrSchedule();
                  });
                },
                isExpanded: true,
                onClear: () {
                  _trDropdownList = [''];
                  submitTRTrainNo = '';
                },
                displayClearIcon: false,
              ),
            )
          ]),
          Row(children: <Widget>[
            Flexible(
              child: SearchableDropdown.single(
                label: Text(
                  allTranslations.text('Destination City'),
                ),
                hint:
                    Text(allTranslations.text('Please enter Destination City')),
                value: destination_city,
                items: _cityList.map((item) {
                  return DropdownMenuItem(child: Text(item), value: item);
                }).toList(),
                onChanged: (dynamic newValue) {
                  destination_city = newValue;
                  destination = null;
                  setState(() {
                    _destinationStationList = [];
                    _trStations.forEach((key, value) {
                      if (destination_city == '全部All' ||
                          destination_city == value['City']) {
                        _destinationStationList.add(key);
                      }
                    });
                  });
                },
                isExpanded: true,
                onClear: () {
                  setState(() {
                    _destinationStationList = [''];
                    departure = '';
                    _trDropdownList = [''];
                    submitTRTrainNo = '';
                  });
                },
                displayClearIcon: false,
              ),
            ),
            Flexible(
              child: SearchableDropdown.single(
                label: Text(allTranslations.text('Destination')),
                hint: Text(allTranslations.text('Please enter Destination')),
                value: destination,
                items: _destinationStationList.map((item) {
                  return DropdownMenuItem(child: Text(item), value: item);
                }).toList(),
                onChanged: (dynamic newValue) {
                  destination = newValue;
                  submitTRTrainNo = '';
                  setState(() {
                    _gettrSchedule();
                  });
                },
                isExpanded: true,
                onClear: () {
                  _trDropdownList = [''];
                  submitTRTrainNo = '';
                },
                displayClearIcon: false,
              ),
            )
          ]),

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
              if (value.isEmpty) {
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
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
            onSaved: (val) => departure_time = val,
            onChanged: (DateTime newValue) {
              setState(() {
                departure_time = newValue;
                if (departure_time.hour == 0 &&
                    departure_time.minute == 0 &&
                    departure_time.second == 0) {
                  departure_time.add(Duration(seconds: 1));
                }
                Future.delayed(Duration(milliseconds: 500), () {
                  _gettrSchedule();
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
            value: submitTRTrainNo,
            items:
                _trDropdownList.map<DropdownMenuItem<String>>((String value) {
              if (value == null || value == '' || value.isEmpty) {
                DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }
              return DropdownMenuItem<String>(
                value: value,
                child: (_trDropdownMap[value] == null)
                    ? Text('')
                    : Text(_trDropdownMap[value].trainType.substring(0, 2) +
                        '   ' +
                        value +
                        '    ' +
                        DateFormat('MM-dd    HH:mm')
                            .format((_trDropdownMap[value].datetime_from)) +
                        ' - ' +
                        DateFormat('HH:mm')
                            .format(_trDropdownMap[value].datetime_to)),
              );
            }).toList(),
            displayClearIcon: false,
            onChanged: (String newValue) {
              if (!mounted) return;
              setState(() {
                submitTRTrainNo = newValue;
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

  void _readTRStations() async {
    var data = await rootBundle.loadString('assets/trStations.json');
    print(data);
    final station_raw = json.decode(data);
    setState(() {
      for (var station in station_raw) {
        _trStations[station['StationName']['Zh_tw'] +
            ' ' +
            station['StationName']['En']] = station;
      }
    });

    print(_trStations);
  }

  Future<void> _gettrSchedule() async {
    // submittrTrainNo = '';
    print(departure);
    print(destination);
    if ((departure != null) &&
        (destination != null) &&
        (destination != departure) &&
        departure_time != null) {
      var _serviceUrl =
          'https://ptx.transportdata.tw/MOTC/v2/Rail/TRA/DailyTimetable/OD/' +
              _trStations[departure]['StationID'] +
              '/to/' +
              _trStations[destination]['StationID'] +
              '/' +
              DateFormat('yyyy-MM-dd').format(departure_time) +
              '?\$top=1000&\$format=JSON';
      // print(_serviceUrl);
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
        // print('Response status: ${response.statusCode}');
        // printWrapped('Response body: ${response.body}');
        var data = jsonDecode(response.body);
        setState(() {
          // print(DateFormat('yyyy-MM-dd').format(departure_time));

          _trDropdownList = [];
          _trDropdownMap = {};
          for (var tr_raw in data) {
            if (DateTime.parse(DateFormat('yyyy-MM-dd').format(departure_time) +
                        ' ' +
                        tr_raw['OriginStopTime']['ArrivalTime'] +
                        ":00")
                    .isBefore(departure_time.subtract(Duration(hours: 2))) ||
                DateTime.parse(DateFormat('yyyy-MM-dd').format(departure_time) +
                        ' ' +
                        tr_raw['OriginStopTime']['ArrivalTime'] +
                        ":00")
                    .isAfter(departure_time.add(Duration(hours: 2)))) {
              continue;
            }
            var tmp = TR();
            tmp.trainNo = tr_raw['DailyTrainInfo']['TrainNo'];
            tmp.trainType = tr_raw['DailyTrainInfo']['TrainTypeName']['Zh_tw'] +
                ' ' +
                tr_raw['DailyTrainInfo']['TrainTypeName']['En'];
            tmp.direction = tr_raw['DailyTrainInfo']['Direction'];
            tmp.departure = tr_raw['OriginStopTime']['StationName']['Zh_tw'] +
                ' ' +
                tr_raw['OriginStopTime']['StationName']['En'];
            tmp.destination = tr_raw['DestinationStopTime']['StationName']
                    ['Zh_tw'] +
                ' ' +
                tr_raw['DestinationStopTime']['StationName']['En'];
            tmp.datetime_from = DateTime.parse(
                DateFormat('yyyy-MM-dd').format(departure_time) +
                    ' ' +
                    tr_raw['OriginStopTime']['ArrivalTime'] +
                    ":00");
            tmp.datetime_to = DateTime.parse(
                DateFormat('yyyy-MM-dd').format(departure_time) +
                    ' ' +
                    tr_raw['DestinationStopTime']['DepartureTime'] +
                    ":00");
            _trDropdownMap[tmp.trainNo] = tmp;
            _trDropdownList.add(tmp.trainNo);
          }
        });
        _trDropdownList.sort((a, b) => _trDropdownMap[a]
            .datetime_from
            .compareTo(_trDropdownMap[b].datetime_from));
        // print(_trDropdownList);
        if (_trDropdownList.isEmpty) {
          _trDropdownList = [''];
        }
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
      TRService().addFavorite(departure, destination);
      showMessage(
          '${departure + ' - ' + destination} ${allTranslations.text('is added to favorite stations.')}',
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
      TR submitTR;
      if (submitTRTrainNo == null || submitTRTrainNo == '') {
        submitTR = TR();
        submitTR.trainNo = '';
        submitTR.datetime_from = departure_time;
        submitTR.datetime_to = departure_time;
        submitTR.departure = departure;
        submitTR.destination = destination;
      } else {
        submitTR = _trDropdownMap[submitTRTrainNo];
      }

      submitTR.note = (note == null) ? '' : note;
      print(submitTR.note);
      submitTR.car_number = car_number;

      TRService().createTR(submitTR);
      // Navigator.pushReplacementNamed(context, '/TRList');
      Navigator.pushNamedAndRemoveUntil(
          context, '/TRList', ModalRoute.withName('/home'));
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
