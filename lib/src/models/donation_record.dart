import 'package:cloud_firestore/cloud_firestore.dart';

class DonationRecord {
  DonationRecord(
      {required this.addresId,
      required this.donorId,
      required this.postId,
      required this.scheduleDate,
      required this.scheduleTime,
      required this.scheduleType,
      required this.postUserId,
      required this.status,
      required this.campaignTitle,
      required this.timestamp,
      required this.description,
      required this.donation});

  final String postId;
  final String postUserId;
  final String donorId;
  final String campaignTitle;
  final Timestamp timestamp;
  final String description;
  final double donation;
  final String status;
  final String addresId;
  final String scheduleType;
  final String scheduleTime;
  final String scheduleDate;

  factory DonationRecord.fromDocumnet(DocumentSnapshot doc) {
    return DonationRecord(
      postId: doc['postId'],
      postUserId: doc['postUserId'],
      donorId: doc['donorId'],
      campaignTitle: doc['campaignTitle'],
      timestamp: doc['timestamp'],
      description: doc['description'],
      donation: double.parse(doc['donation'].toString()),
      status: doc['status'],
      addresId: doc['addressId'],
      scheduleType: doc['scheduleType'],
      scheduleTime: doc['scheduleTime'],
      scheduleDate: doc['scheduleDate'],
    );
  }
}
