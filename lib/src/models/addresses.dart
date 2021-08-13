import 'package:cloud_firestore/cloud_firestore.dart';

class Addresses {
  final String addressId;
  final String title;
  final String addressLineOne;
  final String addressLineTwo;
  final String phoneNumber;
  final String city;
  final String state;
  final int zipCode;

  Addresses({
    required this.addressId,
    required this.title,
    required this.addressLineOne,
    required this.addressLineTwo,
    required this.phoneNumber,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  factory Addresses.fromDocument(DocumentSnapshot doc) {
    return Addresses(
      addressId: doc['addressId'],
      title: doc['title'],
      addressLineOne: doc['addressLineOne'],
      addressLineTwo: doc['addressLineTwo'],
      phoneNumber: doc['phoneNumber'],
      city: doc['city'],
      state: doc['state'],
      zipCode: int.parse(doc['zipCode'].toString()),
    );
  }
}
