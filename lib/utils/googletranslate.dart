/*
  This file holds the main backend functionality for the Amazon translation API calls the app makes
  Created by: Nathaniel Sianipar
  Created on: 02/20/2024
  Modified on: 02/20/2024 by Nathaniel Sianipar
  Modified on: 02/27/2024 by Nathaniel Sianipar
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 04/03/2024 by Omar Nweashe
  Modified on: 04/24/2024 by Kyle Takeuchi
  Modified on: 04/26/2024 by Nathaniel Sianipar

  
*/


import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

class GoogleTranslateService 
{
  String? accessToken;
  DateTime? tokenExpirationTime;
  /* 
    Function to get the access token needed to access Google translation API
  */
  Future<String> getAccessToken() async {
    // Load your service account credentials
    try
    {

      if (accessToken != null && tokenExpirationTime != null && DateTime.now().isBefore(tokenExpirationTime!))
      {
        dev.log('Access token is still valid. Expiration time: $tokenExpirationTime');
        return accessToken!;
      }
      else
      {
        final credentials = ServiceAccountCredentials.fromJson({
        // Insert your service account JSON here
        "client_id": //INSERT ID HERE,
        "private_key_id": //INSERT KEY HERE,
        "private_key": //INSERT KEY HERE,
        "client_email": //INSERT EMAIL HERE,
        "type": "service_account"
        });

        final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
          credentials,
          [
            'https://www.googleapis.com/auth/cloud-platform',
          ],
          http.Client(),
        );
      
        accessToken = accessCredentials.accessToken.data;
        tokenExpirationTime = accessCredentials.accessToken.expiry;


        return accessToken!;
      }

    }

    catch(e)
    {
      dev.log('Error obtaining access token: $e');
      throw 'Error obtaining access token: $e';
    }
  }
  /* 
    Function that handles directly calling Google Translation API, returns the Google translation
  */
  Future<String> translateText(String targetLang, String rawText, String apiKey) async
  {

      final String accessToken = await getAccessToken();
      Map<String, dynamic> requestBody = 
      {
        'contents': [rawText],
        'targetLanguageCode': targetLang,
      };

      String jsonBody = jsonEncode(requestBody);

      http.Response finalres = await http.post(
        Uri.parse(
          'https://translate.googleapis.com/v3/projects/caramel-galaxy-405920:translateText?key=$apiKey'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (finalres.statusCode == 200)
      {
        Map<String, dynamic> responseData = jsonDecode(finalres.body);

        // Handle the translated text
        List<dynamic> translations = responseData['translations'];
        if (translations.isNotEmpty) {
          String translatedText = '${translations.first['translatedText']}';
          Map<String, String> htmlEntities = {
            '&amp;': '&',
            '&lt;': '<',
            '&gt;': '>',
            '&quot;': '"',
            '&#39;': '\'',
            '&#34;': '"',
            '&#60;': '<',
            '&#62;': '>',
          };

          translatedText = translatedText.replaceAllMapped(
            RegExp('(&#?[a-zA-Z0-9]+;)'),
            (Match match) {
              var entity = match.group(0);
              return htmlEntities[entity] ?? '';
            },
          );
          return translatedText;
          //print('Translated text: ${translations.first['translatedText']}');
        } else {
          return 'Translation not available';
        }
      } 
      else
      {
        //print('Failed to translate text. Status code: ${finalres.statusCode}');
        return "Error translating text";
      }
  }

}



  // void main() async {
  //   String credentialsPath = 'C:/caramel-galaxy-405920-3ff6e1ffda74.json';


  //   String textToTranslate = 'هذا اختبار لمعرفة ما إذا كان الكود يعمل أم لا';
  //   String targetLanguage = 'en';

  //   final String apiKey = 'AIzaSyDPdAYpc1P5E9DhEmXgLs5epv7mc5CxNcA';


  //   String finalres = await translateText(targetLanguage, textToTranslate, apiKey);

  //   print("GOOGLE TRANSLATION: $finalres");
  // }