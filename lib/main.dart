import 'package:flutter/material.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(BookSnapApp());
}

class BookSnapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSnap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}