/*
  The main entry point for the Field Guide Vision app
  Author: Omar Nweashe
  Created on: 10/26/2023
  Modified on: 01/19/2024 by Omar Nweashe
  Modified on: 02/16/2024 by Omar Nweashe
  Modified on: 03/28/2024 by Omar Nweashe
*/
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './pages/home_page.dart';
import 'package:dcdg/dcdg.dart';

/*
  The main function that starts the program
*/
void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MdeApp());
}

/*
  Class that runs the the app object
*/
class MdeApp extends StatelessWidget {

  const MdeApp({super.key});

  /*
    Build function that builds the landing page
    @param - context - buildcontext for UI/widget location
  */
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Field Guide Vision',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }

}