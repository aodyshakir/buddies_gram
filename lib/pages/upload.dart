

import 'dart:io';

import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/home.dart';
import 'package:buddiesgram/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;


class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  File file; //for camera and gallery
  bool isUploading = false;
  TextEditingController textPost = TextEditingController();
  TextEditingController textGeolocator = TextEditingController();
  String postId = Uuid().v4();
  handleCamera() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  handleGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressImageFile;
    });
  }

  uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  chooseImage(parentContext) {
    return showDialog(
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with camera"),
                onPressed: () {
                  handleCamera();
                },
              ),
              SimpleDialogOption(
                child: Text("Photo from Gallery"),
                onPressed: () {
                  handleGallery();
                },
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
        context: parentContext);
  }

  createPostFirestore({String mediaUrl, String location, String description}) {
    postsRef
        .document(widget.currentUser.id)
        .collection("usersPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    });
  }

  buildSplashScreen() {
    return Container(
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/images/upload.svg",
              height: 260.0,
            ),
            Padding(padding: EdgeInsets.only(top: 20.0)),
            RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                color: Colors.orange,
                child: Text(
                  "Upload Image",
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                onPressed: () {
                  chooseImage(context);
                })
          ],
        ));
  }

  handelSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostFirestore(
        mediaUrl: mediaUrl,
        location: textGeolocator.text,
        description: textPost.text);
    textGeolocator.clear();
    textPost.clear();
    setState(() {
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  buildForm() {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              handelSubmit();
            },
            child: Text(
              "Post",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          )
        ],
        title: Text(
          "UploadPost",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Center(
                  child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  )),
                ),
              ))),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.currentUser.photoUrl),
              ),
              title: TextField(
                controller: textPost,
                decoration: InputDecoration(
                    hintText: "Write here post", border: InputBorder.none),
              )),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
              leading: Icon(Icons.pin_drop, color: Colors.orange, size: 35.0),
              title: TextField(
                controller: textGeolocator,
                decoration: InputDecoration(
                    hintText: "Where was this taken", border: InputBorder.none),
              )),
          Container(
            width: 100.0,
            padding: EdgeInsets.all(60.0),
            child: RaisedButton.icon(
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  getUserLocation();
                },
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                label: Text("Use current location",
                    style: TextStyle(color: Colors.white))),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    print("placemark is $placemark");
    String fullAddress = "${placemark.locality}" + "," + "${placemark.country}";
    print("fullAddress is $fullAddress");
    textGeolocator.text = fullAddress;
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildForm();
  }
}
