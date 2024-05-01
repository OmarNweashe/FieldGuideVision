/*
  Main code for housing the manual image enhancement page components
  Author: Kyle Takeuchi
  Created on: 02/13/2024
  Modified on: 02/16/2024 by Omar Nweashe
  Modified on: 02/23/2024 by Omar Nweashe
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 03/28/2024 by Omar Nweashe
  Modified on: 04/08/2024 by Omar Nweashe
  Modified on: 04/12/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Freya Archuleta
  Modified on: 04/24/2024 by Kyle Takeuchi
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../utils/manual_adjust.dart';
import 'extracted_text.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageEnhancePage extends StatefulWidget {
  final Uint8List originalImageBytes;

  const ImageEnhancePage({super.key, required this.originalImageBytes});

  @override
  State<ImageEnhancePage> createState() => _ImageEnhancePageState();
}

// Initially set the brightness and contrast level and set state
class _ImageEnhancePageState extends State<ImageEnhancePage> {
  Timer?
      _debounce; // to not update the image every frame when the slider is moving

  double _brightnessDouble = 0.0;
  int _brightness =
      0; // needs to be an int for adjusting brightness in the function that I created
  double _contrastDouble = 0.0;

  Uint8List? _enhancedImageBytes;

  @override
  void initState() {
    super.initState();
    _enhancedImageBytes = widget.originalImageBytes;
  }

  @override
  void dispose() {
    _debounce
        ?.cancel(); // Cancel the timer if it's active when the widget is disposed
    super.dispose();
  }

  // Updating the image based on the slider values
  void _updateImage() async {
    // ADJUST BRIGHTNESS
    _brightness = _brightnessDouble.round();
    Uint8List tempBytes =
        adjustBrightness(widget.originalImageBytes, _brightness);
    // ADJUST CONTRAST
    tempBytes = adjustContrast(tempBytes, _contrastDouble);

    setState(() {
      _enhancedImageBytes = tempBytes;
    });
  }

  // setting the state when the slider is changed
  void _onBrightnessChanged(double value) {
    // Update UI immediately for responsive feedback
    setState(() {
      _brightnessDouble = value;
    });
    // Debounce the actual image processing
    _debounceImageProcessing();
  }

  // setting the state when the slider is changed
  void _onContrastChanged(double value) {
    // Update UI immediately for responsive feedback
    setState(() {
      _contrastDouble = value;
    });
    // Debounce the actual image processing
    _debounceImageProcessing();
  }

  // To not update in real-time and affect page layout on every small adjustment, set a delay of 300 milliseconds
  void _debounceImageProcessing() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updateImage();
    });
  }

  // Save the image that will be passed into the text extraction page
  Future<String?> saveAdjustedImageToFile(Uint8List? imageData) async {
    if (imageData == null) return null;

    final tempDir = await getTemporaryDirectory();
    final filePath = path.join(tempDir.path,
        'adjusted_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final file = await File(filePath).writeAsBytes(imageData);
    return file.path;
  }

  // Title at the top of the page
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

  // Body that contains all Manual Enhancement page related content
  Widget _buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: _enhancedImageBytes == null
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 78, 108, 164)))
                : Image.memory(_enhancedImageBytes!),
          ),
          const SizedBox(height: 20.0),
          Text(
            'Brightness: ${_brightnessDouble.round()}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color.fromARGB(255, 227, 227, 227)),
          ),
          Slider(
            min: -100.0,
            max: 100.0,
            value: _brightnessDouble,
            onChanged: _onBrightnessChanged,
            activeColor: const Color.fromARGB(255, 78, 108, 164),
            thumbColor: const Color.fromARGB(255, 238, 238, 238),
            inactiveColor: const Color.fromARGB(169, 255, 255, 255),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Contrast: ${_contrastDouble.round()}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Color.fromARGB(255, 227, 227, 227)),
          ),
          Slider(
            min: -100.0,
            max: 100.0,
            value: _contrastDouble,
            onChanged: _onContrastChanged,
            activeColor: const Color.fromARGB(255, 78, 108, 164),
            thumbColor: const Color.fromARGB(255, 238, 238, 238),
            inactiveColor: const Color.fromARGB(169, 255, 255, 255),
          ),
          const SizedBox(height: 15),
          // EDITS 4/12/24: For manual button and context
          ElevatedButton(
            onPressed: () async {
              // Capture the context in a local variable before the async gap
              final BuildContext currentContext = context;

              final String? adjustedImagePath =
                  await saveAdjustedImageToFile(_enhancedImageBytes);

              // Check if the widget is still mounted after the async operation
              if (!mounted) return;

              if (adjustedImagePath != null) {
                // ignore: use_build_context_synchronously
                Navigator.of(currentContext).push(MaterialPageRoute(
                  builder: (context) => ExtractedTextPage(
                    imagePath: adjustedImagePath,
                    originalImageBytes: widget.originalImageBytes,
                  ),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: const Color.fromARGB(255, 78, 108, 164),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
            ),
            child: const Text('Extract Text'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
    );
  }
}
