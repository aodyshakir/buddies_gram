import 'dart:async';
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/comments.dart';
import 'package:buddiesgram/pages/home.dart';
import 'package:buddiesgram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc["postId"],
      ownerId: doc["ownerId"],
      username: doc["username"],
      location: doc["location"],
      description: doc["description"],
      mediaUrl: doc["mediaUrl"],
      likes: doc["likes"],
    );
  }

  int getLikeCounts(likes) {
    if (likes == null) {
      return 0;
    }
    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
      postId: this.postId,
      ownerId: this.ownerId,
      username: this.username,
      location: this.location,
      description: this.description,
      mediaUrl: this.mediaUrl,
      likes: this.likes,
      likeCount: getLikeCounts(this.likes));
}

class _PostState extends State<Post> {
  final String CurrentUserId = currentUser?.id;
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  Map likes;
  int likeCount;
  bool isLiked;
  bool showHeart = false;

  _PostState(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.description,
      this.mediaUrl,
      this.likes,
      this.likeCount});

  buildPostHeader() {
    return FutureBuilder<DocumentSnapshot>(
      future: usersRef.document(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: Text(user.username,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text(location),
              trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    print("delete");
                    //TODO delete
                  }),
            ),
            Container(child: Text(description == null ? "" : description))
          ],
        );
      },
    );
  }

  buildPostImage() {
    return GestureDetector(
      onTap: () {},
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  addLikeToActivityFeed() {
    feedsRef
        .document(ownerId)
        .collection("feedItems")
        .document(postId)
        .setData({
      "type": "like",
      "username": currentUser.username,
      "userId": currentUser.id,
      "userProfileImg": currentUser.photoUrl,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": timestamp,
    });
  }

  removeLikeFromActivityFeed() {
    feedsRef
        .document(ownerId)
        .collection("feedItems")
        .document(postId)
        .get()
        .then((doc) {    
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleLikePost() {
    bool _isLiked = likes[CurrentUserId] == true;
    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({'likes.$CurrentUserId': false});
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[CurrentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({'likes.$CurrentUserId': true});
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[CurrentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0, top: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Divider(),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                  child: Container(
                child: InkWell(
                    onTap: () {
                      handleLikePost();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 28.0,
                            color: Colors.pink,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text("Like")),
                        ],
                      ),
                    )),
              )),
              new Expanded(
                  child: Container(
                child: InkWell(
                    onTap: () {
                      showComment(context,
                          postId: postId, ownerId: ownerId, mediaUrl: mediaUrl);
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.comment,
                          size: 28.0,
                          color: Colors.black,
                        ),
                        new Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Comment"),
                        )
                      ],
                    )),
              )),
              new Expanded(
                  child: Container(
                child: InkWell(
                    onTap: () {
                      print("share");
                      //TODO share
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.share,
                          size: 28.0,
                          color: Colors.black,
                        ),
                        new Padding(
                          padding: EdgeInsets.only(left: 5.0),
                          child: Text("Share"),
                        )
                      ],
                    )),
              )),
            ],
          ),
        )
      ],
    );
  }

  showComment(context, {String postId, String ownerId, String mediaUrl}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Comments(
            postId: postId,
            ownerId: ownerId,
            mediaUrl: mediaUrl,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    isLiked = likes[CurrentUserId] == true;
    return Container(
      child: Column(
        children: <Widget>[
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ),
    );
  }
}
