import 'dart:io';

import 'package:flutter/material.dart';
import '../backend/add_request_backend.dart';
import 'package:file_picker/file_picker.dart';

class AddRequestFormScreen extends StatefulWidget {
  @override
  _AddRequestFormScreenState createState() => _AddRequestFormScreenState();
}

class _AddRequestFormScreenState extends State<AddRequestFormScreen> {

  static Map<String,dynamic> _dropDownValue = {};
  static Map<String, dynamic> _requestInfoMap = {};
  static File _videoFile;
  static List _vehicleInfoList = [];
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static final TextEditingController _titleController =
    TextEditingController();
  static final TextEditingController _descriptionController =
    TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _getSubmitButton(),
      body: _createRequestFormContainer(),
    );
  }

  Widget _createRequestFormContainer(){
    return Container(
      margin: EdgeInsets.only(
        top: 50.0,
        left: 15.0,
        right: 15.0,
      ),
      child: _createRequestForm(),
    );
  }

  Widget _createRequestForm(){
    return Form(
      key: _formKey,
      child: _createRequestFormColumn(),
    );
  }

  Widget _createRequestFormColumn(){
    return Column(
      children: <Widget>[
        _createSelectVehicleDropDown(),
        _createTitleTextField(),
        _createDescriptionTextField(),
        _createAttachmentRow(),
        // _createSubmitButton(),
      ],
    );
  }

  Widget _createSelectVehicleDropDown(){
    return FutureBuilder<List>(
      initialData: [false],
      future: AddRequestBackend().getVehiclesFromDb(),
      builder: (BuildContext context, AsyncSnapshot<List> vehicles){
        if(vehicles.data[0] == false){
          return _loadingWidget();
        }else{
          _vehicleInfoList = vehicles.data;
          return _createDropDownRow();
        }
      },
    );
  }

  Widget _loadingWidget(){
    return Center(
      child: Text(
        'Loading...'
      ),
    );
  }

  Widget _createDropDownRow(){
    return Row(
      children: <Widget>[
        _createDropDownRowText(),
        _createDropDownButton()
      ],
    );
  }

  Text _createDropDownRowText(){
    return Text(
      'Please select you car '
    );
  }

  Widget _createDropDownButton(){
    return DropdownButton(
      value: null,
      onChanged: (newValue){
        _changeDropDownValue(newValue);
      },
      items: _createVehicleList(),
    );
  }

  void _changeDropDownValue(Map<String,dynamic> value){
    setState(() {
      _dropDownValue = value;
      _requestInfoMap.addAll({'vehicle': value});
    });
  }

  List<DropdownMenuItem<Map<String,dynamic>>> _createVehicleList(){
    return _vehicleInfoList.map<DropdownMenuItem<Map<String,dynamic>>>((value){
      return _createDropDownItem(value);
    }).toList();
  }

  Widget _createDropDownItem(Map<String, dynamic> vehicle){
    return DropdownMenuItem<Map<String,dynamic>>(
      value: vehicle,
      child: _getVehicleName(vehicle['model']),
    );
  }

  Widget _getVehicleName(String name){
    return Text(
      name,
      style: _getVehicleNameTextStyle(),
    );
  }

  TextStyle _getVehicleNameTextStyle(){
    // todo: when vehicle name style applies
  }

  Widget _createTitleTextField(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Tilte of your quote'
      ),
      controller: _titleController,
      validator: (value){
        return _validateNull(value);
      },
    );
  }

  Widget _createDescriptionTextField(){
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe your problem'
      ),
      controller: _descriptionController,
      validator: (value){
        return _validateNull(value);
      },
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

  Widget _createAttachmentRow(){
    return Row(
      
      children: <Widget>[
        _createAttachmentButton(),
        _createAttachmentIndicator()
      ],
    );
  }

  Widget _createAttachmentButton(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FlatButton(
        child: _getAttachmentButtonText(),
        color: Theme.of(context).accentColor,
        onPressed: (){
          _selectAttachment();
        },
      ),
    );
  }

  Text _getAttachmentButtonText(){
    return Text(
      'Select Attachment',
      style: _getAttachmentButtonTextStyle(),
    );
  }

  TextStyle _getAttachmentButtonTextStyle(){
    return TextStyle(
      color: Colors.white
    );
  }

  Future<void> _selectAttachment()async{
    final File videoFile = await FilePicker.getFile(type: FileType.VIDEO);
    setState(() {
      _videoFile = videoFile;
    });
  }

  Widget _createAttachmentIndicator(){
    if(_videoFile == null){
      return _sparePadding();
    }
    else{
      return _checkIndicatorIcon();
    }
  }

  Widget _sparePadding(){
    return Padding(
      padding: EdgeInsets.only(),
    );
  }

  Widget _checkIndicatorIcon(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        Icons.check_circle,
        color: Theme.of(context).accentColor,
      ),
    );
  }

  Widget _getSubmitButton(){
    return FloatingActionButton(
      child: Icon(Icons.check),
      backgroundColor: Theme.of(context).accentColor,
      onPressed: (){
        _whenSubmitPressed();
      },
    );
  }

  Future<void> _whenSubmitPressed() async{
    bool nullCheck = _formKey.currentState.validate();
    bool submitSuccess = false;

    if(nullCheck){
      if(_videoFile != null){
        _prepareRequestInfoMap();
        submitSuccess = await AddRequestBackend().addRequestToDb(_requestInfoMap);
        if(submitSuccess){
          Navigator.pop(context);
        }
      }
    }
  }

  void _prepareRequestInfoMap(){
    _requestInfoMap.addAll({
      'title' : _titleController.text,
      'description' : _descriptionController.text,
      'file' : _videoFile,
    });
  }
}