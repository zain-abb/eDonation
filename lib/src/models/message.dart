import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  Text,
  Image,
}

class Message {
  final String message;
  final String senderID;
  final MessageType type;
  final Timestamp timestamp;

  Message({
    required this.message,
    required this.senderID,
    required this.type,
    required this.timestamp,
  });
}
