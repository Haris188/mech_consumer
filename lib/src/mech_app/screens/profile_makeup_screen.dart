import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../backend/profile_makeup_backend.dart';
import 'main_screen.dart';
import 'car-info-form-screen.dart';

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
        _createStateTextField(),
        _createCityTextField()
      ],
    );
  }

  TextFormField _createStateTextField(){
    return TextFormField(
      controller: stateController,
      decoration: InputDecoration(
        labelText: 'State',
        hintText: 'In which state do you live?',
      ),
      validator: (value){return _validateState(value);},
    );
  }

  
  String _validateState(String value){
    if(value.length < 1){
      return 'Required';
    }
    else{
      return null;
    }
  }

  TextFormField _createCityTextField(){
    return TextFormField(
      controller: cityController,
      decoration: InputDecoration(
        labelText: 'City',
        hintText: 'In which city do you live?',
      ),
      validator: (value){return _validateCity(value);},
    );
  }

  String _validateCity(String value){
    if(value.length < 1){
      return 'Required';
    }
    else{
      return null;
    }
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
    bool isValidation = _formKey.currentState.validate();
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
      'location': await _submitLocationToDb()
    };
    return resMap;
  }

  void _assertSubmitResults(Map<String, bool> resMap){
    print(resMap);
    if(
      resMap['car'] && resMap['location']
    ){
      _openMainScreen();
    }
  }

  Future<bool> _submitLocationToDb()async{
    _prepareLocationMap();
    return await ProfileMakeupBackend(widget._user)
        .submitLocationToDb(location);
  }

  void _prepareLocationMap(){
    location = {
      'country': 'canada',
      'state': stateController.text,
      'city': cityController.text
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
