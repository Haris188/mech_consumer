import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../authentication.dart';

class ProfileMakeupBackend{

  final FirebaseUser _user;
  static bool _carResult;
  static bool _locationResult;

  ProfileMakeupBackend(this._user);

  Future<bool> submitCarDataToDb(List cars) async{

    bool result;
    for(var index = 0; index < cars.length; index++){
      try {
        await Firestore.instance.collection('consumer_accounts')
          .document(_user.uid).collection('vehicles')
          .add(cars[index]).whenComplete((){
            result = true;
            //_carResult = true;
            //_returnCarResult();
            print('success : car sumbit');
          }).catchError((onError){
            result = false;
            // _carResult = false;
            // _returnCarResult();
            print('fail server');
          });
        } 
        catch (e) {
          print("Cant upload car data @ ProfileMakeupBackend > submitCarDataToDb()");
          print(e.toString());
          result = false;
          // _carResult =false;
          // _returnCarResult();
        }
    }
    return result;
  }

  bool _returnCarResult(){
    return _carResult;
  }

  Future<bool> submitLocationToDb(Map<String, dynamic> location) async{

    bool result;

    try {
      await Firestore.instance.collection('consumer_accounts')
        .document(_user.uid).collection('locations')
        .add(location).whenComplete((){
          result = true;
          print('success: Location');
        }).catchError((onError){
          result = false;
          print('fail server side fail');
          print(onError.toString());
        });
    } 
    catch (e) {
      print('Location cant upload @ ProfileMakeupBackend > submitLocationToDb()');
      print(e.toString());
      result = false;
    }
    return result;
  }

  Future<FirebaseUser> _getFirebaseUser() async{
    FirebaseUser user = await Authenticator().signInWithGoogle();
    return user;
  }
}