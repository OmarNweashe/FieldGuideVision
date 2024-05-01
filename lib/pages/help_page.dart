/*
  This is the help page component for explaing tips to maximize the effectiveness/accuracy of Field Guide Vision.
  Author: Omar Nweashe
  Created on: 03/28/2024
  Modified on: 03/29/2024 by Kyle Takeuchi
  Modified on: 03/30/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Freya Archuleta
  Modified on: 04/24/2024 by Kyle Takeuchi
*/
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  // Title at the top of the page
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

  // Body that contains all help page related content
  Widget _buildBody(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Best Practices',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'This page provides details on valid image properties, '
                'optimal cropping methods, and solutions to common issues, '
                'ensuring the best chance of extracting text with the highest accuracy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 55),
              Text(
                'Image Properties',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Supported image formats: JPG, PNG\n'
                'Image file size: Greater than 15KB, Less than 4MB\n'
                'Image dimensions: Between 50x50 and 4200x4200 pixels. No larger than 10 Megapixels.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 55),
              Text(
                'Cropping',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 14),
              Text(
                "This application's functionality revolves heavily "
                'around its ability to detect characters. To ensure '
                'that the character recognition algorithm can extract the '
                'characters correctly, we require users to isolate '
                'the text to be extracted and nothing else.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Examples can be seen below:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AssetImage('assets/images/GoodExample1.png'),
                    width: 150,
                    height: 400,
                  ),
                  Image(
                    image: AssetImage('assets/images/GoodExample2.png'),
                    width: 150,
                    height: 400,
                  ),
                ],
              ),
              SizedBox(height: 55),
              Text(
                'Common Issues',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Sign is Tilted or Facing Away',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Signs that are tilted in any direction '
                'may be cropped inefficiently, leading to '
                'incorrect text extraction. For optimal results, '
                'the application requires users to take pictures '
                'head-on, as shown below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AssetImage('assets/images/TiltedImage.png'),
                    width: 150,
                    height: 200,
                  ),
                  Image(
                    image: AssetImage('assets/images/StraightImage.png'),
                    width: 150,
                    height: 200,
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'If users are selecting an image from their gallery, '
                'adjusting the tilt degree in their default photo app '
                'before choosing it in this application can significantly '
                'improve text extraction accuracy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Being Too Far From The Sign',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Although the Auto-Enhance feature attempts to sharpen '
                'blurry and pixelated images, it may not always recognize '
                'characters. To extract the text with the highest '
                'possible accuracy, users should ensure they are close enough '
                'to the sign so that each character is visible and clear '
                'AFTER cropping.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Auto-Enhance Producing Bad Result',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The Auto-Enhance feature was implemented to ease '
                'user experience. However, there may be instances '
                'where the original image is clearer than '
                'the enhanced one. In such cases, selecting "Manually Adjust Image" '
                'allows you to proceed with the original image and complete '
                'the extraction process.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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
