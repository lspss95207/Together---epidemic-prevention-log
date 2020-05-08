import 'dart:convert';
import 'package:intl/intl.dart';

class Metro {
  String id;
  String local_id;
  String departure;
  String destination;
  DateTime datetime_from;
  DateTime datetime_to;
  String note;
  int infection_level = 0;

  String toJson() {
    var map = {};
    map['id'] = id;
    map['local_id'] = local_id;
    map['departure'] = departure;
    map['destination'] = destination;
    map['datetime_from'] =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime_from);
    map['datetime_to'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(datetime_to);
    map['note'] = note;

    var json = jsonEncode(map);
    return json;
  }

  void setFromMap(Map map) {
    id = map['id'];
    local_id = map['local_id'];
    departure = map['departure'];
    destination = map['destination'];
    datetime_from = DateTime.parse(map['datetime_from']);
    datetime_to = DateTime.parse(map['datetime_to']);
    note = map['note'];
  }
}
