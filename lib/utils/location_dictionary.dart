/*
  This class handles the backend location-based features of the application
  Author: Freya Archuleta
  Created on: 03/13/2024
  Modified on: 03/21/2024 by Freya Archuleta
  Modified on: 03/27/2024 by Freya Archuleta
  Modified on: 04/06/2024 by Omar Nweashe
  Modified on: 04/07/2024 by Kyle Takeuchi
  Modified on: 04/07/2024 by Omar Nweashe
*/
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

Map<String, List<String>> streetNameDictionary = {}; 
bool trackingStatus = false;
Position? latlon;

/*
  Function that erases the location dict if the locations permissions are not set
*/
Future<void> eraseDictionary() async {
  streetNameDictionary = {};
}

/*
  The function handles setting the appropriate values if location permissions are on/off
*/
Future<void> updateStreetNameDictionary() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever ||
      permission == LocationPermission.denied) {
    streetNameDictionary = {};
    return;
  }

  try {
    latlon = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);

  } catch (e) {
    log("Error getting location data: $e", error: e);
  }
}

/* 
  Used for logging
*/
void splitLog(String message) {
  const chunkSize = 90;
  final length = message.length;
  for (int i = 0; i < length; i += chunkSize) {
    final chunk =
        message.substring(i, i + chunkSize < length ? i + chunkSize : length);
    log(chunk);
  }
}

/*
  This function handles getting the 5 street name alternatives to a given word, for better context.
*/
Future<void> updateStreetNameDictionaryWithOSM(String arabicWord) async {
  // Query that includes the Arabic word that is to be searched in the DB
  String query = '''
  [out:json];
  (
    node["name:ar"="$arabicWord"];
  );
  out body;
  >;
  ''';

  String url = 'http://overpass-api.de/api/interpreter';

  try {
    // Send the request to the Overpass API
    var response = await http.post(Uri.parse(url), headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: {'data': query});

    if (response.statusCode == 200) {
      // Decode JSON response in UTF8 to ensure Arabic characters are visible
      var decodedData = utf8.decode(response.bodyBytes);
      var data = jsonDecode(decodedData);

      streetNameDictionary.clear(); // clear existing dictionary (if any)

      if (data['elements'] != null) {
        int totalEntriesCount = 0;
        for (var element in data['elements']) {
          if (totalEntriesCount >= 5) {
            break; // stop the loop if 5 entries have been added to dict
          }
          var tags = element['tags'];
          var arabicName = tags['name:ar'];
          var englishName = tags['name:en'];

          if (arabicName != null && englishName != null) {
            // Update the dictionary with the Arabic name (there will be one key)
            // and a list of English names (5 entries) as the values (helps improve context for user by giving multiple)
            streetNameDictionary.putIfAbsent(arabicName, () => []).add(englishName);

            totalEntriesCount++;
          }
        }
        splitLog('Updated Street Name Dictionary with OSM Data: $streetNameDictionary');
      } else {
        log('No matching elements found in OSM data.');
      }
    } else {
      // Handle HTTP errors
      log('Failed to load OSM data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any errors that occur during the HTTP request
    log('Error fetching OSM data: $e', error: e);
  }
}