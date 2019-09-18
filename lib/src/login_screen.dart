// A file that has User interface of the login
// screen

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication.dart';
import 'mech_app/mech_app_main.dart';

class LoginScreen{

  Scaffold getScaffold(){
    return Scaffold(
      body: LoginScreenBody(),
    );
  }
  
}

class LoginScreenBody extends StatelessWidget {

  static BuildContext _context;
  static FirebaseUser _user;

  @override
  Widget build(BuildContext context) {
    _addContext(context);
    return _getLoginContainer();
  }

  void _addContext(BuildContext context){
    _context = context;
  }

  Container _getLoginContainer(){
    return Container(
      padding: _getContainerPadding(),
      child: _getLoginColumn(),
    );
  }

  EdgeInsetsGeometry _getContainerPadding(){
    return EdgeInsets.only(
        left: 10.0,
        right: 10.0,
        top: 150.0,
      );
  }

  Column _getLoginColumn(){
    return Column(
      children: <Widget>[
        _getLogoImage(),
        _createGoogleLoginButton()
      ],
    );
  }

  Widget _getLogoImage(){
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: FlutterLogo(
        size: 250.0,
      ),
    );
  }

  RaisedButton _createGoogleLoginButton(){
    return RaisedButton(
      color: Color(0xffde5246),
      child: _getGoogleButtonContent(),
      onPressed: (){ _whenGoogleLoginPressed(); },
    );
  }

  Row _getGoogleButtonContent(){
    return Row(
      children: <Widget>[
        _getGoogleButtonText()
      ],
    );
  }

  Text _getGoogleButtonText(){
    return Text(
      'Sign In with Google',
      style: TextStyle(
        color: Colors.white
      ),
    );
  }

  Future<void> _whenGoogleLoginPressed() async{
    await _login();
    _startMechApp();
  }

  Future<Null> _login() async{
    _user = await Authenticator().signInWithGoogle();
  }

  void _startMechApp(){
    if(_isLoginSuccessful()){
      MechApp(_user, _context).start();
    }
  }

  bool _isLoginSuccessful(){
    if(_user == null){
      print('Login Failed @ LoginScreenBody');
      return false;
    }
    else{
      print('Login Success @ LoginScreenBody');
      return true;
    }
  }
}