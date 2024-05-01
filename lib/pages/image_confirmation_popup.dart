/*
  This is the home page popup component
  Author: Omar Nweashe
  Created on: 11/05/2023
  Modified on: 04/12/2024 by Freya Archuleta
*/
import 'package:flutter/material.dart';
import 'dart:io';

class ImagePopup extends StatelessWidget {
  final String imagePath;
  final VoidCallback onProceed;
  final VoidCallback onChangePhoto;

  const ImagePopup({
    super.key,
    required this.imagePath,
    required this.onProceed,
    required this.onChangePhoto,
  });

  /*
    This build function builds the popup, utilizes the two functions given to perform different actions,
    when their respective buttons are clicked
   */
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 227, 227, 227),
      title: const Text(
        'Selected Image',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(
            File(imagePath),
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          const Text(
            'Would you like to proceed with this photo?',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onChangePhoto();
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
              child: const Text('Change Photo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onProceed();
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
              child: const Text('Proceed'),
            ),
          ],
        ),
      ],
    );
  }
}
