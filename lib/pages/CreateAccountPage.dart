import 'dart:async';

import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final  _scaffoldkey = GlobalKey<ScaffoldState>();
  final  _formkey = GlobalKey<FormState>();
  String username;

  submitUsername(){
    final from = _formkey.currentState;
    if(from.validate())
    {
      from.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome " + username));
      _scaffoldkey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 4),(){
        Navigator.pop(context,username);
      });

    }
  }
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
       key: _scaffoldkey,
      appBar: header(context, strTitle: "Settings", disappeareBackButton: true),
      body:ListView(
        children: <Widget>[
          Container(
             child: Column(
               children: <Widget>[
                 Padding(
                   padding: EdgeInsets.only(top:26.0),
                   child: Center(
                     child: Text("Set up a username",style: TextStyle(fontSize:25.0),),
                   ),
                   ),
                   Padding(padding: EdgeInsets.all(17.0),
                   child: Container(
                     child: Form(
                       key: _formkey,
                       
                       autovalidate: true,
                       child: TextFormField(
                         style:TextStyle(color: Colors.white) ,

                         validator: (value) {
                           if(value.trim().length<5 || value.isEmpty){
                             return "user name is very short.";
                           }
                           else if(value.trim().length>15 || value.isEmpty){
                             return "user name is very long.";
                           }
                           else{
                             return null;
                           }
                         },
                         onSaved: (newValue) => username = newValue,
                         decoration: InputDecoration(
                           enabledBorder: UnderlineInputBorder(
                             borderSide: BorderSide(color: Colors.grey),

                           ),
                           focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                           ),
                           labelText: "username",
                           labelStyle: TextStyle(fontSize: 16.0),
                           hintText: "must be allest 5 characters",
                           hintStyle: TextStyle(color: Colors.grey),
                         ),

                       ),
                        
                     ),
                   ),
                   ), 
                   GestureDetector(
                     onTap: submitUsername,
                     child: Container(
                       height: 55.0,
                       width:360.0 ,
                       decoration: BoxDecoration(
                         color:Colors.green,
                         borderRadius: BorderRadius.circular(8.0),
                       ),
                       child: Center(
                         child: Text(
                           "Proceed",
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 16.0,
                             fontWeight: FontWeight.bold,


                           ),
                         ),
                       ),
                     ),
                   )
               ],
             ),
          ),
        ],
      )
    );
  }
}
