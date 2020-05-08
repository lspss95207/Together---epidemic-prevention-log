import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import 'thsr.dart';

class THSRService {
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

  Future<List<THSR>> createTHSR(THSR thsr) async {
    // List<THSR> thsrList = await getTHSR();
    List<THSR> thsrList = globals.thsrList;
    thsr.local_id = thsrList.length.toString();
    thsrList.add(thsr);
    print(thsr.trainNo);

    String jsonString = '[\n';
    thsrList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    final jsonfile = await _localFile('thsrData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getTHSR();
    globals.thsrList = thsrList;
    return thsrList;
  }

  Future<List<THSR>> getTHSR() async {
    List<THSR> thsrList = [];
    final jsonfile = await _localFile('thsrData.json');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    int index = 0;
    for (var item in json) {
      THSR input = THSR();
      item['local_id'] = index.toString();
      index++;

      input.setFromMap(item);
      if (globals.delete21 &&
          input.datetime_from
              .isBefore(DateTime.now().subtract(Duration(days: 21)))) {
        continue;
      }
      thsrList.add(input);
    }
    String jsonString = '[\n';
    thsrList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    await jsonfile.writeAsString(jsonString);

    thsrList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.thsrList = thsrList;
    return thsrList;
  }

  Future<void> deleteTHSR(THSR thsr) async {
    globals.thsrList.remove(thsr);

    var jsonString = '[\n';

    globals.thsrList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if (globals.thsrList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('thsrData.json');
    await jsonfile.writeAsString(jsonString);
  }

  Future<void> addFavorite(String departure, String destination) async {
    List<Map<String, String>> thsrFavList = globals.thsrFavList;
    bool repeat = false;
    thsrFavList.forEach((element) {
      if (element['departure'] == departure &&
          element['destination'] == destination) {
        repeat = true;
      }
    });
    if (repeat == false) {
      thsrFavList.add({'departure': departure, 'destination': destination});

      String jsonString = '[\n';
      thsrFavList.forEach((element) {
        jsonString += '{\n"departure": "' + element['departure'] + '",\n';
        jsonString += '"destination": "' + element['destination'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      // print(jsonString);

      final jsonfile = await _localFile('thsrFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.thsrFavList = thsrFavList;
    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('thsrFavData.json');
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
    globals.thsrFavList = favList;
    // print(favList);
    return favList;
  }

  Future<void> deleteFavorite(Map<String, String> stations) async {
    globals.thsrFavList.remove(stations);

    String jsonString = '[\n';
    globals.thsrFavList.forEach((element) {
      jsonString += '{\n"departure": "' + element['departure'] + '",\n';
      jsonString += '"destination": "' + element['destination'] + '"\n},\n';
    });
    if (globals.thsrFavList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('thsrFavData.json');
    await jsonfile.writeAsString(jsonString);
  }
}
