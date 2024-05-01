/*
  This is the home (landing) page of the Field Guide Vison App
  Author: Omar Nweashe
  Created on: 10/26/2023
  Modified on: 10/26/2023 by Omar Nweashe
  Modified on: 11/02/2023 by Omar Nweashe
  Modified on: 11/07/2023 by Omar Nweashe
  Modified on: 11/09/2023 by Omar Nweashe
  Modified on: 01/19/2024 by Omar Nweashe
  Modified on: 01/26/2024 by Omar Nweashe
  Modified on: 02/16/2024 by Omar Nweashe
  Modified on: 02/23/2024 by Omar Nweashe
  Modified on: 02/24/2024 by Freya Archuleta
  Modified on: 02/28/2024 by Omar Nweashe
  Modified on: 03/04/2024 by Omar Nweashe
  Modified on: 03/13/2024 by Freya Archuleta
  Modified on: 03/27/2024 by Freya Archuleta
  Modified on: 03/28/2024 by Omar Nweashe
  Modified on: 03/29/2024 by Kyle Takeuchi
  Modified on: 03/30/2024 by Kyle Takeuchi
  Modified on: 04/06/2024 by Omar Nweashe
  Modified on: 04/12/2024 by Freya Archuleta
  Modified on: 04/12/2024 by Kyle Takeuchi
*/
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './image_confirmation_popup.dart';
import '../utils/location_dictionary.dart' as dict;
import 'package:image_cropper/image_cropper.dart';

import './image_enhancement_page.dart';
import './help_page.dart';

bool canTrack = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String? _imagePath;

  /*
    Function opens the gallery using ImagePicker and returns an image
   */
  Future<void> _openGallery() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  /*
    Function opens the Camera using ImagePicker to get an image from the camera
   */
  Future<void> _openCamera() async {
    final imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  /*
    Builds the AppBar at the top of the page
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
    );
  }

  /*
    Returns the welcome message to the user
   */
  Widget _getWelcome() {
    return const Text(
      'Welcome to Field Guide Vision!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(255, 227, 227, 227),
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /*
    Returns the text on the page to prompt the user to select the input image source
   */
  Widget _getSourceRequest() {
    return const Text(
      'Select Photo Source',
      style: TextStyle(
        color: Color.fromARGB(255, 227, 227, 227),
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /*
    This uses ImageCropper to allow the user to crop the image and proceed
    Appears after confirming the image on the image popup.
   */
  Future<void> _cropImage(String imagePath) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Select Text',
          toolbarColor: const Color.fromARGB(255, 70, 70, 70),
          cropGridColor: const Color.fromARGB(255, 70, 70, 70),
          backgroundColor: const Color.fromARGB(255, 70, 70, 70),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Select Text'),
      ],
    );

    if (cropped != null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EnhancePage(croppedFile: cropped)));
    }
  }

  /*
    Handles showing the user the image popup to either proceed with the image selected, 
    or go back and choose a different image.
   */
  void _showImagePopup() {
    if (_imagePath != null) {
      String imagePathForDialog = _imagePath!;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ImagePopup(
            imagePath: imagePathForDialog,
            onProceed: () {
              _cropImage(imagePathForDialog);
              setState(() {
                _imagePath = null;
              });
            },
            onChangePhoto: () {
              Navigator.of(context).pop();
              setState(() {
                _imagePath = null;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          );
        },
      );
    }
  }

  /*
    Returns the two buttons on the page and handles their repsective functionalties,
    where Camera calls its respective function and opens the camera, gallery opens the gallery 
    to select an image. 
   */
  Widget _getButtons(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _openGallery();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: const Color.fromARGB(255, 78, 108, 164),
                foregroundColor: const Color.fromARGB(255, 227, 227, 227),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
              ),
              child: const Text('Photo Gallery'),
            ),
            if (isIOS || isAndroid) ...[
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  _openCamera();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: const Color.fromARGB(255, 78, 108, 164),
                  foregroundColor: const Color.fromARGB(255, 227, 227, 227),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
                child: const Text('Camera'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Allow Location for Improved Translation',
                  style: TextStyle(
                    color: Color.fromARGB(255, 227, 227, 227),
                    fontSize: 16,
                  ),
                ),
                Switch(
                  value: canTrack,
                  onChanged: (value) {
                    setState(() {
                      canTrack = value;
                      dict.trackingStatus = value;
                    });
                    if (canTrack) {
                      dict.updateStreetNameDictionary();
                    } else {
                      dict.eraseDictionary();
                    }
                  },
                  activeColor: const Color.fromARGB(255, 78, 108, 164),
                  activeTrackColor: const Color.fromARGB(173, 78, 108, 164),
                  inactiveThumbColor: const Color.fromARGB(255, 238, 238, 238),
                  inactiveTrackColor: const Color.fromARGB(169, 255, 255, 255),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /*
    This function builds the body of the page, where it is centered and scrollable, and the components are laid out.
   */
  Widget buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                _getWelcome(),
                // Help Page button
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpPage()));
                  },
                  child: const Text(
                    'How to Maximize Accuracy',
                    style: TextStyle(
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                      decorationColor: Color.fromARGB(255, 170, 170, 170),
                      color: Color.fromARGB(255, 227, 227, 227),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                _getSourceRequest(),
                const SizedBox(height: 20),
                _getButtons(context),
                const SizedBox(height: 20),
                if (_imagePath != null)
                  Column(
                    children: [
                      FutureBuilder<void>(
                        future:
                            Future.delayed(const Duration(milliseconds: 1), () {
                          _showImagePopup();
                        }),
                        builder: (context, snapshot) {
                          return Container();
                        },
                      ),
                    ],
                  ),
                // Images
                const SizedBox(height: 20),
                const Image(
                  image: AssetImage(
                    'assets/images/c5isr.png',
                  ),
                  height: 75,
                ),
                const SizedBox(height: 20),
                const Image(
                  image: AssetImage(
                    'assets/images/vt-logo.png',
                  ),
                  height: 45,
                ),
              ],
            )),
      ),
    );
  }

  /*
    This function is the main build function, builds the app bar, the body itself, as well as sets the default backgroud color.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: buildBody(context),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
    );
  }
}
