
# FieldGuideVision

This is the official repository for **FieldGuideVision** Android/iOS application. This application translates images of National Standard Road and Street signs from Arabic into English.

  
## Prerequisites

-   Make sure is Flutter and Dart are installed correctly through the official flutter documentation:
    

	- [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
    
	- If you're using VScode as your IDE, then ctrl+shift+p and search for doctor and run it.
    - If you encounter unable to start flutter daemon, run this command in your terminal:
	    -    ``` git config --global --add safe.directory '*'```
    - Helpful Links and Tutorials:
    

		-   [https://docs.flutter.dev/get-started/test-drive](https://docs.flutter.dev/get-started/test-drive)
    
		-   [https://flutter.github.io/samples/#?platform=web](https://flutter.github.io/samples/#?platform=web)
    
		-   Basic tutorial: [https://codelabs.developers.google.com/codelabs/flutter-codelab-first?hl=en#0](https://codelabs.developers.google.com/codelabs/flutter-codelab-first?hl=en#0)
    
		-   Dart Language Guide: [https://dart.dev/language](https://dart.dev/language)
    

-   Make sure to set up the Android Studio Device VM ready.
    
-   Make sure to set up iOS Simulation:
    

-   For testing, it will require the user to have an Apple computer.
    
-   Download XCode, which will be used to load the iOS simulator.
    
-   Download all iOS simulator versions you plan on using.
    
-   In XCode, open the /ios/Runner.xcworkspace.
    
-   In the Runner tab, go to Signing & Capabilities and change the team to your own account.
    
-   Change bundle identifier name to your own custom name.
    

## Notes

  

1. The main entry point to this project is **/lib/main.dart**.

2. Brief top level description of **/lib/pages**:

	- **/lib/pages/extracted_text.dart**:

		- This file handles the text extraction components.

		- Replace the uri string in **_extractTextFromImage** function with your own azure OCR API link.

		- Replace **Ocp-Apim-Subscription-Key** with your own key.

- **/lib/pages/help_page.dart**:

	- This is the help page component for explaining tips to maximize the effectiveness/accuracy of Field Guide Vision.

- **/lib/pages/home_page.dart**:

	- This is the home (landing) page of the FieldGuideVision App.

- **/lib/pages/image_confirmation_popup.dart**:

	- This is the home page popup component.

- **/lib/pages/image_enhancement_page.dart**:

	- This file holds the components for the Image Enhancement page.

- **/lib/pages/image_manual_page.dart**:
	- Main code for housing the manual image enhancement page components.

- **/lib/pages/text_translation_page.dart**:

	- The text translation page that houses the components and widgets for the text translation page.

  
  

3. Brief top level of the **/lib/utils**:

- **/lib/utils/awstranslate.dart**:

	- This file holds the main backend functionality for the Amazon translation API calls the app makes.

	- Replace **accesskey** in translateText function with AWS account credentials.

	- Replace **secretkey** in translateText function with AWS account credentials.

  

- **/lib/utils/azuretranslate.dart**:

	- This file holds the main backend functionality for the Microsoft translation API calls the app makes.

	- Replace the uri string in **translateText** function with your own Azure account API link.

	- Replace **Ocp-Apim-Subscription-Key** in translateText function, headers variable with your own Azure account key.

  
- **/lib/utils/googletranslate.dart**:

	- This file holds the main backend functionality for the Amazon translation API calls the app makes.
	- Replace **client_id**, **private_key_id**, **private_key** and **client_email** in the credentials variable with your own Google account credentials.

  

- **/lib/utils/image_enhancement.dart**:

	- This file holds the main backend functionality for the image enhancement techniques we employ.

 
- **/lib/utils/location_dictionary.dart**:

	- This class handles the backend location-based features of the application.

  

- **/lib/utils/manual_adjust.dart**:

	- This file provides methods for the manual enhancement of images on the **/lib/utils/image_manual_page.dart**.