import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String senderID;
  final String userId;
  final String image;
  final String lastMessage;
  final String name;
  final Timestamp timestamp;
  final String type;
  final int unseenCount;

  Chat({
    required this.chatId,
    required this.senderID,
    required this.userId,
    required this.image,
    required this.lastMessage,
    required this.name,
    required this.timestamp,
    required this.type,
    required this.unseenCount,
  });

  factory Chat.fromDocument(DocumentSnapshot doc) {
    return Chat(
      chatId: doc['chatId'],
      senderID: doc['senderID'],
      userId: doc['userId'],
      image: doc['image'],
      lastMessage: doc['lastMessage'],
      name: doc['name'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      unseenCount: int.parse(doc['unseenCount'].toString()),
    );
  }
}
