
import 'package:flutter/material.dart';
import 'package:tryst/src/mech_app/screens/main_screen.dart';
import 'package:tryst/src/mech_app/screens/profile_makeup_screen.dart';
import 'src/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/mech_app/mech_app_main.dart';

class Tryst{
  MaterialApp getMaterialApp(){
    return MaterialApp(
      title: 'Client App',
      theme: _getThemeData(),
      home: _getLoginOrMain(),
    );
  }

  ThemeData _getThemeData(){
  return ThemeData(
    primaryColor: Colors.blue,
    accentColor: Colors.blue.shade700
  );
}

Widget _getLoginOrMain(){
  return FutureBuilder(
    future: _getFirebaseUser(),
    builder: (BuildContext context, AsyncSnapshot<FirebaseUser> user){
      if(user.data == null){
        print('if run');
        return _getLoginScreen();
      }
      else{
        print('else run');
        print(user.data.uid);
        return _getMainScreen(user.data, context);
      }
    },
  );
}

Future<FirebaseUser> _getFirebaseUser() async{
  return await FirebaseAuth.instance.currentUser();
}

Widget _getMainScreen(FirebaseUser user, BuildContext context){
  return FutureBuilder(
    future: MechApp(user, context).checkDbForCurrentUid(),
    builder: (BuildContext context, AsyncSnapshot<bool> result){
      if(result.data != null){
        if(result.data){
          return MainScreen();
        }
        else{
          return ProfileMakeupScreen(user);
        }
      }
      else{
        return Container();
      }
    },
  );
}

Scaffold _getLoginScreen(){
  return LoginScreen().getScaffold();
}
}