import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../backend/profile_makeup_backend.dart';
import 'main_screen.dart';
import 'car-info-form-screen.dart';
import 'dart:convert';

class ProfileMakeupScreen extends StatefulWidget {

  final FirebaseUser _user;

  ProfileMakeupScreen(this._user);

  @override
  _ProfileMakeupScreenState createState() => _ProfileMakeupScreenState();
}

class _ProfileMakeupScreenState extends State<ProfileMakeupScreen> {

  static List carsList = [];
  static Map<String, dynamic> location = {};
  static BuildContext _context;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
   String _stateValue;
   String _cityValue;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: _createProfileFormWizard(),
    );
  }

  Container _createProfileFormWizard(){
    return Container(
      padding: EdgeInsets.only(
        top: 30.0,
        left: 15.0,
        right: 15.0
      ),
      child: _createFormColumn(),
    );
  }

  Column _createFormColumn(){
    return Column(
      children: <Widget>[
        _createLocationForm(),
        _createListOfCars(),
        _createAddCarButton(),
        _createSubmitButton(),
      ],
    );
  }

  Widget _createLocationForm(){
    return Expanded(
          child: Form(
            key: _formKey,
            child: _createLocationFormFields(),
      ),
    );
  }

  Column _createLocationFormFields(){
    return Column(
      children: <Widget>[
        // _createStateTextField(),
        // _createCityTextField()
        _createStateDropdownRow(),
        _createCityDropdownRow()
      ],
    );
  }

  Widget _createStateDropdownRow(){
    return Row(
      children: <Widget>[
        _getStateDropdownText(),
        _createStateDropdown()
      ],
    );
  }

  Widget _getStateDropdownText(){
    return Text('Select your State: ');
  }

  Widget _createStateDropdown(){
    return FutureBuilder(
      future: _getStates(),
      builder: (BuildContext context, AsyncSnapshot stateListSnap){
        return DropdownButton(
          value: _stateValue,
          items: stateListSnap.data,
          onChanged: (value){_replaceStateWith(value);},
        );
      },
    );
  }

  Future<List<DropdownMenuItem>>_getStates() async{
    List<dynamic> listOfStates = 
      json.decode(await rootBundle.loadString('lib/src/mech_app/assets/states.json'));
    List<DropdownMenuItem<String>> itemList
      = listOfStates.map<DropdownMenuItem<String>>((state){
          return DropdownMenuItem<String>(
            value: state['name'],
            child: Text(state['name']),
          );
      }).toList();
    return itemList;
  }

  void _replaceStateWith(String value){
    setState(() {
      _stateValue = value;
    });
  }

  Widget _createCityDropdownRow(){
    return Row(
      children: <Widget>[
        _getCityDropdownText(),
        _createCityDropdown()
      ],
    );
  }

  Widget _getCityDropdownText(){
    return Text('Select your City: ');
  }

  Widget _createCityDropdown(){
    return FutureBuilder(
      future: _getCities(),
      builder: (BuildContext context, AsyncSnapshot cityListSnap){
        return DropdownButton(
          value: _cityValue,
          items: cityListSnap.data,
          onChanged: (value){_replaceCityWith(value);},
        );
      },
    );
  }

  Future<List<DropdownMenuItem>>_getCities() async{
    List<dynamic> listOfStates = 
      json.decode(await rootBundle.loadString('lib/src/mech_app/assets/cities.json'));
    listOfStates = listOfStates.where((city){
      return city['admin'] == _stateValue;
    }).toList();
    List<DropdownMenuItem<String>> itemList
      = listOfStates.map<DropdownMenuItem<String>>((city){
          return DropdownMenuItem<String>(
            value: city['city'],
            child: Text(city['city']),
          );
      }).toList();
    return itemList;
  }

  void _replaceCityWith(String value){
    setState(() {
      _cityValue = value;
    });
  }

  Widget _createListOfCars(){
    if(carsList != null){
      return Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index){
                  return _getCarListTileNo(index);
                },
                itemCount: carsList.length,
        ),
      );
    }
    else{
      return Padding(padding: EdgeInsets.all(0.0),);
    }
  }

  ListTile _getCarListTileNo(int index){
    return ListTile(
      title: _getCarNameText(index),
      subtitle: _getCarYearText(index),
    );
  }

  Widget _getCarNameText(int index){
    if((carsList != null) && (carsList.length>0)){
      return Text(
      '${carsList[index]['make']} , ${carsList[index]['model']}',
      );
    }
    else{
      return Padding(padding: EdgeInsets.all(0.0),);
    }
  }

  Widget _getCarYearText(int index){
    if((carsList != null) && (carsList.length > 0)){
      return Text(
        '${carsList[index]['year']}',
      );
    }
    else{
      return Padding(padding: EdgeInsets.all(0.0),);
    }
  }

  Widget _createAddCarButton(){
    return RaisedButton(
        child: _getAddCarButtonText(),
        color: Theme.of(context).primaryColor,
        onPressed: (){
          _whenAddCarPressed();
        },
      );
    
  }

  Text _getAddCarButtonText(){
    return Text(
      'Add Car'
    );
  }

  Future<Null> _whenAddCarPressed() async{
    Map car = await _getCarInfoFromForm();
    if(car != null){
      if(car.length > 0){
        _addCarToArray(car);
      }
    }
  }

  Future<Map> _getCarInfoFromForm() async{
    var car = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context){
          return CarInfoFormScreen();
        }
      )
    );
    return car;
  }

  void _addCarToArray(Map car){
    setState(() {
      carsList.add(car);
    });
  }

  Widget _createSubmitButton(){
    return RaisedButton(
      child: _submitButtonText(),
      color: Theme.of(_context).primaryColor,
      onPressed: (){
        _whenSubmitPressed();
      },
    );
  }

  Text _submitButtonText(){
    return Text(
      'Done'
    );
  }

  Future<void> _whenSubmitPressed() async{
    bool isValidation = (_cityValue != null) && (_stateValue != null);
    if(
      carsList.length > 0 && 
      carsList != null &&
      isValidation
      ){
        final Map<String, bool> submitRes =
          await _getSubmitResultMap();
        return _assertSubmitResults(submitRes);
      }
    else{
      //_giveErrorSnack(context);
      print('Fields not filled');
    }
  }

  Future<Map<String, bool>> _getSubmitResultMap() async{
    Map<String, bool> resMap= {
      'car': await _submitCarDataToDb(),
      'location': await _submitLocationToDb(),
      'id': await _submitConsumerIdToDb()
    };
    return resMap;
  }

  void _assertSubmitResults(Map<String, bool> resMap){
    print(resMap);
    if(
      resMap['car'] && resMap['location'] && resMap['id']
    ){
      _openMainScreen();
    }
  }

  Future<bool> _submitLocationToDb()async{
    _prepareLocationMap();
    return await ProfileMakeupBackend(widget._user)
        .submitLocationToDb(location);
  }

  Future<bool> _submitConsumerIdToDb() async{
    print('subconsumerexecuted');
    return await ProfileMakeupBackend(widget._user)
        .submitConsumerIdToDb();
  }

  void _prepareLocationMap(){
    location = {
      'country': 'canada',
      'state': _stateValue,
      'city': _cityValue
    };
  }

  Future<bool> _submitCarDataToDb() async{
      return await ProfileMakeupBackend(widget._user)
        .submitCarDataToDb(carsList);
  }


  void _openMainScreen(){
    print('Open screen executed');
    MaterialPageRoute route = MaterialPageRoute(
      builder: (BuildContext context){
        return MainScreen();
      }
    );
    Navigator.push(context, route);
  }

  void _giveErrorSnack(BuildContext context){
    SnackBar snackBar = SnackBar(
      content: _getSnackBarText(),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget _getSnackBarText(){
    return Text(
      'Please Enter all the information'
    );
  }
}
