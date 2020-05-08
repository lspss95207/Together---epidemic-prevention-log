import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import 'location.dart';

class LocationService {
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

  Future<List<Location>> createLocation(Location location) async {
    // List<Location> locationList = await getLocation();
    List<Location> locationList = globals.locationList;
    location.local_id = locationList.length.toString();
    locationList.add(location);

    String jsonString = '[\n';
    locationList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    final jsonfile = await _localFile('locationData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getLocation();
    globals.locationList = locationList;
    return locationList;
  }

  Future<List<Location>> getLocation() async {
    List<Location> locationList = [];
    final jsonfile = await _localFile('locationData.json');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    int index = 0;
    for (var item in json) {
      Location input = Location();
      item['local_id'] = index.toString();
      index++;

      input.setFromMap(item);
      if(globals.delete21 && input.datetime_from.isBefore(DateTime.now().subtract(Duration(days: 21)))){
        continue;
      }

      locationList.add(input);
    }
    String jsonString = '[\n';
    locationList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';
    await jsonfile.writeAsString(jsonString);

    print(locationList);
    locationList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.locationList = locationList;
    return locationList;
  }

  Future<void> deleteLocation(Location location) async {
    globals.locationList.remove(location);

    var jsonString = '[\n';

    globals.locationList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if (globals.locationList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('locationData.json');
    await jsonfile.writeAsString(jsonString);
  }

  Future<void> addFavorite(
      double latitude_d, double longitude_d, String location_name) async {
    String latitude = latitude_d.toString();
    String longitude = longitude_d.toString();

    List<Map<String, String>> locationFavList = globals.locationFavList;
    bool repeat = false;
    locationFavList.forEach((element) {
      if (element['latitude'] == latitude &&
          element['longitude'] == longitude &&
          element['location_name'] == location_name) {
        repeat = true;
      }
    });
    if (repeat == false) {
      locationFavList.add({
        'latitude': latitude,
        'longitude': longitude,
        'location_name': location_name
      });

      String jsonString = '[\n';
      locationFavList.forEach((element) {
        jsonString += '{\n"latitude": "' + element['latitude'] + '",\n';
        jsonString += '\n"longitude": "' + element['longitude'] + '",\n';
        jsonString +=
            '"location_name": "' + element['location_name'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      // print(jsonString);

      final jsonfile = await _localFile('locationFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.locationFavList = locationFavList;
    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('locationFavData.json');
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
      input['location_name'] = item['location_name'];
      
      favList.add(input);
    }
    globals.locationFavList = favList;
    // print(favList);
    return favList;
  }

  Future<void> deleteFavorite(Map<String, String> stations) async {
    globals.locationFavList.remove(stations);

    String jsonString = '[\n';
    globals.locationFavList.forEach((element) {
      jsonString += '{\n"latitude": "' + element['latitude'] + '",\n';
      jsonString += '{\n"longitude": "' + element['longitude'] + '",\n';
      jsonString += '"location_name": "' + element['location_name'] + '"\n},\n';
    });
    if (globals.locationFavList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('locationFavData.json');
    await jsonfile.writeAsString(jsonString);
  }
}
