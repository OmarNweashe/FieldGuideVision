/* 
  The text translation page that houses the components and widgets for the text translation page
  Author: Nathan Sianipar
  Created on: 02/23/2024
  Modified on: 02/27/2024 by Nathan Sianipar
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 03/04/2024 by Omar Nweashe
  Modified on: 03/21/2024 by Nathan Sianipar
  Modified on: 03/27/2024 by Nathan Sianipar
  Modified on: 03/28/2024 by Omar Nweashe
  Modified on: 04/06/2024 by Omar Nweashe
  Modified on: 04/07/2024 by Kyle Takeuchi
  Modified on: 04/07/2024 by Omar Nweashe
  Modified on: 04/08/2024 by Omar Nweashe
  Modified on: 04/09/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Freya Archuleta

*/
// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import '../utils/awstranslate.dart';
import '../utils/azuretranslate.dart';
import '../utils/googletranslate.dart';
import 'dart:developer' as dev;
import '../utils/location_dictionary.dart' as location;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';

class TranslatedTextPage extends StatefulWidget {
  final String extractedtext;

  const TranslatedTextPage({super.key, required this.extractedtext});

  @override
  State<TranslatedTextPage> createState() => _TranslatedTextPageState();
}

class _TranslatedTextPageState extends State<TranslatedTextPage> {
  String? googletextranslation = "Translating ...";
  String? azuretextranslation = "Translating ...";
  String? awstextranslation = "Translating ...";
  String sourceLanguageCode = "ar";
  String targetLanguageCode = "en";
  bool translationsVisible = false;
  bool dictionarymatch = false;
  List<String> foundlocations = [];

  @override
  void initState() {
    super.initState();
    location.eraseDictionary();
    parseAndReplaceText(widget.extractedtext);
  }

  /* 
    Function that builds the app bar at the top of the page
  */
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Field Guide Vision',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 227, 227, 227)),
      ),
      backgroundColor: const Color.fromARGB(255, 70, 70, 70),
      elevation: 0.0,
      centerTitle: true,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color.fromARGB(255, 143, 163, 202),
          onPressed: () {
            Navigator.pop(context);
          }),
    );
  }

  /*
    Function handles showing alternative translations
   */
  Future<void> _maketranslationvisible(bool show) async {
    setState(() {
      translationsVisible = show;
    });
  }

  /* 
    Function to display the various translation results, as well as the alt translations
  */
  Future<void> parseAndReplaceText(String text) async {
    await location.updateStreetNameDictionaryWithOSM(
        text); // Call OpenStreetMap API and populate dictionary with top 5 results of that name

    await AWStranslate(text);
    await Azuretranslate(text);
    await Googletranslate(text);
  }

  /* 
    Function to call the Amazon translation API, sets Amazon translation string
  */
  Future<void> AWStranslate(String text) async {
    AwsTranslateService awstranslate = AwsTranslateService();

    try {
      String awstranslation = await awstranslate.translateText(
        sourceLanguageCode,
        targetLanguageCode,
        text,
      );

      setState(() {
        awstextranslation = awstranslation;
      });
    } catch (e) {
      setState(() {
        awstextranslation =
            'Error occurred during translation. Please try again. ';
      });
      dev.log('Error in AWS translation: $e');
    }
  }

  /* 
    Function to call the Microsoft translation API, sets Microsoft translation string
  */
  Future<void> Azuretranslate(String text) async {
    AzureTranslateService azuretranslate = AzureTranslateService();

    try {
      String azuretranslation = await azuretranslate.translateText(
        sourceLanguageCode,
        targetLanguageCode,
        text,
      );

      setState(() {
        azuretextranslation = azuretranslation;
      });
    } catch (e) {
      setState(() {
        azuretextranslation =
            'Error occurred during translation. Please try again. ';
      });
      dev.log('Error in Azure translation: $e');
    }
  }

  /* 
    Function to call the Google translation API, sets Google translation string
  */
  Future<void> Googletranslate(String text) async {
    GoogleTranslateService googletranslate = GoogleTranslateService();
    String apiKey = //INSERT KEY HERE';

    try {
      String googletranslation = await googletranslate.translateText(
        targetLanguageCode,
        text,
        apiKey,
      );
      setState(() {
        googletextranslation = googletranslation;
      });
    } catch (e) {
      setState(() {
        googletextranslation =
            'Error occurred during translation. Please try again. ';
      });
      dev.log('Error in Google translation: $e');
    }
  }

  /* 
    Function to display google translation result
  */
  Widget _displayGoogleTranslation() {
    return Text(
      'Google Translation: $googletextranslation',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    );
  }

  /* 
    Function to display aws translation result
  */
  Widget _displayAWSTranslation() {
    return Text(
      'AWS Translation: $awstextranslation',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    );
  }

  /* 
    Function to display azure translation result
  */
  Widget _displayAzureTranslation() {
    return Text(
      'Azure Translation: $azuretextranslation',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    );
  }

  /* 
    Function to display alternative translation text
  */
  Widget _displayAltTranslations() {
    return Column(children: [
      const Text(
        '\nAlternative Translations:',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
      ...location.streetNameDictionary.entries.map((entry) => Text(
            '${entry.key}: ${entry.value.join(', ')}', // Joining list values with commas
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 17,
            ),
          ))
    ]);
  }

  /* 
    Function to display no alternative translation text
  */
  Widget _displayNoAltTranslations() {
    return const Text(
      'Alternative Translations: None',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
    );
  }

  /*
    This function returns the two buttons on the page, the show/hide other translations,
    as well as teh translate another picture button.
   */
  Widget _getButtons(BuildContext context) {
    return Column(children: [
      ElevatedButton(
        onPressed: () {
          _maketranslationvisible(!translationsVisible);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: const Color.fromARGB(255, 78, 108, 164),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
        ),
        child: Text(translationsVisible
            ? 'Hide Additional Translations'
            : 'Show Additional Translations'),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: const Color.fromARGB(255, 78, 108, 164),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
        ),
        child: const Text('Translate Another Picture'),
      ),
    ]);
  }

  /*
    Function that handles getting the street the user is on.
  */
  Future<String> _getStreet() async {
    //final Uri uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&accept-language=en&lat=${location.latlon!.latitude}&lon=${location.latlon!.longitude}&zoom=18');
    // v Hardcoded latlon values for AlSharabeya in Egypt
    final Uri uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&accept-language=en&lat=${30.0751899}&lon=${31.2596313}&zoom=18');
    final http.Response res = await http.get(uri);

    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      final String road = data['address']['road'];
      return road;
    } else {
      dev.log('Request failed with status: ${res.statusCode}');
      return '';
    }
  }

  /*
    Function that displays the street the user is on
  */
  Future<Widget> _displayCurrentStreet() async {
    String road = await _getStreet();
    return Text(
      '\n\nYou are on $road',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color.fromARGB(255, 39, 46, 255),
        fontSize: 22,
      ),
    );
  }

  /*
    Function that gets the list of streets within a 250 meter radius from the user.
  */
  Future<List<String>> getStreetsWithinRadius(
      double lat, double lon, double radius,
      {int limit = 7}) async {
    const overpassUrl = "https://overpass-api.de/api/interpreter";
    final overpassQuery = """
    [out:json];
    way(around:$radius,$lat,$lon)["highway"~"^(motorway|trunk|primary|secondary|tertiary|residential|service|motorway_link|trunk_link|primary_link|secondary_link|tertiary_link)\$"];
    out center;
  """;

    final response =
        await http.post(Uri.parse(overpassUrl), body: {'data': overpassQuery});

    if (response.statusCode == 200) {
      try {
        final decodedData = utf8.decode(response.bodyBytes);
        final data = json.decode(decodedData);
        //final data = json.decode(response.body);
        final Set<String> streetNames = {};
        if (data['elements'] != null) {
          for (var element in data['elements']) {
            if (element['tags'] != null) {
              final tags = element['tags'];
              final streetEnglishName = tags['name:en'] ?? '';
              final streetArabicName = tags['name:ar'] ?? '';
              final roadName = tags['name'] ?? '';
              String formattedName = '';
              if (streetEnglishName.isNotEmpty && streetArabicName.isNotEmpty) {
                formattedName = '$streetEnglishName - $streetArabicName';
              } else if (streetEnglishName.isNotEmpty) {
                formattedName = streetEnglishName;
              } else if (streetArabicName.isNotEmpty) {
                formattedName = streetArabicName;
              } else {
                formattedName = roadName;
              }
              if (formattedName.isNotEmpty) {
                dev.log(formattedName);
                streetNames.add(formattedName);
              }
            }
          }
        }
        return streetNames.toList();
      } catch (e) {
        dev.log("Error parsing JSON response: $e");
      }
    } else {
      dev.log("Error: ${response.statusCode} - ${response.body}");
    }
    return [];
  }

  /*
    Function that handles building the body for the page where it is scrollable,
    displays google translation as the first translation, shows the other translations
    if the button is clicked, allows the user to go back and take another picture to process
    it also shows the street the user is on, a list of streets near the user if gps is enabled.
  */
  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _displayGoogleTranslation(),
                  if (translationsVisible)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        _displayAWSTranslation(),
                        const SizedBox(height: 20),
                        _displayAzureTranslation(),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (location.streetNameDictionary.isNotEmpty)
                    _displayAltTranslations(),
                  if (location.streetNameDictionary.isEmpty)
                    _displayNoAltTranslations(),
                  Visibility(
                    visible: location.trackingStatus,
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        FutureBuilder<Widget>(
                          future: location.latlon != null
                              ? _displayCurrentStreet()
                              : Future.error('latlon is null'),
                          builder: (BuildContext context,
                              AsyncSnapshot<Widget> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                  color: Color.fromARGB(255, 78, 108, 164));
                            } else if (snapshot.hasError) {
                              dev.log('Error: ${snapshot.error}');
                              return Container();
                            } else {
                              return snapshot.data!;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: location.trackingStatus,
                    child: FutureBuilder<List<String>>(
                      future: location.latlon != null
                          //? getStreetsWithinRadius(location.latlon!.latitude, location.latlon!.longitude, 250)
                          ? getStreetsWithinRadius(30.0751899, 31.2596313,
                              250) // Hard-coded latlon values for AlSharabeya in Egypt
                          : Future.error('latlon is null'),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                              color: Color.fromARGB(255, 78, 108, 164));
                        } else if (snapshot.hasError) {
                          dev.log('Error: ${snapshot.error}');
                          return Container();
                        } else {
                          final data = snapshot.data;
                          if (data != null && data.isNotEmpty) {
                            return Column(
                              children: [
                                const SizedBox(height: 10),
                                const Text(
                                  "Closest Streets Within 250 Meters",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                for (int i = 0; i < data.length && i < 7; i++)
                                  Text(
                                    data[i],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                    ),
                                  ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _getButtons(context),
          ],
        ),
      ),
    );
  }

  /*
    build function that builds the text translation page
  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      body: _buildBody(context),
    );
  }
}
