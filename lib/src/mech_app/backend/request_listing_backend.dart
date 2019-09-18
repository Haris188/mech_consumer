import 'backend-methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RequestListingBackend{

  static String _consumerId;
  static String _screenType;
  static Map<String, dynamic> _locationMap = {};
  static String _status;
  static List<dynamic> _requestIds;
  static List<Map<String, dynamic>> _requestsList;

  Future<List<Map<String,dynamic>>> getRequestsFromDbFor(String screen) async{
    
    _screenType = screen;
    _consumerId = await BackendMethods().getCurrentUid();
    _locationMap = await BackendMethods().getConsumerLocation();
    _changeRequestStatusFor(_screenType);
    await _getConsumerRequestIds();
    _requestsList = await _getRequests();
    _removeNullsInRequestsList();
    _prepareRequestsForReletiveScreen();
    print(_requestsList.length);
    return _requestsList;
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
    List<dynamic> listOfIds;

    await Firestore.instance.collection('consumer_accounts')
      .document(_consumerId).collection('requests')
      .document('request_ids').get()
      .then((idsSnap)async{
        if(idsSnap.data != null){
          listOfIds = await idsSnap.data['request_ids'];
        }
      }).catchError((e){
        print("Cant get Ids @ RequestListingBackend > getConsumerRequestIds()");
        print(e);
      });
    _requestIds = listOfIds;
  }

  Future<List<Map<String, dynamic>>> _getRequests() async{
    List<Map<String, dynamic>> listOfRequests = [];

    if(_requestIds != null){
      for (var requestId in _requestIds) {
      Map<String,dynamic> request = await _getRequestForId(requestId);
        if(request != null){
          if(request.containsValue('timeout')){
            break;
          }
        }
      listOfRequests.add(request);
      }
    }
    else{
      listOfRequests.add(null);
    }
    return listOfRequests;
  }

  Future<Map<String, dynamic>> _getRequestForId(String reqId) async{
    Map<String, dynamic> request;

    await Firestore.instance.collection('requests')
      .document(_locationMap['country'])
      .collection(_locationMap['state'])
      .document(_locationMap['city'])
      .collection('request_info')
      .document(reqId)
      .get()
      .then((reqSnap){
        request = reqSnap.data;
      })
      .timeout(Duration(seconds: 5), onTimeout: (){
        request = {'result': 'timeout'};
      })
      .catchError((e){
        print('Cant fetch requests @ RequestListingBackend > getRequestForId()');
        print(e);
      });
    return request;
  }

  void _removeNullsInRequestsList(){
    _requestsList.removeWhere((request){
      return (request == null);
    });
  }

  void _prepareRequestsForReletiveScreen(){
    if(_requestsList.length > 0){
      print(_requestsList);
      if(_screenType == 'active'){
        _requestsList.removeWhere((Map<String, dynamic> request){
        return (request['status'] == 'close');
      });
      }
      else if(_screenType == 'archived'){
        _requestsList.removeWhere((Map<String, dynamic> request){
        return (request['status'] == 'open');
      });
      }
    }
  }
}