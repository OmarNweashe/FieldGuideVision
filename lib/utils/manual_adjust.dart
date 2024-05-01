/*
  This file provides methods for the manual enhancement of images on the image_manual_page.dart
  Author: Kyle Takeuchi
  Created on: 02/13/2024
  Modified on: 04/12/2024 by Kyle Takeuchi
*/
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/*
  Method that handles the brightness adjustment for the manual image enhancement
*/
Uint8List adjustBrightness(Uint8List imageBytes, int adjustment) {
  img.Image image = img.decodeImage(imageBytes)!;

  // Iterate over all pixels to adjust brightness
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      img.Pixel pixel = image.getPixel(x, y);
      int brightness = pixel.r.toInt() + adjustment;
      brightness = brightness.clamp(0, 255); // clamp brightness to within 0-255
      image.setPixel(x, y, img.ColorRgb8(brightness,brightness,brightness));
    }
  }
  return Uint8List.fromList(img.encodeJpg(image));
}

/*
  Method that handles the contrast adjustment for the manual image enhancement
*/
Uint8List adjustContrast(Uint8List imageBytes, double adjustment) {
  img.Image image = img.decodeImage(imageBytes)!;

  // Adjust the range of adjustment as needed. Example: -100 to 100 for slider input.
  double alpha = (adjustment + 100) / 200 * 1.5 + 0.5; 

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      img.Pixel pixel = image.getPixel(x, y);
      int gray = pixel.r.toInt();
      gray = ((alpha * (gray - 128)) + 128).clamp(0, 255).toInt(); // adjust contrast
      image.setPixel(x, y, img.ColorRgb8(gray,gray,gray));
    }
  }

  return Uint8List.fromList(img.encodeJpg(image));
}


