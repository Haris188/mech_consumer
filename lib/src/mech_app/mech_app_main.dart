import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/profile_makeup_screen.dart';
import 'screens/main_screen.dart';

class MechApp{

  static bool _uidAvailableInDb;
  final FirebaseUser _user;
  final BuildContext _context;

  MechApp(
    this._user, 
    this._context); 

  Future<Null> start() async{
    _uidAvailableInDb = await _checkDbForCurrentUid();
    if(_uidAvailableInDb){
      print('main');
      _navigateToScreenNamed('MainScreen');
    }
    else{
      print('profile');
      _navigateToScreenNamed('ProfileMakeup');
    }
  }

  Future<bool> _checkDbForCurrentUid() async{
    bool result;
    await Firestore.instance.collection('consumer_accounts')
      .document(_user.uid)
      .get()
      .then((doc){
        if(doc.data != null){
          if(doc.data['consumer_id'] == _user.uid){
            result = true;
            }
          }
        else{
          result = false;
        }
      })
      .catchError((e){
        print("error @ MechAppMain > checkfor ID");
        print(e);
      });
    return result;
  }

  void _navigateToScreenNamed(String screen){
    MaterialPageRoute route;
    if(screen == 'MainScreen'){
      route = _getMainScreenRoute();
    }
    else if(screen == 'ProfileMakeup'){
      route = _getProfileMakeupRoute();
    }
    if(route != null){
      Navigator.push(_context, route);
    }
  }

  MaterialPageRoute _getMainScreenRoute(){
    return MaterialPageRoute(
      builder: (_context){
        return MainScreen();
      }
    );
  }

  MaterialPageRoute _getProfileMakeupRoute(){
    return MaterialPageRoute(
      builder: (_context){
        return ProfileMakeupScreen(_user);
      }
    );
  }
}