
import 'package:cloud_firestore/cloud_firestore.dart';

import 'backend-methods.dart';

class QuoteListBackend{
  final String _requestId;
  static Map<String,dynamic> _location;
  final List<Map<String,dynamic>> _quoteList = [];

  QuoteListBackend(this._requestId);

  Future<List<Map<String,dynamic>>> getQuoteListFromDb()async{
    await _getConsumerLocation();
    await _queryQuoteList();
    return _quoteList;
  }

  Future<void> _getConsumerLocation() async{
    _location = await BackendMethods().getConsumerLocation();
  }

  Future<void> _queryQuoteList() async{
    await Firestore.instance.collection('requests')
      .document(_location['country'])
      .collection(_location['state'])
      .document(_location['city'])
      .collection('request_info')
      .document(_requestId)
      .collection('quotes')
      .getDocuments()
      .then((docsSnap){
        if(docsSnap.documents.length < 1){
          _quoteList.add({'result': false});
        }
        else{
          docsSnap.documents.forEach((doc){
          _quoteList.add(doc.data);
          print(_quoteList);
          });
        }
      })
      .timeout(Duration(seconds: 5), onTimeout: (){
        _quoteList.add({'result': 'timeout'});
      })
      .catchError((e){
        print('cant get quote @ QuoteListingScreen > getQuoteList()');
        print(e);
      });
  }
}