import 'package:flutter/material.dart';

class CarInfoFormScreen extends StatefulWidget {
  @override
  _CarInfoFormScreenState createState() => _CarInfoFormScreenState();
}

class _CarInfoFormScreenState extends State<CarInfoFormScreen> {

  static Map<String, dynamic> _carInfoMap = {};
  static final TextEditingController
    _yearController = TextEditingController();
  static final TextEditingController
    _makeController = TextEditingController();
  static final TextEditingController
    _modelController = TextEditingController();
  static final TextEditingController
    _trimController = TextEditingController();
  static final TextEditingController
    _transmissionController = TextEditingController();
  static final TextEditingController
    _fuelTypeController = TextEditingController();
  static final TextEditingController
    _driveTrainController = TextEditingController();
  static final TextEditingController
    _mileageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  BuildContext _context;
      

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: _buildCarInfoForm(),
    );
  }

  Widget _buildCarInfoForm(){
    return Container(
      padding: EdgeInsets.only(
        top: 20.0,
        left: 15.0,
        right: 15.0
      ),
      child: ListView(
        children: <Widget>[
          Form(
            key: _formKey,
            child: _createCarInfoFieldColumn(),
          ),
        ],
      )
    );
  }

  Widget _createCarInfoFieldColumn(){
    return Column(
      children: <Widget>[
        _createYearField(_context),
        _createMakeField(_context),
        _createModelField(_context),
        _createTrimField(_context),
        _createTransmissionField(_context),
        _createFuelTypeField(_context),
        _createDriveTrainField(_context),
        _createMileageField(_context),
        _createSubmitButton()
      ],
    );
  }

  Widget _createYearField(BuildContext context){
    return TextFormField(
      controller: _yearController,
      decoration: InputDecoration(
        hintText: "What year your car was made?",
        labelText: 'Year'
      ),
      keyboardType: TextInputType.number,
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createMakeField(BuildContext context){
    return TextFormField(
      controller: _makeController,
      decoration: InputDecoration(
        hintText: "Toyota, Honda, etc",
        labelText: 'Make'
      ),
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createModelField(BuildContext context){
    return TextFormField(
      controller: _modelController,
      decoration: InputDecoration(
        hintText: "Civic, Prius, etc",
        labelText: 'Model'
      ),
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createTrimField(BuildContext context){
    return TextFormField(
      controller: _trimController,
      decoration: InputDecoration(
        hintText: "SXT, SXT+, etc",
        labelText: 'Trim'
      ),
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createTransmissionField(BuildContext context){
    return TextFormField(
      controller: _driveTrainController,
      decoration: InputDecoration(
        hintText: "AWD, RWD, etc",
        labelText: 'Drivetrain'
      ),
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createFuelTypeField(BuildContext context){
    return TextFormField(
      controller: _fuelTypeController,
      decoration: InputDecoration(
        hintText: "Diesel, Gas, etc",
        labelText: 'Fuel Type'
      ),
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createDriveTrainField(BuildContext context){
    return TextFormField(
      controller: _driveTrainController,
      decoration: InputDecoration(
        hintText: "Auto/Manual",
        labelText: 'Transmission'
      ),
      validator: (value){return _validateNull(value);},
    );
  }

  Widget _createMileageField(BuildContext context){
    return TextFormField(
      controller: _mileageController,
      decoration: InputDecoration(
        hintText: "How many Kms/Miles your car did?",
        labelText: 'Mileage'
      ),
      keyboardType: TextInputType.number,
      validator: (value){return _validateNull(value);},
    );
  }

  String _validateNull(String value){
    if(value.length == 0){
      return "Field is empty";
    }
    else{
      return null;
    }
  }

  RaisedButton _createSubmitButton(){
    return RaisedButton(
      child: _getSubmitButtonText(),
      onPressed: (){_whenSubmitPressed();},
    );
  }

  Widget _getSubmitButtonText(){
    return Text(
      'Submit'
    );
  }

  void _whenSubmitPressed(){
    bool validationTrue = _formKey.currentState.validate();
    if(validationTrue){
      _addInfoToMap();
      _openProfileMakeupScreen();
    }
  }

  void _addInfoToMap(){
    _carInfoMap = {
      'year': _yearController.text,
      'make': _makeController.text,
      'model': _modelController.text,
      'trim': _trimController.text,
      'transmission': _transmissionController.text,
      'drivetrain' : _driveTrainController.text,
      'mileage': _mileageController.text,
      'fuel_type': _fuelTypeController.text
    };
  }

  void _openProfileMakeupScreen(){
    if(_carInfoMap.length > 0){
      Navigator.pop(context, _carInfoMap);
    }
    else{
      Navigator.pop(context);
    }
  }
}