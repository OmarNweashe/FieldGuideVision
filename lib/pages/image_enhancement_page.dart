/*
  This file holds the components for the Image Enhancement page
  Author: Omar Nweashe 
  Created on: 02/16/2024
  Modified on: 02/23/2024 by Omar Nweashe
  Modified on: 02/27/2024 by Nathan Sinaipar
  Modified on: 02/28/2024 by Omar Nweashe 
  Modified on: 03/04/2024 by Omar Nweashe 
  Modified on: 03/28/2024 by Omar Nweashe
  Modified on: 04/12/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Freya Archuleta
  Modified on: 04/24/2024 by Kyle Takeuchi 
*/
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'image_manual_page.dart';
import 'extracted_text.dart';
import '../utils/image_enhancement.dart';

// ignore: must_be_immutable
class EnhancePage extends StatefulWidget {
  CroppedFile? croppedFile;

  EnhancePage({super.key, this.croppedFile});

  @override
  State<EnhancePage> createState() => _EnhancePageState();
}

class _EnhancePageState extends State<EnhancePage> {
  // AutoEnhance
  XFile? enhancedImageAuto;

  // Edits 4/12/24: Circular Progress Indicator implementation and sending original image across different pages
  Future<void>? _enhanceFuture;
  Uint8List? originalImageBytes;

  @override
  void initState() {
    super.initState();
    //_enhanceImage();

    // Edits 4/12/24: Instead of calling _enhanceImage() directly and affecting UI,
    // set a future variable used for building later
    _enhanceFuture = _enhanceImage();
  }

  // Enhance Image Function that will asynchronously process the image and set the state to the enhanced image
  Future<void> _enhanceImage() async {
    if (widget.croppedFile != null) {
      final croppedImageBytes =
          await File(widget.croppedFile!.path).readAsBytes();

      // convert cropped to grayscale
      img.Image image = img.decodeImage(croppedImageBytes)!;
      img.Image grayscaleImage = img.grayscale(image);
      Uint8List grayscaleBytes =
          Uint8List.fromList(img.encodeJpg(grayscaleImage));

      // Edit 4/12/24: Setting originalImageBytes to grayscaled
      originalImageBytes = grayscaleBytes;

      String fileName = path.basename(widget.croppedFile!.path);
      Directory tempDir = await getTemporaryDirectory();
      String grayscaleImagePath =
          path.join(tempDir.path, 'grayscale_$fileName');
      File(grayscaleImagePath).writeAsBytesSync(grayscaleBytes);

      // Store the updated cropped file temporarily
      CroppedFile updatedCroppedFile = CroppedFile(grayscaleImagePath);

      // AutoEnhance
      // Edits 4/12/24: Asynch processing for computations
      AutoEnhanceInput input = AutoEnhanceInput(croppedImageBytes);
      final enhancedBytes4 = await compute(autoEnhanceCompute, input);

      tempDir = await getTemporaryDirectory();

      // AutoEnhance
      XFile? enhancedImageAuto = await saveEnhancedImage(
          enhancedBytes4, 'enhanced4_$fileName', tempDir.path);

      setState(() {
        // Update the properties with the enhanced images
        // AutoEnhance
        this.enhancedImageAuto = enhancedImageAuto;
        // Assign the updated cropped file to the widget property
        widget.croppedFile = updatedCroppedFile;
      });
    }
  }

  Future<XFile?> saveEnhancedImage(
      Uint8List? bytes, String fileName, String dirPath) async {
    if (bytes == null) return null;
    String filePath = path.join(dirPath, fileName);
    File enhancedImageFile = File(filePath)..writeAsBytesSync(bytes);
    return XFile(enhancedImageFile.path);
  }

  void _navigateAndExtractText(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtractedTextPage(
          imagePath: imagePath,
          originalImageBytes: originalImageBytes!,
        ), // Edit 4/12/24
      ),
    );
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
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Buttons for transitioning from page to page
  Widget _getButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            final navigator = Navigator.of(context);
            if (!mounted) return;
            navigator.push(MaterialPageRoute(
              builder: (context) =>
                  ImageEnhancePage(originalImageBytes: originalImageBytes!),
            ));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: const Color.fromARGB(255, 78, 108, 164),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
          ),
          child: const Text('Manually Adjust Image'),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => _navigateAndExtractText(enhancedImageAuto!.path),
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
    );
  }

  // Displaying the resulting image
  Widget _getImage(
    String text,
    String path,
    double width,
    double height,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style: const TextStyle(
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
          child: Image.file(File(path)),
        ),
      ],
    );
  }

  // Body that contains all Manual Enhancement page related content
  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.croppedFile != null) ...[
              _getImage(
                'Original Image',
                widget.croppedFile!.path,
                200,
                200,
              ),
            ],
            if (enhancedImageAuto != null) ...[
              _getImage(
                '\n\nAuto-Enhance Result',
                enhancedImageAuto!.path,
                200,
                200,
              ),
            ],
            const SizedBox(height: 25),
            _getButtons(context),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Edit 4/12/24: Circular Progress Indicator
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder(
        future: _enhanceFuture,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(255, 78, 108, 164),
            ));
          }
          // display an error message for errors
          else if (snapshot.hasError) {
            return const Center(child: Text("Failed to enhance image"));
          }
          // When the future completes successfully, show the UI with the enhanced image
          return _buildBody(context);
        },
      ),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
    );
  }
}
