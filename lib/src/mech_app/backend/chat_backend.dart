import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'backend-methods.dart';

class ChatBackend{
  final String _requestId;
  final String _mechId;
  static Stream<QuerySnapshot> _chatStream;
  static Map<String, dynamic> _location;

  ChatBackend(this._mechId, this._requestId);

  Future<Stream<QuerySnapshot>> getChatStream() async{
    await _getUserLocation();
    _getChatStreamSnapshot();
    print("chatSteam: ${_chatStream == null}");
    return _chatStream;
  }

  Future<void> _getUserLocation() async{
    _location = await BackendMethods().getConsumerLocation();
  }

  Future<void> _getChatStreamSnapshot() async{
    _chatStream = Firestore.instance.collection('requests')
      .document(_location['country'])
      .collection(_location['state'])
      .document(_location['city'])
      .collection('request_info')
      .document(_requestId)
      .collection('quotes')
      .document(_mechId)
      .collection('chat')
      .snapshots();
  }

  Future<bool> uploadMsg(String msg) async{
    bool result;
    await Firestore.instance.collection('requests')
      .document(_location['country'])
      .collection(_location['state'])
      .document(_location['city'])
      .collection('request_info')
      .document(_requestId)
      .collection('quotes')
      .document(_mechId)
      .collection('chat')
      .add({
        'name': await _getUserName(),
        'text': msg,
        'timestamp': Timestamp.now().microsecondsSinceEpoch.toString()
      })
      .whenComplete((){
        result = true;
      })
      .catchError((e){
        result = false;
        print('Cant upload Msg @ ChatBackend > uploadMsg()');
        print(e);
      });
    return result;
  }

  Future<String> _getUserName() async{
    String name;
    await FirebaseAuth.instance.currentUser()
      .then((user){
        name = user.displayName;
      });
    return name;
  }
}