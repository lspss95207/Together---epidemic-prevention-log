import 'dart:convert';
import 'package:intl/intl.dart';

class THSR {
  String id;
  String local_id;
  String trainNo;
  int direction;
  String departure;
  String destination;
  DateTime datetime_from;
  DateTime datetime_to; 
  String car_number;
  String note;
  int infection_level = 0;


  String toJson() {
    var map = {};
    map['id'] = id;
    map['local_id'] = local_id;
    map['trainNo'] = trainNo;
    map['direction'] = direction;
    map['departure'] = departure;
    map['destination'] = destination;
    map['datetime_from'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime_from);
    map['datetime_to'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime_to);
    map['car_number'] = car_number;
    map['note'] = note;
    
    var json = jsonEncode(map);
    return json;
  }

  void setFromMap(Map map){
    id = map['id'];
    local_id = map['local_id'];
    trainNo = map['trainNo'];
    direction =  map['direction'];
    departure = map['departure'];
    destination = map['destination'];
    datetime_from = DateTime.parse(map['datetime_from']);
    datetime_to = DateTime.parse(map['datetime_to']);
    car_number = map['car_number'];
    note = map['note'];
  }
}