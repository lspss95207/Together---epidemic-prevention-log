import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import '../metro.dart';

class TaipeiMetroService {
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
    // List<Metro> taipeiMetroList = await getMetro();
    List<Metro> taipeiMetroList = globals.taipeiMetroList;
    metro.local_id = taipeiMetroList.length.toString();
    taipeiMetroList.add(metro);

    String jsonString = '[\n';
    taipeiMetroList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    // print(jsonString);

    final jsonfile = await _localFile('taipeiMetroData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getMetro();
    globals.taipeiMetroList = taipeiMetroList;
    return taipeiMetroList;
  }

  Future<List<Metro>> getMetro() async {
    List<Metro> taipeiMetroList = [];
    final jsonfile = await _localFile('taipeiMetroData.json');
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
      taipeiMetroList.add(input);
    }
    String jsonString = '[\n';
    taipeiMetroList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    // print(jsonString);
    await jsonfile.writeAsString(jsonString);

    taipeiMetroList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.taipeiMetroList = taipeiMetroList;
    return taipeiMetroList;
  }

  Future<void> deleteMetro(Metro metro) async {
    globals.taipeiMetroList.remove(metro);

    var jsonString = '[\n';

    globals.taipeiMetroList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if (globals.taipeiMetroList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('taipeiMetroData.json');
    await jsonfile.writeAsString(jsonString);
  }

  Future<void> addFavorite(String departure, String destination) async {
    List<Map<String, String>> taipeiMetroFavList = globals.taipeiMetroFavList;
    bool repeat = false;
    taipeiMetroFavList.forEach((element) {
      if (element['departure'] == departure &&
          element['destination'] == destination) {
        repeat = true;
      }
    });
    if (repeat == false) {
      taipeiMetroFavList
          .add({'departure': departure, 'destination': destination});

      String jsonString = '[\n';
      taipeiMetroFavList.forEach((element) {
        jsonString += '{\n"departure": "' + element['departure'] + '",\n';
        jsonString += '"destination": "' + element['destination'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      print(jsonString);

      final jsonfile = await _localFile('taipeiMetroFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.taipeiMetroFavList = taipeiMetroFavList;
    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('taipeiMetroFavData.json');
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
    globals.taipeiMetroFavList = favList;
    // print(favList);
    return favList;
  }

  Future<void> deleteFavorite(Map<String, String> stations) async {
    globals.taipeiMetroFavList.remove(stations);

    String jsonString = '[\n';
    globals.taipeiMetroFavList.forEach((element) {
      jsonString += '{\n"departure": "' + element['departure'] + '",\n';
      jsonString += '"destination": "' + element['destination'] + '"\n},\n';
    });
    if (globals.taipeiMetroFavList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('taipeiMetroFavData.json');
    await jsonfile.writeAsString(jsonString);
  }
}
