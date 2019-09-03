import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend-methods.dart';


class AddRequestBackend{

  static String _currentUid;
  static Map<String,dynamic> _requestInfoMap = {};
  static Map<String, dynamic> _location = {};
  static String _requestId;
  static Map<String, dynamic> _vehicleInfo = {};

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

    _requestInfoMap = requestMap;
    _location = await BackendMethods().getConsumerLocation();
    _requestId = Timestamp.now().microsecondsSinceEpoch.toString();
    _extractVehicleInfoFromRequest();
    _addAdditionalDataToMap();
    dataSubmitCheck = await _addDataToRequest();
    vehicleSubmitCheck = await _addVehicleToRequest();
    statusSubmitCheck = await _addStatusToRequest();
    reqIdSubmitCheck = await _addRequestIdToConsumerData() ;

    if(
      vehicleSubmitCheck &&
      dataSubmitCheck &&
      statusSubmitCheck &&
      reqIdSubmitCheck
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
    _requestInfoMap.remove('file');
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
      .document(_location['city']).collection(_requestId)
      .document('request_info').setData(_requestInfoMap)
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
      .document(_location['city']).collection(_requestId)
      .document('request_info').collection('vehicle')
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
      .document(_location['city']).collection(_requestId)
      .document('request_info')
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
      .setData({'$_requestId': _requestId})
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
}