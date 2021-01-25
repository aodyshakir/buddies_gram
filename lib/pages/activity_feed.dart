import 'package:buddiesgram/pages/home.dart';
import 'package:buddiesgram/pages/post_screen.dart';
import 'package:buddiesgram/pages/profile.dart';
import 'package:buddiesgram/widgets/header.dart';
import 'package:buddiesgram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getFeedData() async {
    QuerySnapshot snapshot = await feedsRef
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(50)
        .getDocuments();

    List<ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocoment(doc));
    });
    return feedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: header(context, titleText: "activityFeeds"),
        body: FutureBuilder(
            future: getFeedData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return circularProgress();
              }
              return ListView(
                children: snapshot.data,
              );
            }));
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocoment(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc["username"],
      userId: doc["userId"],
      commentData: doc["commentData"],
      mediaUrl: doc["mediaUrl"],
      postId: doc["postId"],
      userProfileImg: doc["userProfileImg"],
      timestamp: doc["timestamp"],
      type: doc["type"],
    );
  }
  String activityFeedItem;
  Widget mediaPreview;

  configurMediaPreviw(context) {
    if (type == "like" || type == "comments") {
      mediaPreview = GestureDetector(
        onTap: () {
          showProfile(context, profileId: userId);
        },
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: CachedNetworkImageProvider(mediaUrl),
                      fit: BoxFit.cover)),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == "like") {
      activityFeedItem = "liked your post";
    } else if (type == "follow") {
      activityFeedItem = "is flollow you";
    } else if (type == "comments") {
      activityFeedItem = "replied: $commentData";
    } else {
      activityFeedItem = "Error:$type";
    }
  }

  showPost(context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return PostScreen(postId: postId, userId: userId);
    }));
  }

  @override
  Widget build(BuildContext context) {
    configurMediaPreviw(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        child: ListTile(
          title: GestureDetector(
            onTap: () {
              showPost(context);
            },
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(
                      text: username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' $activityFeedItem',
                    )
                  ]),
            ),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            backgroundImage:CachedNetworkImageProvider(userProfileImg),
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }
}

showProfile(context, {profileId}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Profile(
      profileId: profileId,
    );
  }));
}
