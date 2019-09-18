
import 'package:flutter/material.dart';
import 'add_request_form_screen.dart';
import 'request_listing_screen.dart';
import '../../authentication.dart';
import '../../login_screen.dart';

class MainScreen extends StatelessWidget {

  static BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: _buildMainScreen(),
    );
  }

  Widget _buildMainScreen(){
    return Column(
      children: <Widget>[
        _createInstructionsBlock(),
        _createMenu()
      ],
    );
  }

  Widget _createInstructionsBlock(){
    return Container(
      height: _getInstructionsBlockHeight(),
      color: Theme.of(_context).primaryColor,
      child: _createInstructionsColumn(),
    );
  }

  double _getInstructionsBlockHeight(){
    double screenHeight = MediaQuery.of(_context).size.height;
    double blockHeight = screenHeight / 1.6;
    return blockHeight;
  }

  Widget _createInstructionsColumn(){
    return Column(
      children: <Widget>[
        _createWelcomeMsg(),
        _createInstructionsMsg()
      ],
    );
  }

  Widget _createWelcomeMsg(){
    return Container(
      alignment: Alignment.centerLeft,
      height: _getWelcomeContainerHeight(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 15.0,
          right: 15.0
          ),
        child: Text(
          'Welcome To Mech_app',
          style: _getWelcomeTextStyle(),
        ),
      ),
    );
  }

  double _getWelcomeContainerHeight(){
    double screenHeight = MediaQuery.of(_context).size.height;
    double containerHeight = screenHeight / 3.5;
    return containerHeight;
  }

  TextStyle _getWelcomeTextStyle(){
    return TextStyle(
      color: Colors.white,
      fontSize: 40,
      fontWeight: FontWeight.bold
    );
  }

  Widget _createInstructionsMsg(){
    return Expanded(
      child: _createInstructionsMsgSettings(),
    );
  }

  Widget _createInstructionsMsgSettings(){
    return Container(
        alignment: Alignment.centerLeft,
        color: Theme.of(_context).accentColor,
        child: Padding(
          padding: EdgeInsets.only(
            left: 15.0, 
            right:15.0
            ),
          child: _getInstructionsTextColumn(),
        ),
    );
  }

  Widget _getInstructionsTextColumn(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _getHelloText(),
        _getSparePadding(5.0),
        _getInstructionsText()

      ],
    );
  }

  Widget _getHelloText(){
    return Text(
      'Hello!',
      style: TextStyle(
        fontSize: 25.0,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
    );
  }

  Widget _getInstructionsText(){
    return Text(
      'Mech_app allows you to get quick quotes' +
      'from mechanics arround you. Select one' +
      'of the options below',
      style: _getInstructionsTextStyle(),
    );
  }

  TextStyle _getInstructionsTextStyle(){
    return TextStyle(
      fontSize: 25.0,
      color: Colors.white,
      fontWeight: FontWeight.w300
    );
  }

  Widget _createMenu(){
    return Expanded(
          child: Container(
            color: Theme.of(_context).accentColor,
            child:  _createMenuItemsList(),
          ),
    );
  }

  Widget _createMenuItemsList(){
    return ListView(
      children: <Widget>[
        _createAddRequestTile(),
        _createActiveRequestTile(),
        _createArchivedRequestTile(),
        _createLogoutTile()
      ],
    );
  }

  Widget _createAddRequestTile(){
    return ListTile(
        title: _getAddTitleText(),
        onTap: (){
          _whenAddRequestPressed();
        },
      );
  }

  Widget _getAddTitleText(){
    return Text(
      'Add a Request For Quote',
      style: _getMenuListTextStyle(),
    );
  }

  void _whenAddRequestPressed(){
    Navigator.push(_context, _getAddFormRoute());
  }

  MaterialPageRoute _getAddFormRoute(){
    return MaterialPageRoute(
      builder: (BuildContext context){
        return AddRequestFormScreen();
      }
    );
  }

  Widget _createActiveRequestTile(){
    return ListTile(
          title: _getActiveTitleText(),
          onTap: (){
            _whenActiveRequestPressed();
          },
        );
  }

  Widget _getActiveTitleText(){
    return Text(
      'View Active Requests',
      style: _getMenuListTextStyle(),
    );
  }

  void _whenActiveRequestPressed(){
    Navigator.push(_context, _getActiveRoute());
  }

  MaterialPageRoute _getActiveRoute(){
    return MaterialPageRoute(
      builder: (BuildContext context){
        return RequestListingScreen('active');
      }
    );
  }

  Widget _createArchivedRequestTile(){
    return ListTile(
          title: _getArchivedTitleText(),
          onTap: (){
            _whenArchivedRequestPressed();
          },
        );
  }

  Widget _getArchivedTitleText(){
    return Text(
      'View Archived Requests',
      style: _getMenuListTextStyle(),
    );
  }

  void _whenArchivedRequestPressed(){
    Navigator.push(_context, _getArchivedRoute());
  }

  MaterialPageRoute _getArchivedRoute(){
    return MaterialPageRoute(
      builder: (BuildContext context){
        return RequestListingScreen('archived');
      }
    );
  }

  Widget _createLogoutTile(){
    return ListTile(
          title: _getLogoutText(),
          onTap: (){
            _whenLogoutPressed();
          },
        );
  }

  Widget _getLogoutText(){
    return Text(
      'Logout',
      style: _getMenuListTextStyle(),
    );
  }

  Future<void> _whenLogoutPressed() async{
    await Authenticator().logout();
    MaterialPageRoute route = _getLoginRoute();
    Navigator.push(_context, route);
  }

  MaterialPageRoute _getLoginRoute(){
    return MaterialPageRoute(
      builder: (BuildContext context){
        return LoginScreen().getScaffold();
      }
    );
  }

  TextStyle _getMenuListTextStyle(){
    return TextStyle(
      color: Colors.white
    );
  }

  Padding _getSparePadding(double amount){
    return Padding(
      padding: EdgeInsets.only(top: amount),
    );
  }




}