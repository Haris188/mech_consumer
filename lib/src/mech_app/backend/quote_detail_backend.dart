
import 'package:cloud_firestore/cloud_firestore.dart';
import 'backend-methods.dart';

class QuoteDetailBackend{
  static Map<String, dynamic> _mechInfoMap;
  static String _mechId;
  static Map<String,dynamic> _mechAddressInfo;
  static Map<String, dynamic> _consumerLocation;
  final String _reqId;

  QuoteDetailBackend(this._reqId);

  Future<Map<String,dynamic>> getMechInfo(String mechId) async{
    _setMechId(mechId);
    await _getConsumerLocation();
    await _getMechNameInfoFromDb();
    await _getMechAddressInfoFromDb();
    _putAddressInfoToInfoMap();
    return _mechInfoMap;
  }

  void _setMechId(String mechId){
    _mechId = mechId;
  }

  Future<void> _getConsumerLocation() async{
    _consumerLocation = await BackendMethods().getConsumerLocation();
  }

  Future<void> _getMechNameInfoFromDb() async{
    await Firestore.instance.collection('provider_accounts')
      .document(_mechId)
      .get()
      .then((docSnap){
        _mechInfoMap = docSnap.data;
      })
      .catchError((e){
        print('Cant get Mech info @ QuoteDetailBackend > getMechNameInfoFromDb()');
        print(e);
      });
  }

  Future<void> _getMechAddressInfoFromDb() async{
    await Firestore.instance.collection('provider_accounts')
      .document(_mechId)
      .collection('locations')
      .getDocuments()
      .then((docsSnap){
        _mechAddressInfo = docsSnap.documents.first.data;
      })
      .catchError((e){
        print('Cant get Mech address @ QuoteDetailBackend > getMechAddressInfoFromDb()');
        print(e);
      });
  }

  void _putAddressInfoToInfoMap(){
    _mechInfoMap.addAll(_mechAddressInfo);
  }

  Future<bool> acceptQuote() async{
    await _getConsumerLocation();
    List<bool> resultList = [
      await _deleteRejectedQuotes(),
      await _changeReqStatusToClosed(),
      await _moveReqToMechArchived()
    ];
    if(resultList[0] && resultList[1]){
      return true;
    }
    else{
      return false;
    }
  }

  Future<bool> _deleteRejectedQuotes() async{
    bool result;
    await Firestore.instance.collection('requests')
      .document(_consumerLocation['country'])
      .collection(_consumerLocation['state'])
      .document(_consumerLocation['city'])
      .collection('request_info')
      .document(_reqId)
      .collection('quotes')
      .getDocuments()
      .then((docsSnap){
        docsSnap.documents.removeWhere((docSnap){
          return (docSnap.documentID != _mechId);
        });        
      })
      .whenComplete((){
        result = true;
      })
      .catchError((e){
        result = false;
        print('Cant delete Quotes @ QuoteDetailBackend > deleteRejectedQuotes()');
        print(e);
      });
    return result;
  }

  Future<bool> _changeReqStatusToClosed() async{
    bool result;
    await Firestore.instance.collection('requests')
      .document(_consumerLocation['country'])
      .collection(_consumerLocation['state'])
      .document(_consumerLocation['city'])
      .collection('request_info')
      .document(_reqId)
      .updateData({'status': 'close'})
      .whenComplete((){
        result = true;
      })
      .catchError((e){
        result = false;
        print('Cant change request status @ QuoteDetailBackend > changeReqStatusToClosed()');
        print(e);
      });
    return result;
  }

  Future<bool> _moveReqToMechArchived() async{
    bool delRes;
    bool insertRes;
    delRes = await _deleteReqIdFromMechQuoted();
    insertRes = await _addReqIdToMechAccepted();
    if(delRes && insertRes){
      return true;
    }
    else{
      return false;
    }
  }

  Future<bool> _deleteReqIdFromMechQuoted() async{
    bool result;
    await Firestore.instance.collection('provider_accounts')
      .document(_mechId)
      .collection('quoted_requests')
      .document(_reqId)
      .delete()
      .whenComplete((){
        result = true;
      })
      .catchError((e){
        print('cant delete req id @ QuoteDetailBackend > deleteReqIdFromMechQuoted()');
        result = false;
        print(e);
      }); 
    return result;
  }

  Future<bool> _addReqIdToMechAccepted() async{
    bool result;
    await Firestore.instance.collection('provider_accounts')
      .document(_mechId)
      .collection('accepted_requests')
      .document(_reqId)
      .setData({'id': _reqId})
      .whenComplete((){
        result = true;
      })
      .catchError((e){
        print('cant add req id @ QuoteDetailBackend > addReqIdToMechAccepted()');
        result = false;
        print(e);
      }); 
    return result;
  }
}
