// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';

// import 'package:virus_tracker/globals.dart' as globals;

// class FeedbackPage extends StatefulWidget {
//   @override
//   State createState() => FeedbackPageState();
// }

// class FeedbackPageState extends State<FeedbackPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   String feedback;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('意見回覆'),
//       ),
//       key: _scaffoldKey,
//       body: SafeArea(
//         top: false,
//         bottom: false,
//         child: SingleChildScrollView(
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 20.0),
//             child: _build_form(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _build_form() {
//     return Form(
//       key: _formKey,
//       autovalidate: true,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           Container(
//               height: 300,
//               margin: EdgeInsets.all(10.0),
//               child: TextFormField(
//                 decoration: const InputDecoration(
//                   hintText: '請輸入您寶貴的回饋或是意見',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.multiline,
//                 maxLines: 1000,
//                 onSaved: (val) => feedback = val,
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return '請輸入您寶貴的回饋或是意見';
//                   } else {
//                     return null;
//                   }
//                 },
//               )),
//           Container(
//             margin: EdgeInsets.all(10),
//             child: SizedBox(
//               width: double.infinity,
//               child: RaisedButton(
//                 child: const Text('傳送'),
//                 onPressed: send,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> send() async {
//     if (_formKey.currentState.validate()) {
//       _formKey.currentState.save();
//       Email email = Email(
//         body: feedback,
//         subject: '意見回覆',
//         recipients: ['2020fightepidemic@gmail.com'],
//         isHTML: false,
//       );
//       String platformResponse;
//       try {
//         await FlutterEmailSender.send(email);
//         platformResponse = '傳送成功';
//         Navigator.pop(context);
//       } catch (error) {
//         platformResponse = error.toString();
//       }
//       _scaffoldKey.currentState.showSnackBar(SnackBar(
//         content: Text(platformResponse),
//       ));
//     }
//   }

//   void showMessage(String message, [MaterialColor color = Colors.red]) {
//     _scaffoldKey.currentState.showSnackBar(SnackBar(
//         backgroundColor: color,
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         )));
//   }
// }
