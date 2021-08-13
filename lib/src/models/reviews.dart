import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/users.dart';

class Reviews {
  final String reviewId;
  final String username;
  final String userId;
  final String userPhotoUrl;
  final Users user;
  final String postId;
  final double rating;
  final String review;
  final Timestamp timestamp;

  Reviews({
    required this.reviewId,
    required this.username,
    required this.userId,
    required this.userPhotoUrl,
    required this.user,
    required this.postId,
    required this.rating,
    required this.review,
    required this.timestamp,
  });

  // factory Reviews.fromDocument(QueryDocumentSnapshot doc) {
  //   return Reviews(
  //       reviewId: doc['reviewId'],
  //       userId: doc['userId'],
  //       postId: doc['postId'],
  //       rating: double.parse(doc['rating'].toString()),
  //       review: doc['review'],
  //       timestamp: doc['timestamp']);
  // }
}
