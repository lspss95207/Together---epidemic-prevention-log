import 'dart:core';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

class MOTC{
  final AppID = '2210eb091b494ee1b7bf26ee22163ea5';
  final AppKey = 'O__zi2OOZNRGryM2tuDdK3CBsiE';

  Map<String, String> GetAuthorizationHeader(){
    var GMTString = DateFormat('E, dd MMM y HH:mm:ss').format(DateTime.now().toUtc()) + ' GMT';
    print(GMTString);

    var key = utf8.encode(AppKey);
    var bytes = utf8.encode('x-date: ' + GMTString);

    var hmacSha1 = new Hmac(sha1, key);
    var HMAC = hmacSha1.convert(bytes);
    var B64 = base64.encode(HMAC.bytes);

    var Authorization = 'hmac username=\"' + AppID + '\", algorithm=\"hmac-sha1\", headers=\"x-date\", signature=\"' + B64 + '\"';
    return { 'Authorization': Authorization, 'X-Date': GMTString /*,'Accept-Encoding': 'gzip'*/};
  }
}