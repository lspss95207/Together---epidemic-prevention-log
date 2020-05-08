// import 'dart:async';
// import 'dart:convert' show json;

// import 'package:flutter/material.dart';

// import "package:http/http.dart" as http;
// import 'package:google_sign_in/google_sign_in.dart';

// import 'globals.dart' as globals;

// import 'package:virus_tracker/locationPage/locationList.dart';
// import 'package:virus_tracker/thsrPage/thsrList.dart';
// import 'package:virus_tracker/trPage/trList.dart';
// import 'package:virus_tracker/metroPage/taipeiMetro/taipeiMetroList.dart';
// import 'package:virus_tracker/busPage/busList.dart';

// class SignIn extends StatefulWidget {
//   @override
//   State createState() => SignInState();
// }

// class SignInState extends State<SignIn> {
//   String _contactText;
//   int _currentIndex = 0;
//   final pages = [LocationList(), THSRList(), TRList(), TaipeiMetroList(), BusList()];

//   SignInState() {
//     Timer.periodic(Duration(seconds: 1800), (timer) {
//       globals.googleSignIn.onCurrentUserChanged
//           .listen((GoogleSignInAccount account) {
//         setState(() {
//           globals.currentUser = account;
//         });
//       });
//       globals.updateIDToken();
//       print('reconnect');
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     globals.googleSignIn.onCurrentUserChanged
//         .listen((GoogleSignInAccount account) {
//       setState(() {
//         globals.currentUser = account;
//       });
//       if (globals.currentUser != null) {
//         // _handleGetContact();
//         globals.updateIDToken();
//       }
//     });
//     globals.googleSignIn.signInSilently().then((result) {
//       result.authentication.then((googlekey) {
//         globals.id_token = googlekey.idToken;
//       });
//     });
//   }

//   //UI
//   @override
//   Widget build(BuildContext context) {
//     if (globals.currentUser != null) {
//       return _mainPage();
//     } else {
//       return _loginPage();
//     }
//   }

//   Widget _loginPage() {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Virus Tracker'),
//       ),
//       body: Container(
//         color: Colors.white,
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               FlutterLogo(size: 150),
//               SizedBox(height: 50),
//               _signInButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _mainPage() {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Virus Tracker'),
//       ),
//       drawer: Drawer(
//           child: ListView(
//         children: <Widget>[
//           UserAccountsDrawerHeader(
//             currentAccountPicture: GoogleUserCircleAvatar(
//               identity: globals.currentUser,
//             ),
//             accountName: Text(globals.currentUser.displayName ?? ''),
//             accountEmail: Text(globals.currentUser.email ?? ''),
//           ),
//           RaisedButton(
//             child: const Text('SIGN OUT'),
//             onPressed: _handleSignOut,
//           ),
//           ListTile(
//             leading: Icon(Icons.location_on),
//             title: Text('Locations'),
//             onTap: () {
//               _onItemClick(0);
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.directions_railway),
//             title: Text('Taiwan High Speed Rail'),
//             onTap: () {
//               _onItemClick(1);
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.train),
//             title: Text('Taiwan Railways'),
//             onTap: () {
//               _onItemClick(2);
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.train),
//             title: Text('Taipei Metro'),
//             onTap: () {
//               _onItemClick(3);
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.directions_bus),
//             title: Text('Bus'),
//             onTap: () {
//               _onItemClick(4);
//             },
//           ),
//         ],
//       )),
//       body: pages[_currentIndex],
//     );
//   }

//   void _onItemClick(int index) {
//     setState(() {
//       _currentIndex = index;
//       Navigator.of(context).pop();
//     });
//   }

//   Future<void> _handleSignOut() {
//     globals.googleSignIn.disconnect();
//   }

//   static Future<void> _handleSignIn() async {
//     try {
//       await globals.googleSignIn.signIn();
//     } catch (error) {
//       print(error);
//     }
//   }

//   Widget _signInButton() {
//     return OutlineButton(
//       splashColor: Colors.grey,
//       onPressed: _handleSignIn,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//       highlightElevation: 0,
//       borderSide: BorderSide(color: Colors.grey),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
//             Padding(
//               padding: const EdgeInsets.only(left: 10),
//               child: Text(
//                 'Sign in with Google',
//                 style: TextStyle(
//                   fontSize: 20,
//                   color: Colors.grey,
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Future<void> _handleGetContact() async {
// //   setState(() {
// //     _contactText = "Loading contact info...";
// //   });
// //   final http.Response response = await http.get(
// //     'https://people.googleapis.com/v1/people/me/connections'
// //     '?requestMask.includeField=person.names',
// //     headers: await _currentUser.authHeaders,
// //   );
// //   if (response.statusCode != 200) {
// //     setState(() {
// //       _contactText = "People API gave a ${response.statusCode} "
// //           "response. Check logs for details.";
// //     });
// //     print('People API ${response.statusCode} response: ${response.body}');
// //     return;
// //   }
// //   final Map<String, dynamic> data = json.decode(response.body);
// //   final String namedContact = _pickFirstNamedContact(data);
// //   setState(() {
// //     if (namedContact != null) {
// //       _contactText = "I see you know $namedContact!";
// //     } else {
// //       _contactText = "No contacts to display.";
// //     }
// //   });
// // }

// // String _pickFirstNamedContact(Map<String, dynamic> data) {
// //   final List<dynamic> connections = data['connections'];
// //   final Map<String, dynamic> contact = connections?.firstWhere(
// //     (dynamic contact) => contact['names'] != null,
// //     orElse: () => null,
// //   );
// //   if (contact != null) {
// //     final Map<String, dynamic> name = contact['names'].firstWhere(
// //       (dynamic name) => name['displayName'] != null,
// //       orElse: () => null,
// //     );
// //     if (name != null) {
// //       return name['displayName'];
// //     }
// //   }
// //   return null;
// // }

// // Column(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: <Widget>[
// //           ListTile(
// //             leading: GoogleUserCircleAvatar(
// //               identity: _currentUser,
// //             ),
// //             title: Text(_currentUser.displayName ?? ''),
// //             subtitle: Text(_currentUser.email ?? ''),
// //           ),
// //           const Text("Signed in successfully."),
// //           Text(_contactText ?? ''),
// //           RaisedButton(
// //             child: const Text('SIGN OUT'),
// //             onPressed: _handleSignOut,
// //           ),
// //           RaisedButton(
// //             child: const Text('REFRESH'),
// //             onPressed: _handleGetContact,
// //           ),
// //         ],
// //       );
