import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'backend-methods.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddRequestBackend{

  static String _currentUid;
  static Map<String,dynamic> _requestInfoMap = {};
  static Map<String, dynamic> _location = {};
  static String _requestId;
  static Map<String, dynamic> _vehicleInfo = {};
  static List _recievedList =new List();

  Future<List> getVehiclesFromDb() async{
    List vehicleList = [];
    await _getCurrentUid();
    CollectionReference ref = _getVehiclesReference();
    await ref.getDocuments().then((onValue){
      print('Success @ AddRequestBackend > getVehicleInfo()');
      onValue.documents.forEach((doc){
        vehicleList.add(doc.data);
      });
    }).catchError((e){
      print('Unable to get vehicle info @ AddRequestBackend > getVehiclesFromdb()');
    });
    return vehicleList;
  }

  Future<void> _getCurrentUid()async{
    await FirebaseAuth.instance.currentUser()
      .then((user){
        _currentUid = user.uid;
      });
  }

  CollectionReference _getVehiclesReference(){
    CollectionReference ref = Firestore.instance
      .collection('consumer_accounts').document(_currentUid)
      .collection('vehicles');
    return ref;
  } 

  Future<bool> addRequestToDb(Map<String, dynamic> requestMap)async{
    bool vehicleSubmitCheck;
    bool dataSubmitCheck;
    bool statusSubmitCheck;
    bool reqIdSubmitCheck;
    bool videoSubmitCheck;
    bool reqIdAddCheck;

    _requestInfoMap = requestMap;
    _location = await BackendMethods().getConsumerLocation();
    _requestId = Timestamp.now().microsecondsSinceEpoch.toString();
    _extractVehicleInfoFromRequest();
    _addAdditionalDataToMap();
    videoSubmitCheck = await _addVideoToDb();
    dataSubmitCheck = await _addDataToRequest();
    vehicleSubmitCheck = await _addVehicleToRequest();
    statusSubmitCheck = await _addStatusToRequest();
    reqIdAddCheck = await _addRequestIdToConsumerData() ;
    reqIdSubmitCheck = await _updateRequestIdsList();
    


    if(
      vehicleSubmitCheck &&
      dataSubmitCheck &&
      statusSubmitCheck &&
      reqIdSubmitCheck &&
      videoSubmitCheck &&
      reqIdAddCheck
    ){
      return true;
    }
    else{
      return false;
    }
  }

  void _extractVehicleInfoFromRequest(){
    //print(_requestInfoMap);
    print(_requestInfoMap['vehicle']);
    _vehicleInfo = _requestInfoMap['vehicle'];
    _requestInfoMap.remove('vehicle');
    //print(_requestInfoMap);
  }

  void _addAdditionalDataToMap(){
    _requestInfoMap.addAll({
      'request_id' : _requestId,
      'consumer_id': _currentUid
    });
  }

  Future<bool> _addDataToRequest() async{

    bool result = false;

    await Firestore.instance.collection('requests')
      .document(_location['country']).collection(_location['state'])
      .document(_location['city']).collection('request_info')
      .document(_requestId).setData(_requestInfoMap)
      .whenComplete((){
        result = true;
      })
      .catchError((onError){
        result = false;
        print('Cant Upload @ add_request_backend > addDataToRequest()');
        print(onError.toString());
      });
    print(2);
    return result;
  }

  Future<bool> _addVehicleToRequest() async{

    bool result =  false;
    print(_vehicleInfo);
    await Firestore.instance.collection('requests')
      .document(_location['country']).collection(_location['state'])
      .document(_location['city']).collection('request_info')
      .document(_requestId).collection('vehicle')
      .add(_vehicleInfo)
      .whenComplete((){
        result = true;
      })
      .catchError((onError){
        result = false;
        print('Cant Upload @ add_request_backend > addVehicleToRequest()');
        print(onError.toString());
      });
    print(3);
    return result;
  }

  Future<bool> _addStatusToRequest() async{

    bool result = false;

    await Firestore.instance.collection('requests')
      .document(_location['country']).collection(_location['state'])
      .document(_location['city']).collection('request_info')
      .document(_requestId)
      .updateData({'status': 'open'})
      .whenComplete((){
        result = true;
      })
      .catchError((onError){
        result = false;
        print('Cant Upload @ add_request_backend > addStatusToRequest()');
        print(onError.toString());
      });

    return result;
  }

  Future<bool> _addRequestIdToConsumerData() async{

    bool result = false;

    await Firestore.instance.collection('consumer_accounts')
      .document(_currentUid).collection('requests')
      .document('request_ids')
      .get().then((onValue)async{
        if(onValue.data != null){
          _recievedList += await onValue.data['request_ids'];
          print('if run');
        }else{
          _recievedList = [];
          print('else run');
          print(onValue.data);
        }
      })
      .whenComplete((){
        result = true;
      })
      .catchError((onError){
        result = false;
        print('Cant Upload @ add_request_backend > addRequestIdToConsumerData()');
        print(onError.toString());
      });

    return result;
  }

  Future<bool> _updateRequestIdsList()async{
    bool result= false;

    _recievedList.add(_requestId);
    await Firestore.instance.collection('consumer_accounts')
      .document(_currentUid).collection('requests')
      .document('request_ids')
      .setData({'request_ids': _recievedList})
      .whenComplete((){
        result = true;
        _recievedList.clear();
      })
      .catchError((onError){
        print('cant upload @ add_request_backend > updateRequestIdsList()');
        print(onError);
        result = false;
      });
      return result;
  }

  Future<bool> _addVideoToDb() async{
    bool result;
    bool submitResult;
    bool linkSubmitResult;

    submitResult = await _submitVideoFile();
    _deleteFileFromInfoMap();
    result = submitResult;
    return result;
  }

  Future<bool> _submitVideoFile() async{
    bool submitResult= false;
    String vidDownloadUrl;
    File file = _requestInfoMap['file'];

    StorageReference ref = FirebaseStorage.instance.ref().child('$_requestId');
    await ref.putFile(file).onComplete.then((snap) async{
      vidDownloadUrl = await snap.ref.getDownloadURL();
      submitResult = true;
    });
    _requestInfoMap.addAll({'attachment_url' : vidDownloadUrl});
    return submitResult;
  }

  void _deleteFileFromInfoMap(){
    _requestInfoMap.remove('file');
  }
}