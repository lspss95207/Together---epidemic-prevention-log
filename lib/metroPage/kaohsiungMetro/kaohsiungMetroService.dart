import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import '../metro.dart';

class KaohsiungMetroService {
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

  Future<List<Metro>> createMetro(Metro metro) async {
    // List<Metro> kaohsiungMetroList = await getMetro();
    List<Metro> kaohsiungMetroList = globals.kaohsiungMetroList;
    metro.local_id = kaohsiungMetroList.length.toString();
    kaohsiungMetroList.add(metro);

    String jsonString = '[\n';
    kaohsiungMetroList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    // print(jsonString);

    final jsonfile = await _localFile('kaohsiungMetroData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getMetro();
    globals.kaohsiungMetroList = kaohsiungMetroList;
    return kaohsiungMetroList;
  }

  Future<List<Metro>> getMetro() async {
    List<Metro> kaohsiungMetroList = [];
    final jsonfile = await _localFile('kaohsiungMetroData.json');
    // await jsonfile.writeAsString('');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    // print(json_raw);
    var json = jsonDecode(json_raw);
    int index = 0;
    for (var item in json) {
      Metro input = Metro();
      item['local_id'] = index.toString();
      index++;

      input.setFromMap(item);
      print('service:' + input.toJson());
      if (globals.delete21 &&
          input.datetime_from
              .isBefore(DateTime.now().subtract(Duration(days: 21)))) {
        continue;
      }
      kaohsiungMetroList.add(input);
    }
    String jsonString = '[\n';
    kaohsiungMetroList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    // print(jsonString);
    await jsonfile.writeAsString(jsonString);
    
    kaohsiungMetroList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.kaohsiungMetroList = kaohsiungMetroList;
    return kaohsiungMetroList;
  }

  Future<void> deleteMetro(Metro metro) async {
    globals.kaohsiungMetroList.remove(metro);

    var jsonString = '[\n';

    globals.kaohsiungMetroList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if (globals.kaohsiungMetroList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('kaohsiungMetroData.json');
    await jsonfile.writeAsString(jsonString);
  }

  Future<void> addFavorite(String departure, String destination) async {
    List<Map<String, String>> kaohsiungMetroFavList =
        globals.kaohsiungMetroFavList;
    bool repeat = false;
    kaohsiungMetroFavList.forEach((element) {
      if (element['departure'] == departure &&
          element['destination'] == destination) {
        repeat = true;
      }
    });
    if (repeat == false) {
      kaohsiungMetroFavList
          .add({'departure': departure, 'destination': destination});

      String jsonString = '[\n';
      kaohsiungMetroFavList.forEach((element) {
        jsonString += '{\n"departure": "' + element['departure'] + '",\n';
        jsonString += '"destination": "' + element['destination'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      print(jsonString);

      final jsonfile = await _localFile('kaohsiungMetroFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.kaohsiungMetroFavList = kaohsiungMetroFavList;
    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('kaohsiungMetroFavData.json');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    for (var item in json) {
      var input = <String, String>{};
      input['departure'] = item['departure'];
      input['destination'] = item['destination'];
      favList.add(input);
    }
    globals.kaohsiungMetroFavList = favList;
    // print(favList);
    return favList;
  }

  Future<void> deleteFavorite(Map<String, String> stations) async {
    globals.kaohsiungMetroFavList.remove(stations);

    String jsonString = '[\n';
    globals.kaohsiungMetroFavList.forEach((element) {
      jsonString += '{\n"departure": "' + element['departure'] + '",\n';
      jsonString += '"destination": "' + element['destination'] + '"\n},\n';
    });
    if (globals.kaohsiungMetroFavList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('kaohsiungMetroFavData.json');
    await jsonfile.writeAsString(jsonString);
  }
}
