

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BackendMethods{

  static String _currentUid;

  Future<Map<String,dynamic>> getConsumerLocation() async{
    String currentUid = await getCurrentUid();
    Map<String, dynamic> location;
    await Firestore.instance.collection('consumer_accounts')
      .document(currentUid).collection('locations')
      .getDocuments()
      .then((docs){
        location = docs.documents.first.data;
      });
      return location;
  }

  Future<String> getCurrentUid()async{

    await FirebaseAuth.instance.currentUser().then((user){
      _currentUid = user.uid;
    })
    .catchError((onError){
      print('cant fetch id @ BackendMethods > getCurrentUid');
      print(onError.toString());
    });

    return _currentUid;
  }
}