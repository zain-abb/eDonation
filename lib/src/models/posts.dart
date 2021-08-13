import 'package:cloud_firestore/cloud_firestore.dart';

class Posts {
  final String campaignDescription;
  final String campaignReq;
  final String campaignTitle;
  final String duration;
  final String issueType;
  final GeoPoint location;
  final String postId;
  final String postType;
  final double raised;
  final String imageUrl;
  final double target;
  final Timestamp timestamp;
  final String userId;
  final String username;
  final String userPhotoUrl;
  final GeoPoint userLocation;

  Posts({
    required this.campaignDescription,
    required this.campaignReq,
    required this.campaignTitle,
    required this.duration,
    required this.issueType,
    required this.location,
    required this.postId,
    required this.postType,
    required this.raised,
    required this.imageUrl,
    required this.target,
    required this.timestamp,
    required this.userId,
    required this.username,
    required this.userPhotoUrl,
    required this.userLocation,
  });

  factory Posts.fromDocument(DocumentSnapshot doc) {
    return Posts(
      campaignDescription: doc['campaignDescription'],
      campaignReq: doc['campaignReq'],
      campaignTitle: doc['campaignTitle'],
      duration: doc['duration'],
      issueType: doc['issueType'],
      location: doc['location'],
      postId: doc['postId'],
      postType: doc['postType'],
      raised: double.parse(doc['raised'].toString()),
      imageUrl: doc['imageUrl'],
      target: double.parse(doc['target'].toString()),
      timestamp: doc['timestamp'],
      userId: doc['userId'],
      username: doc['username'],
      userPhotoUrl: doc['userPhotoUrl'],
      userLocation: doc['userLocation'],
    );
  }
}
