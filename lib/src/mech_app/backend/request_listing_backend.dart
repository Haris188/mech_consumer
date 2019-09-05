import 'backend-methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RequestListingBackend{

  static String _consumerId;
  static String _screenType;
  static Map<String, dynamic> _locationMap = {};
  static String _status;
  static List<String> _requestIds;

  Future<List<Map<String,dynamic>>> getRequestsFromDbFor(String screen) async{
    List<Map<String, dynamic>> requests;
    _screenType = screen;
    _consumerId = await BackendMethods().getCurrentUid();
    _locationMap = await BackendMethods().getConsumerLocation();
    _changeRequestStatusFor(_screenType);
    await _getConsumerRequestIds();
    //requests = await _getRequests();
    return requests;
  }

  void _changeRequestStatusFor(String screen){
    if(screen == 'active'){
      _status = 'open';
    }
    else{
      _status = 'close';
    }
  }

  Future<void> _getConsumerRequestIds() async{
    List<String> listOfIds;

    // Firestore.instance.collection('consumer_accouts')
    //   .document(_consumerId).collection('requests')
    //   .document('request_ids').
  }
}