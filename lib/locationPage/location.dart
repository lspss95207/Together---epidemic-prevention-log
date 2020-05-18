import 'dart:convert';
import 'package:intl/intl.dart';

class Location {
  String id;
  String local_id;
  String location_name;
  String address;
  String type;
  double latitude;
  double longitude;
  DateTime datetime_from;
  DateTime datetime_to;
  String note = '';
  int infection_level = 0;

  String toJson() {
    var map = {};
    map['id'] = id;
    map['local_id'] = local_id;
    map['location_name'] = location_name;
    map['address'] = address;
    map['latitude'] = latitude.toString();
    map['longitude'] = longitude.toString();
    map['datetime_from'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime_from);
    map['datetime_to'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime_to);
    map['type'] = type;
    map['note'] = note;
    
    var json = jsonEncode(map);
    return json;
  }
    void setFromMap(Map map){
    id = map['id'];
    local_id = map['local_id'];
    location_name =  map['location_name'];
    address = map['address'];
    latitude = double.tryParse(map['latitude']);
    longitude = double.tryParse(map['longitude']);
    datetime_from = DateTime.parse(map['datetime_from']);
    datetime_to = DateTime.parse(map['datetime_to']);
    type = map['type'];
    note = map['note']??'';
  }

}