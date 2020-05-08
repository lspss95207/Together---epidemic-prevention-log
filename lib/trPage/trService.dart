import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import 'tr.dart';

class TRService {
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

  Future<List<TR>> createTR(TR tr) async {
    // List<TR> trList = await getTR();
    List<TR> trList = globals.trList;
    tr.local_id = trList.length.toString();
    trList.add(tr);
    print(tr.trainNo);

    String jsonString = '[\n';
    trList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    final jsonfile = await _localFile('trData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getTR();
    globals.trList = trList;
    return trList;
  }

  Future<List<TR>> getTR() async {
    List<TR> trList = [];
    final jsonfile = await _localFile('trData.json');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    int index = 0;
    for (var item in json) {
      TR input = TR();
      item['local_id'] = index.toString();
      index++;

      input.setFromMap(item);
      if (globals.delete21 &&
          input.datetime_from
              .isBefore(DateTime.now().subtract(Duration(days: 21)))) {
        continue;
      }
      trList.add(input);
    }
    String jsonString = '[\n';
    trList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    await jsonfile.writeAsString(jsonString);

    trList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.trList = trList;
    return trList;
  }

  Future<void> deleteTR(TR tr) async {
    globals.trList.remove(tr);

    var jsonString = '[\n';

    globals.trList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if (globals.trList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('trData.json');
    await jsonfile.writeAsString(jsonString);
  }

  Future<void> addFavorite(String departure, String destination) async {
    List<Map<String, String>> trFavList = globals.trFavList;
    bool repeat = false;
    trFavList.forEach((element) {
      if (element['departure'] == departure &&
          element['destination'] == destination) {
        repeat = true;
      }
    });
    if (repeat == false) {
      trFavList.add({'departure': departure, 'destination': destination});

      String jsonString = '[\n';
      trFavList.forEach((element) {
        jsonString += '{\n"departure": "' + element['departure'] + '",\n';
        jsonString += '"destination": "' + element['destination'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      // print(jsonString);

      final jsonfile = await _localFile('trFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.trFavList = trFavList;
    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('trFavData.json');
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
    globals.trFavList = favList;
    // print(favList);
    return favList;
  }

  Future<void> deleteFavorite(Map<String, String> stations) async {
    globals.trFavList.remove(stations);

    String jsonString = '[\n';
    globals.trFavList.forEach((element) {
      jsonString += '{\n"departure": "' + element['departure'] + '",\n';
      jsonString += '"destination": "' + element['destination'] + '"\n},\n';
    });
    if (globals.trFavList.isNotEmpty) {
      jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('trFavData.json');
    await jsonfile.writeAsString(jsonString);
  }
}
