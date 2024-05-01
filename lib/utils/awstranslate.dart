/*
  This file holds the main backend functionality for the Amazon translation API calls the app makes
  Created by: Nathaniel Sianipar
  Created on: 11/02/2023
  Modified on: 11/07/2023 by Nathaniel Sianipar
  Modified on: 11/07/2023 by Omar Nweashe
  Modified on: 11/07/2023 by Nathaniel Sianipar
  Modified on: 11/08/2023 by Nathaniel Sianipar
  Modified on: 11/09/2023 by Nathaniel Sianipar
  Modified on: 01/19/2024 by Omar Nweashe
  Modified on: 02/20/2024 by Nathaniel Sianipar
  Modified on: 02/20/2024 by Nathaniel Sianipar
  Modified on: 02/27/2024 by Nathaniel Sianipar
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 03/04/2024 by Omar Nweashe
  Modified on: 04/24/2024 by Kyle Takeuchi
  Modified on: 04/26/2024 by Nathaniel Sianipar

  
*/


import 'dart:async';
import 'package:aws_translate_api/translate-2017-07-01.dart';
import 'dart:developer' as dev;

class AwsTranslateService
{
  /* 
    Function that handles directly calling Amazon Translation API, returns the Amazon translation
  */
  Future<String> translateText(String sourceLangCode, String targetLangCode, String rawText) async {
    // Configure your AWS credentials
    AwsClientCredentials credentials = AwsClientCredentials(
      accessKey: //INSERT KEY HERE,
      secretKey: //INSERT KEY HERE,
    );

    // Initialize the Translate client with your credentials
    Translate translate = Translate(
      region: 'us-east-1', // Set your AWS region
      credentials: credentials,
    );

    try {
      // Send the translation request
      TranslateTextResponse response = await translate.translateText(
          sourceLanguageCode: sourceLangCode,
          targetLanguageCode: targetLangCode,
          text: rawText,);

      // Extract and return the translated text from the response
      return response.translatedText;
    } catch (e) {
      // Handle any errors that occur during the translation request
      dev.log('Error: $e');
      return 'Error in the code';
    }
  }

}
