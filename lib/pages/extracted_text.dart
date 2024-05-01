/*
  This file handles the text extraction components
  Author: Kyle Takeuchi
  Created on: 02/13/2024
  Modified on: 02/23/2024 by Nathan Sianipar
  Modified on: 02/23/2024 by Omar Nweashe
  Modified on: 02/27/2024 by Nathan Sianipar
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 03/04/2024 by Omar Nweashe
  Modified on: 03/21/2024 by Kyle Takeuchi
  Modified on: 03/28/2024 by Omar Nweashe
  Modified on: 03/28/2024 by Kyle Takeuchi
  Modified on: 04/03/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Freya Archuleta
  Modified on: 04/24/2024 by Kyle Takeuchi
*/
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_manual_page.dart';
import './text_translation_page.dart';

class ExtractedTextPage extends StatefulWidget {
  final String imagePath;

  // Edit 4/12/24: Passing in originalImageBytes for Manual Enhancement FROM extracted text page.
  final Uint8List originalImageBytes;

  const ExtractedTextPage(
      {super.key,
      required this.imagePath,
      required this.originalImageBytes // Edit 4/12/24
      });

  @override
  State<ExtractedTextPage> createState() => _ExtractedTextPageState();
}

class _ExtractedTextPageState extends State<ExtractedTextPage> {
  String _extractedText = 'Extracting text...';

  @override
  void initState() {
    super.initState();
    _extractTextFromImage();
  }

  // Handles the API calls from Azure AI services and extracts text. Returns error message otherwise.
  Future<void> _extractTextFromImage() async {
    // Changing detection language. Default is 'unk'
    String languageCode = 'ar';

    final uri = Uri.parse(
        'https://street-sign-extraction.cognitiveservices.azure.com/vision/v3.2/ocr?language=$languageCode');
    final headers = {
      'Ocp-Apim-Subscription-Key': //INSERT KEY HERE,
      'Content-Type': 'application/octet-stream'
    };

    final imageBytes = await _getImageBytes(widget.imagePath);
    final response = await http.post(uri, headers: headers, body: imageBytes);

    if (response.statusCode == 200) {
      // Valid / Success
      setState(() {
        _extractedText = _parseOcrResult(json.decode(response.body));
      });
    } else if (response.statusCode == 400) {
      // Invalid Request and Argument
      final responseBody = json.decode(response.body);
      final errorMessage = responseBody['error']['message'];
      setState(() {
        _extractedText =
            'Failed to extract text: \n$errorMessage. \n\nPlease check instructions page for image requirements.';
      });
    } else if (response.statusCode == 415) {
      // Unsupported media type
      final responseBody = json.decode(response.body);
      final errorMessage = responseBody['error']['message'];
      setState(() {
        _extractedText =
            'Failed to extract text: \n$errorMessage. \n\nPlease pick a valid image.';
      });
    } else if ((response.statusCode == 500) || (response.statusCode == 503)) {
      // Internal Service Error and Service Unavailable
      final responseBody = json.decode(response.body);
      final errorMessage = responseBody['error']['message'];
      setState(() {
        _extractedText =
            'Failed to extract text: \n$errorMessage. \n\nPlease try again later.';
      });
    } else {
      // If non-typical error code appears.
      final responseBody = json.decode(response.body);
      final errorCode = responseBody['error']['code'];
      final errorMessage = responseBody['error']['message'];
      setState(() {
        _extractedText =
            'Failed to extract text. Status code: $errorCode - $errorMessage';
      });
    }
  }

  // ImageBytes are necessary to perform text extraction
  Future<List<int>> _getImageBytes(String path) async {
    File imageFile = File(path);
    return imageFile.readAsBytes();
  }

  // Parsing the resulting string from the OCR
  String _parseOcrResult(Map<String, dynamic> jsonResponse) {
    if (!jsonResponse.containsKey('regions')) {
      return 'No regions found in the JSON response.';
    }

    StringBuffer buffer = StringBuffer();
    List<dynamic> regions =
        jsonResponse['regions']; // grab regions section from JSON

    for (var region in regions) {
      if (region.containsKey('lines')) {
        List<dynamic> lines = region['lines'];

        for (var line in lines) {
          List<dynamic> words = line['words'];

          // reverse order of words for RTL text before concatenating
          var reversedWords = words.reversed.toList();

          for (int k = 0; k < reversedWords.length; k++) {
            // Edit 3/28/24: Filter out non-arabic words
            var wordText = reversedWords[k]['text'];

            if (isArabic(wordText)) {
              if (k > 0) {
                buffer.write(' ');
              }
              buffer.write(wordText);
            }
          }

          buffer.write(
              '\n'); // Newline after each line to match that of the picture
        }
      }
    }

    return buffer.toString().trim(); // trim trailing \n
  }

  // edit 3/28/24: Function to check if text is arabic
  bool isArabic(String text) {
    return text.runes.any((int rune) {
      return (rune >= 0x0600 && rune <= 0x06FF) || // Arabic
          (rune >= 0x0750 && rune <= 0x077F) || // Arabic Supplement
          (rune >= 0x08A0 && rune <= 0x08FF) || // Arabic Extended-A
          (rune >= 0xFB50 && rune <= 0xFDFF) || // Arabic Presentation Forms-A
          (rune >= 0xFE70 && rune <= 0xFEFF); // Arabic Presentation Forms-B
    });
  }

  //Function to send extracted text to texttranslation page
  Future<void> _sendExtractedText(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TranslatedTextPage(extractedtext: _extractedText),
      ),
    );
  }

  // Title at the top of page
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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

  // Body that contains all Extracted Text page related content
  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Input Image',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 20 > 0
                    ? MediaQuery.of(context).size.width - 20
                    : double.infinity,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Image.file(File(widget.imagePath)),
            ),
            const Text(
              '\nExtracted Text',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _extractedText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _sendExtractedText(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: const Color.fromARGB(255, 78, 108, 164),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
              ),
              child: const Text('Translate Text'),
            ),
            const SizedBox(height: 40),
            const Text(
              'Not extracting correctly?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try manually enhancing or visit the \n'
              'instructions page for more information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            // Edit 4/12/24: Button leading to Manual Enhance Page
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageEnhancePage(
                        originalImageBytes: widget.originalImageBytes),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: const Color.fromARGB(255, 78, 108, 164),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
              ),
              child: const Text('Adjust Image Manually'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
    );
  }
}
