import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String id;
  final String username;
  final String email;
  final String cnic;
  final String bio;
  final String phone;
  final String dob;
  final String gender;
  final GeoPoint loc;
  final String photoUrl;
  final Timestamp timestamp;
  final bool presence;
  final int lastSeenEpochs;

  Users(
      {required this.id,
      required this.username,
      required this.email,
      required this.cnic,
      required this.bio,
      required this.phone,
      required this.gender,
      required this.dob,
      required this.loc,
      required this.photoUrl,
      required this.timestamp,
      required this.presence,
      required this.lastSeenEpochs});

  factory Users.fromDocument(DocumentSnapshot doc) {
    return Users(
        id: doc['id'],
        username: doc['username'],
        email: doc['email'],
        cnic: doc['cnic'],
        bio: doc['bio'],
        phone: doc['phone'],
        gender: doc['gender'],
        dob: doc['dob'],
        loc: doc['loc'],
        photoUrl: doc['image_url'],
        timestamp: doc['timestamp'],
        presence: doc['presence'],
        lastSeenEpochs: int.parse(doc['lastSeen'].toString()));
  }
}
