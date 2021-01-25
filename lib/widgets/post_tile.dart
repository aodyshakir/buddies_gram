import 'package:buddiesgram/widgets/posts.dart';
import 'package:flutter/material.dart';

import 'custom_image.dart';

class PostTile extends StatefulWidget {
  final Post post;
  PostTile({this.post});

  @override
  _PostTileState createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: cachedNetworkImage(widget.post.mediaUrl,BoxFit.cover),
    );
  }
}
