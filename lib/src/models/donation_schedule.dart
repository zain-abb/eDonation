import 'package:cloud_firestore/cloud_firestore.dart';

class DonationSchedule {
  final String addresId;
  final String donorId;
  final String postId;
  final String scheduleDate;
  final String scheduleTime;
  final String scheduleType;
  final String userId;
  final String status;

  DonationSchedule(
      {required this.addresId,
      required this.donorId,
      required this.postId,
      required this.scheduleDate,
      required this.scheduleTime,
      required this.scheduleType,
      required this.userId,
      required this.status});

  factory DonationSchedule.fromDocumnet(DocumentSnapshot doc) {
    return DonationSchedule(
        addresId: doc['addressId'],
        donorId: doc['donorId'],
        postId: doc['postId'],
        scheduleDate: doc['scheduleDate'],
        scheduleTime: doc['scheduleTime'],
        scheduleType: doc['scheduleType'],
        userId: doc['userId'],
        status: doc['status']);
  }
}
