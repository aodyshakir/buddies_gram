import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'package:buddiesgram/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';

class TimeLinePage extends StatefulWidget {

  final User gCurrentUser;

  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}


class _TimeLinePageState extends State<TimeLinePage> {

  List<PostWidget> posts;
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeLine() async{
    QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id).collection("timelinePosts").orderBy("timestamp",descending: true).getDocuments();

    List<PostWidget> allPosts = querySnapshot.documents.map((document) => PostWidget.fromDocument(document)).toList();

    setState(() {
      this.posts=allPosts;
    });
  }

  retrieveFollowings() async{
    QuerySnapshot querySnapshot = await timelineReference.document(widget.gCurrentUser.id).collection("userFollowing").getDocuments();

    setState(() {
      followingsList = querySnapshot.documents.map((document) => document.documentID).toList();
    });
  }

  createUserTimeLine(){
    if(posts==null){
      return circularProgress();
    }
    else{
      return ListView(children: posts,);
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveTimeLine();
    retrieveFollowings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle : true,),
      body: RefreshIndicator(child: createUserTimeLine(), onRefresh: () => retrieveTimeLine(),),
    );
  }
}
