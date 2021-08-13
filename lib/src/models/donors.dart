import 'package:cloud_firestore/cloud_firestore.dart';

class Donors {
  final String donorId;
  final String username;
  final String userId;
  final String userPhotoUrl;
  final String postId;
  final double donation;
  final String description;
  final Timestamp timestamp;
  final String status;

  Donors({
    required this.donorId,
    required this.username,
    required this.userId,
    required this.userPhotoUrl,
    required this.postId,
    required this.donation,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  // factory Donors.fromDocument(QueryDocumentSnapshot doc) {
  //   return Donors(
  //       donorId: doc['donorId'],
  //       userId: doc['userId'],
  //       postId: doc['postId'],
  //       donation: double.parse(doc['donation'].toString()),
  //       timestamp: doc['timestamp']);
  // }
}
