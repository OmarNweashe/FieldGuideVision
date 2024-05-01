/*
  This file holds the main backend functionality for the Microsoft translation API calls the app makes
  Created by: Nathaniel Sianipar
  Created on: 02/20/2024
  Modified on: 02/20/2024 by Nathaniel Sianipar
  Modified on: 02/27/2024 by Nathaniel Sianipar
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 04/25/2024 by Omar Nweashe
  Modified on: 04/26/2024 by Nathaniel Sianipar

  
*/


import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class AzureTranslateService{
  /* 
    Function that handles directly calling Microsoft Translation API, returns the Microsoft translation
  */
    Future<String> translateText(String sourceLang, String targetLang, String rawText) async
    {
        var subscriptionKey = //INSERT KEY HERE;
        var url = Uri.parse("https://api.cognitive.microsofttranslator.com/translate");
        var untranlsatedText = [{'Text': rawText}];

        var queryParams = {
            'api-version': '3.0',
            'from': sourceLang,
            'to': targetLang
        };

        var headers = {
            'Ocp-Apim-Subscription-Key': subscriptionKey,
            'Ocp-Apim-Subscription-Region': 'eastus',
            'Content-Type': 'application/json; charset=UTF-8'
        };

        var body = jsonEncode(untranlsatedText);

        var finalres = await http.post(
            url.replace(queryParameters: queryParams),
            headers: headers,
            body: body,
        );
        
        if (finalres.statusCode == 200) 
        {
            var responseBody = jsonDecode(finalres.body);
            var translatedText = responseBody[0]['translations'][0]['text'];
            return translatedText;
        } 
        else 
        {
            dev.log('Request failed with status: ${finalres.statusCode}.');
            return 'Unfortunate error';
        }
    }
}
