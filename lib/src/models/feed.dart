import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  Feed(
      {required this.activityType,
      required this.description,
      required this.id,
      required this.number,
      required this.postId,
      required this.postMediaUrl,
      required this.timestamp,
      required this.userId,
      required this.userImageUrl,
      required this.username});

  final String activityType;
  final String description;
  final String id;
  final double number;
  final String postId;
  final String postMediaUrl;
  final Timestamp timestamp;
  final String userId;
  final String userImageUrl;
  final String username;

  factory Feed.fromDocument(DocumentSnapshot doc) {
    return Feed(
        activityType: doc['activityType'],
        description: doc['description'],
        id: doc['id'],
        number: double.parse(doc['number'].toString()),
        postId: doc['postId'],
        postMediaUrl: doc['postMediaUrl'],
        timestamp: doc['timestamp'],
        userId: doc['userId'],
        userImageUrl: doc['userImageUrl'],
        username: doc['username']);
  }
}
