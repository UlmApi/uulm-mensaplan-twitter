// MIT License (C) 2016 UlmAPI

import 'dart:core';
import 'dart:convert';
import 'dart:io';

import 'package:twitter/twitter.dart';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

main(List<String> args) async {

  var places = ["Mensa", "Bistro", "CB", "West", "Prittwitzstr"];
  var url = 'https://www.uni-ulm.de/mensaplan/data/mensaplan.json';

  var _authFile = new File("./twitter_auth.yaml");
  var _auth = await _authFile.readAsString();
  _auth = loadYaml(_auth);

  var response = await http.get(url);

  var decoded = JSON.decode(response.body);
  
  DateTime day = new DateTime.now();
  String today = "${day.year}-${addZero(day.month)}-${addZero(day.day)}";
  
  for (var day in decoded['weeks'][0]['days']) {
    if (day["date"] == today) {

      for (var place in places) {

        for (var meal in day[place]["meals"]) {

          String tweet = "$place: ${meal['category']}: ${meal['meal']}";

          if (tweet.length > 139) {
            tweet = tweet.substring(0,139);
          }

          Twitter _twitter = new Twitter.fromMap(_auth);

          Map _body = {
            "status" : tweet
          };

          var _response = await _twitter.request("POST", "statuses/update.json", body: _body);

          JsonDecoder _decoder  = new JsonDecoder();
          var _jsonResponse = _decoder.convert(_response.body);
          print(_jsonResponse["text"]);

        }
      }
    }
  }

}

int addZero(int number) {
  if (number < 10) {
    return "0$number";
  } else {
    return number;
  }
}
