import 'package:flutter/material.dart';
import "package:cached_network_image/cached_network_image.dart";

cachedNetworkImage(mediaUrl, BoxFit cover) {
  return CachedNetworkImage(
    imageUrl: mediaUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      padding: EdgeInsets.all(20.0),
      child: CircularProgressIndicator(),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}
