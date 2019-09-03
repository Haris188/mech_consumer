
import 'package:flutter/material.dart';
import 'src/mech_app/screens/profile_makeup_screen.dart';
import 'src/authentication.dart';
import 'src/mech_app/screens/main_screen.dart';
import 'material_app.dart';

// void main(List<String> args) {
//   runApp(
//     Tryst().getMaterialApp()
//   );
// }

// main(List<String> args) async{
//   runApp(
//     MaterialApp(
//       home: ProfileMakeupScreen(await Authenticator().signInWithGoogle()),
//     )
//   );
// }

main(List<String> args) {
  runApp(
    MaterialApp(
      theme: ThemeData(accentColor: Colors.blue.shade700),
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    )
  );
}
