
import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:path_provider/path_provider.dart';

import 'package:virus_tracker/globals.dart' as globals;

import 'bus.dart';

class BusService {
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

  Future<List<Bus>> createBus(Bus bus) async {
    // List<Bus> busList = await getBus();
    List<Bus> busList = globals.busList;
    bus.local_id = busList.length.toString();
    busList.add(bus);

    String jsonString = '[\n';
    busList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';

    final jsonfile = await _localFile('busData.json');
    await jsonfile.writeAsString(jsonString);

    // var list = await getBus();
    globals.busList = busList;
    return busList;
  }

  Future<List<Bus>> getBus() async {
    List<Bus> busList = [];
    final jsonfile = await _localFile('busData.json');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      return [];
    }
    var json = jsonDecode(json_raw);
    int index = 0;
    for (var item in json) {

      Bus input = Bus();
      item['local_id'] = index.toString();
      index++;

      input.setFromMap(item);
      if(globals.delete21 && input.datetime_from.isBefore(DateTime.now().subtract(Duration(days: 21)))){
        continue;
      }
      busList.add(input);
    }
    String jsonString = '[\n';
    busList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    jsonString = jsonString.substring(0, jsonString.length - 2);
    jsonString += ']\n';
    await jsonfile.writeAsString(jsonString);
    
    busList.sort((a, b) => a.datetime_from.compareTo(b.datetime_from));
    globals.busList = busList;
    return busList;
  }

  Future<void> deleteBus(Bus bus) async {
    globals.busList.remove(bus);

    var jsonString = '[\n';

    globals.busList.forEach((element) {
      jsonString += element.toJson() + ',\n';
    });
    if(globals.busList.isNotEmpty){
        jsonString = jsonString.substring(0, jsonString.length - 2);
    }
    jsonString += ']\n';

    final jsonfile = await _localFile('busData.json');
    await jsonfile.writeAsString(jsonString);
  }



  Future<void> addFavorite(String city, String route) async {
    List<Map<String, String>> busFavList = globals.busFavList;
    bool repeat = false;
    busFavList.forEach((element) {
      if (element['city'] == city &&
          element['route'] == route) {
        repeat = true;
      }
    });
    if (repeat == false) {
      busFavList.add({'city': city, 'route': route});

      String jsonString = '[\n';
      busFavList.forEach((element) {
        jsonString += '{\n"city": "' + element['city'] + '",\n';
        jsonString += '"route": "' + element['route'] + '"\n},\n';
      });
      jsonString = jsonString.substring(0, jsonString.length - 2);
      jsonString += ']\n';

      print(jsonString);

      final jsonfile = await _localFile('busFavData.json');
      await jsonfile.writeAsString(jsonString);
      globals.busFavList = busFavList;

      getFavorite();

    }
  }

  Future<List<Map<String, String>>> getFavorite() async {
    var favList = <Map<String, String>>[];
    final jsonfile = await _localFile('busFavData.json');
    // await jsonfile.writeAsString('');
    String json_raw = await jsonfile.readAsString();
    if (json_raw == '') {
      globals.busFavList = [];
      return [];
    }
    var json = jsonDecode(json_raw);
    for (var item in json) {
      var input = <String, String>{};
      input['city'] = item['city'];
      input['route'] = item['route'];
      favList.add(input);
    }
    globals.busFavList = favList;
    print(favList);
    return favList;
  }


  Future<void> deleteFavorite(Map<String, String> route) async {
    globals.busFavList.remove(route);

      String jsonString = '[\n';
      globals.busFavList.forEach((element) {
        jsonString += '{\n"city": "' + element['city'] + '",\n';
        jsonString += '"route": "' + element['route'] + '"\n},\n';
      });
      if(globals.busFavList.isNotEmpty){
        jsonString = jsonString.substring(0, jsonString.length - 2);
      }
      jsonString += ']\n';

    final jsonfile = await _localFile('busFavData.json');
    await jsonfile.writeAsString(jsonString);
  }

}
