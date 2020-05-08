import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import 'taxi.dart';

class TaxiService {
  static const _serviceUrl = 'https://lspss95207.duckdns.org/query.php';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(String filename) async {
    // final path = await _localPath;
    final path = (await getApplicationDocumentsDirectory()).path;
    if (!await File(path + '/' + filename).exists()) {
      await File(path + '/' + filename).create();
    }
    ;
    return File('$path/$filename');
  }

  Future<List<Taxi>> createTaxi(Taxi taxi) async {
    // List<Taxi> taxiList = await getTaxi();
    List<Taxi> taxiList = globals.taxiList;
    taxi.local_id = taxiList.length.toString();
    taxiList.add(taxi);

    String jsonString = '[\n';
    taxiList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    final jsonfile = await _localFile('taxiData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getTaxi();
    globals.taxiList = taxiList;
    return taxiList;
  }

  Future<List<Taxi>> getTaxi() async {
    List<Taxi> taxiList = [];
    final jsonfile = await _localFile('taxiData.json');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    int index = 0;
    for (var item in json) {
      Taxi input = Taxi();
      item['local_id'] = index.toString();
      index++;

      input.setFromMap(item);
      if (globals.delete21 &&
          input.datetime_from
              .isBefore(DateTime.now().subtract(Duration(days: 21)))) {
        continue;
      }
      taxiList.add(input);
    }
    String jsonString = '[\n';
    taxiList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    await jsonfile.writeAsString(jsonString);

    taxiList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.taxiList = taxiList;
    return taxiList;
  }

  Future<void> deleteTaxi(Taxi taxi) async {
    globals.taxiList.remove(taxi);

    var jsonString = '[\n';

    globals.taxiList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if (globals.taxiList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('taxiData.json');
    await jsonfile.writeAsString(jsonString);
  }

  Future<void> addFavorite(
      double latitude_d, double longitude_d, String taxi_name) async {
    String latitude = latitude_d.toString();
    String longitude = longitude_d.toString();

    List<Map<String, String>> taxiFavList = globals.taxiFavList;
    bool repeat = false;
    taxiFavList.forEach((element) {
      if (element['latitude'] == latitude &&
          element['longitude'] == longitude &&
          element['taxi_name'] == taxi_name) {
        repeat = true;
      }
    });
    if (repeat == false) {
      taxiFavList.add({
        'latitude': latitude,
        'longitude': longitude,
        'taxi_name': taxi_name
      });

      String jsonString = '[\n';
      taxiFavList.forEach((element) {
        jsonString += '{\n"latitude": "' + element['latitude'] + '",\n';
        jsonString += '\n"longitude": "' + element['longitude'] + '",\n';
        jsonString += '"taxi_name": "' + element['taxi_name'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      // print(jsonString);

      final jsonfile = await _localFile('taxiFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.taxiFavList = taxiFavList;
    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('taxiFavData.json');
    String json_raw = await jsonfile.readAsString();
    print(json_raw);
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    for (var item in json) {
      var input = <String, String>{};
      input['latitude'] = item['latitude'];
      input['longitude'] = item['longitude'];
      input['taxi_name'] = item['taxi_name'];
      favList.add(input);
    }
    globals.taxiFavList = favList;
    // print(favList);
    return favList;
  }

  Future<void> deleteFavorite(Map<String, String> stations) async {
    globals.taxiFavList.remove(stations);

    String jsonString = '[\n';
    globals.taxiFavList.forEach((element) {
      jsonString += '{\n"latitude": "' + element['latitude'] + '",\n';
      jsonString += '{\n"longitude": "' + element['longitude'] + '",\n';
      jsonString += '"taxi_name": "' + element['taxi_name'] + '"\n},\n';
    });
    if (globals.taxiFavList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('taxiFavData.json');
    await jsonfile.writeAsString(jsonString);
  }
}
