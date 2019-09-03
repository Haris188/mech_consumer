// classes and functions for authentication

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authenticator{
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  Future<FirebaseUser> signInWithGoogle() async{
    try {
      final GoogleSignInAccount account = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
        await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken
      );
      final AuthResult authResult =  await _firebaseAuth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await _firebaseAuth.currentUser();
      print('Login Successful @ Authenticator > signInWithGoogle');
      return currentUser;    
    } 
    catch (e) {
        print("error @ Authenticator > signInWithGoogle");
        print(e.toString());
        return null;
    }
  }
}