import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Timeline extends StatefulWidget {
  Timeline({Key key}) : super(key: key);

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("Timeline"),
    );
  }
}
