
import 'package:flutter/material.dart';
import 'src/login_screen.dart';

class Tryst{
  MaterialApp getMaterialApp(){
    return MaterialApp(
      title: 'Client App',
      theme: _getThemeData(),
      home: _getLoginScreen(),
    );
  }

  ThemeData _getThemeData(){
  return ThemeData(
    primaryColor: Colors.purple,
    accentColor: Colors.purpleAccent
  );
}

Scaffold _getLoginScreen(){
  return LoginScreen().getScaffold();
}
}