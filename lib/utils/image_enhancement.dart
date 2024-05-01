/*
  This file holds the main backend functionality for the image enhancement techniques we employ
  Created by: Kyle Takeuchi
  Created on: 02/05/2024
  Modified on: 02/09/2024 by Kyle Takeuchi
  Modified on: 02/13/2024 by Kyle Takeuchi
  Modified on: 03/21/2024 by Kyle Takeuchi
  Modified on: 03/28/2024 by Kyle Takeuchi
  Modified on: 04/03/2024 by Kyle Takeuchi
  Modified on: 04/12/2024 by Kyle Takeuchi
  Modified on: 04/24/2024 by Kyle Takeuchi
*/
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:math';

// Edit 4/12/24: Created class to wrap for using 'compute' (moving computation to background thread)
class AutoEnhanceInput {
  Uint8List imageBytes;
  AutoEnhanceInput(this.imageBytes);
}
Future<Uint8List?> autoEnhanceCompute(AutoEnhanceInput input) async {
  return autoEnhance(input.imageBytes);
}

/// APPLY HISTOGRAM EQUALIZATION

// ---------- Returns Grayscaled ------------ //
Future<Uint8List?> applyHistogramEqualization(Uint8List originalImageBytes) async {
  // Decode the image from the Uint8List
  img.Image? inputImage = img.decodeImage(originalImageBytes);
  if (inputImage == null) {
    // Handle the case where the image could not be decoded
    return null;
  }

  img.Image? grayscaleImage = toGrayscale(inputImage);
  if (grayscaleImage == null) {
    return null;
  }

  List<int> histogram = calculateHistogram(grayscaleImage);
  List<int> cdf = calculateCDF(histogram);
  List<int> normalizedCdf = normalizeCDF(cdf);
  img.Image? equalizedImage = applyEqualization(grayscaleImage, normalizedCdf);

  if (equalizedImage == null) {
    return null;
  }

  Uint8List? equalizedImageBytes = img.encodeJpg(equalizedImage);
  return equalizedImageBytes;
}

// Grayscale function
img.Image? toGrayscale(img.Image inputImage) {
  if (inputImage.width <= 0 || inputImage.height <= 0) {
    // Handle the case where the input image is invalid
    return null;
  }

  img.Image? grayscaleImage =
      img.Image(width: inputImage.width, height: inputImage.height);

  for (int y = 0; y < inputImage.height; y++) {
    for (int x = 0; x < inputImage.width; x++) {
      img.Pixel pixel = inputImage.getPixel(x, y);

      int red = pixel.r.toInt();
      int green = pixel.g.toInt();
      int blue = pixel.b.toInt();

      // Convert to grayscale using luminance formula
      int luminance = (0.299 * red + 0.587 * green + 0.114 * blue).round();

      grayscaleImage.setPixel(
          x, y, img.ColorRgb8(luminance, luminance, luminance));
    }
  }

  return grayscaleImage;
}

// Calculating the Histogram from 0-255
List<int> calculateHistogram(img.Image? inputImage) {
  List<int> histogram = List<int>.filled(256, 0);

  for (int y = 0; y < inputImage!.height; y++) {
    for (int x = 0; x < inputImage.width; x++) {
      img.Pixel pixel = inputImage.getPixel(x, y);
      int intensity = pixel.r.toInt();
      histogram[intensity]++;
    }
  }

  return histogram;
}

// Calculating the Cumulative Distribution Function
List<int> calculateCDF(List<int> histogram) {
  List<int> cdf = List<int>.filled(256, 0);
  int cumulative = 0;

  for (int i = 0; i < histogram.length; i++) {
    cumulative += histogram[i];
    cdf[i] = cumulative;
  }

  return cdf;
}

// Normalize the Cumulative Distribution Function
List<int> normalizeCDF(List<int> cdf) {
  int minValue = cdf.firstWhere((element) => element > 0);
  int maxValue = cdf.last;

  return cdf
      .map((value) => ((value - minValue) * 255 ~/ (maxValue - minValue)))
      .toList();
}

// Applying histogram equalization
img.Image? applyEqualization(img.Image? inputImage, List<int> normalizedCdf) {
  if (inputImage!.width <= 0 || inputImage.height <= 0) {
    // Handle the case where the input image is invalid
    return null;
  }

  img.Image equalizedImage =
      img.Image(width: inputImage.width, height: inputImage.height);

  for (int y = 0; y < inputImage.height; y++) {
    for (int x = 0; x < inputImage.width; x++) {
      img.Pixel pixel = inputImage.getPixel(x, y);
      int intensity = pixel.r.toInt();
      int equalizedIntensity = normalizedCdf[intensity];
      img.ColorRgb8 newPixel = img.ColorRgb8(
          equalizedIntensity, equalizedIntensity, equalizedIntensity);
      equalizedImage.setPixel(x, y, newPixel);
    }
  }

  return equalizedImage;
}


// APPLY SHARPENING KERNEL 

// ---------- Returns Grayscaled ------------ //
Future<Uint8List?> applySharpen(Uint8List originalImageBytes) async {
  img.Image? inputImage = img.decodeImage(originalImageBytes);
  if (inputImage == null || inputImage.width <= 0 || inputImage.height <= 0) {
    return null;
  }

  img.Image? grayscaleImage = toGrayscale(inputImage);
  if (grayscaleImage == null) {
    return null;
  }

  img.Image outputImage = img.Image(width: grayscaleImage.width, height: grayscaleImage.height);

  List<List<int>> kernel = [
    [0, -1, 0],
    [-1, 5, -1],
    [0, -1, 0],
  ];

  int width = grayscaleImage.width;
  int height = grayscaleImage.height;

  for (int y = 1; y < height - 1; y++) {
    for (int x = 1; x < width - 1; x++) {
      int sumIntensity = 0;

      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          int factor = kernel[ky + 1][kx + 1];
          img.Pixel pixel = grayscaleImage.getPixel(x + kx, y + ky);
          int intensity = pixel.r.toInt(); // In grayscale, r=g=b
          sumIntensity += intensity * factor;
        }
      }

      int newIntensity = sumIntensity.clamp(0, 255);
      outputImage.setPixel(x, y, img.ColorRgb8(newIntensity, newIntensity, newIntensity));
    }
  }

  Uint8List? outputBytes = img.encodePng(outputImage);
  return outputBytes;
}

// 3/20/24 Edit: Calculate the laplacian values and discard top 5%
Future<List<double>> calculateLaplacianValues(Uint8List imageBytes) async {
  img.Image? image = img.decodeImage(imageBytes);
  if (image == null) {
    throw Exception("Failed to decode image");
  }
  img.Image grayscaleImage = img.grayscale(image);

  // Laplacian kernel
  List<List<int>> kernel = [
    [0, 1, 0],
    [1, -4, 1],
    [0, 1, 0],
  ];

  List<double> laplacianValues = [];

  for (int y = 1; y < grayscaleImage.height - 1; y++) {
    for (int x = 1; x < grayscaleImage.width - 1; x++) {
      double sum = 0.0;
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          img.Pixel pixel = grayscaleImage.getPixel(x + kx, y + ky);
          double intensity = pixel.r.toDouble(); // In grayscale, r=g=b
          sum += intensity * kernel[ky + 1][kx + 1];
        }
      }
      laplacianValues.add(sum.abs());
    }
  }

  return laplacianValues;
}


// APPLY MEDIAN FILTER 

// ---------- Returns Grayscaled ------------ //
Future<Uint8List?> applyMedian(Uint8List originalImageBytes) async {
  img.Image? inputImage = img.decodeImage(originalImageBytes);
  if (inputImage == null) {
    return null;
  }

  // Convert to grayscale before applying median filter
  img.Image? grayscaleImage = toGrayscale(inputImage);
  if (grayscaleImage == null) {
    return null; // or throw an exception
  }

  int radius = 1;

  img.Image outputImage = img.Image(width: grayscaleImage.width, height: grayscaleImage.height);

  for (int y = radius; y < grayscaleImage.height - radius; y++) {
    for (int x = radius; x < grayscaleImage.width - radius; x++) {
      List<int> intensityValues = [];

      for (int dy = -radius; dy <= radius; dy++) {
        for (int dx = -radius; dx <= radius; dx++) {
          img.Pixel pixel = grayscaleImage.getPixel(x + dx, y + dy);
          int intensity = pixel.r.toInt(); // In grayscale, r=g=b
          intensityValues.add(intensity);
        }
      }

      intensityValues.sort();
      int medianIntensity = intensityValues[intensityValues.length ~/ 2];
      outputImage.setPixel(x, y, img.ColorRgb8(medianIntensity, medianIntensity, medianIntensity));
    }
  }

  Uint8List? outputBytes = img.encodePng(outputImage);
  return outputBytes;
}

// Calculating Global Standard Deviation of image
Future<double> calculateStandardDeviationOfImageBytes(Uint8List imageBytes) async {
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) {
    throw Exception("Failed to decode image");
  }

  img.Image grayscale = img.grayscale(image);

  // calculate the mean of the pixel values
  int totalPixels = grayscale.width * grayscale.height;
  double sum = 0;
  for (int y = 0; y < grayscale.height; y++) {
    for (int x = 0; x < grayscale.width; x++) {
      img.Pixel pixel = grayscale.getPixel(x, y);
      sum += pixel.r.toInt();
    }
  }
  double mean = sum / totalPixels;

  // calculate variance
  double varianceSum = 0;
  for (int y = 0; y < grayscale.height; y++) {
    for (int x = 0; x < grayscale.width; x++) {
      img.Pixel pixel = grayscale.getPixel(x, y);
      double luminance = pixel.r.toDouble();
      varianceSum += pow(luminance - mean, 2);
    }
  }
  double variance = varianceSum / totalPixels;

  // sd = sqrt(var)
  return sqrt(variance);
}

// Edit 3/28/24: For a more nuanced solution, also calculate location standard deviation
Future<double> calculateLocalStandardDeviation(Uint8List imageBytes) async {
  img.Image? image = img.decodeImage(imageBytes);
  if (image == null) {
    throw Exception("Failed to decode image");
  }

  image = img.grayscale(image);

  int windowSize = 5; // Define the size of the local window to examine
  double totalLocalSD = 0.0;
  int count = 0;

  for (int y = 0; y <= image.height - windowSize; y += windowSize) {
    for (int x = 0; x <= image.width - windowSize; x += windowSize) {
      double sum = 0.0;
      double sumSquared = 0.0;
      int pixelCount = 0;

      // calculate sum and sum squared within the window
      for (int winY = y; winY < y + windowSize; winY++) {
        for (int winX = x; winX < x + windowSize; winX++) {
          img.Pixel pixel = image.getPixel(x, y);
          int pixelValue = pixel.r.toInt();
          sum += pixelValue;
          sumSquared += pixelValue * pixelValue;
          pixelCount++;
        }
      }

      // calculate var and find sd
      double mean = sum / pixelCount;
      double variance = (sumSquared / pixelCount) - (mean * mean);
      double localSD = sqrt(variance);

      totalLocalSD += localSD;
      count++;
    }
  }

  // average local standard deviation
  return totalLocalSD / count;
}

// Comparing with Threshold values to see if an image requires image enhancement
Future<bool> shouldSmooth(Uint8List imageBytes) async {
  double gsd = await calculateStandardDeviationOfImageBytes(imageBytes);
  // Edit 3/28/24
  double lsd = await calculateLocalStandardDeviation(imageBytes);
  return gsd > 50 || lsd > 30; // Salt and pepper noise threshold values
}

Future<bool> shouldEqualize(Uint8List imageBytes) async {
  double sd = await calculateStandardDeviationOfImageBytes(imageBytes);
  return sd < 30; // Adjusted threshold to account for extreme conditions
}

// 3/20/24 Edit
Future<bool> shouldSharpen(Uint8List imageBytes) async {
  List<double> laplacianValues = await calculateLaplacianValues(imageBytes);
  laplacianValues.sort();
  // Discard the top 5%
  int discardIndex = (laplacianValues.length * 0.95).floor();
  laplacianValues = laplacianValues.sublist(0, discardIndex);
  double medianLaplacianValue = laplacianValues[laplacianValues.length ~/ 2];

  //return medianLaplacianValue < 30; // Sharpens almost everything
  return medianLaplacianValue > 13; // Sharpens for more pixelated images, took average of testing values
}


// AUTO ENHANCE FUNCTION

Future<Uint8List?> autoEnhance(Uint8List originalImageBytes) async {
  Uint8List? enhancedImageBytes = originalImageBytes;

  // Determine whether to smooth image
  bool smooth = await shouldSmooth(originalImageBytes);
  if (smooth) { 
    Uint8List? smoothedBytes = await applyMedian(originalImageBytes);
    if (smoothedBytes != null) {
      enhancedImageBytes = smoothedBytes;
    }
  }
  // Determine whether to apply sharpening
  bool sharpen = await shouldSharpen(originalImageBytes);
  if (sharpen){
    Uint8List? sharpenedBytes = await applySharpen(enhancedImageBytes); 
    if (sharpenedBytes != null) {
      enhancedImageBytes = sharpenedBytes;
    }
  }

  // Determine whether to equalize the histogram
  bool equalize = await shouldEqualize(enhancedImageBytes);
  if (equalize) {
    Uint8List? equalizedBytes = await applyHistogramEqualization(enhancedImageBytes);
    if (equalizedBytes != null) {
      enhancedImageBytes = equalizedBytes;
    }
  }

  // If no image enhancements, still return a grayscale
  if (!(smooth) && !(sharpen) && !(equalize)){
    img.Image? grayscaleImage = toGrayscale(img.decodeImage(originalImageBytes)!);
    if (grayscaleImage != null) {
      Uint8List? grayscaleBytes = img.encodeJpg(grayscaleImage);
      enhancedImageBytes = grayscaleBytes;
    }
  }

  return enhancedImageBytes;
}
