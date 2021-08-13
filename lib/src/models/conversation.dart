import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/message.dart';

class Conversation {
  final String chatID;
  final List<String> members;
  final List<Message> messages;
  final String ownerID;

  Conversation({
    required this.chatID,
    required this.members,
    required this.messages,
    required this.ownerID,
  });

  factory Conversation.fromDocument(DocumentSnapshot doc) {
    List<dynamic> messages = doc['messages'];
    List<Message> allMessages = [];
    if (doc['messages'].isNotEmpty)
      allMessages = messages.map((snapshot) {
        return Message(
            message: snapshot['message'],
            senderID: snapshot['senderID'],
            type: snapshot['type'] == 'text'
                ? MessageType.Text
                : MessageType.Image,
            timestamp: snapshot['timestamp']);
      }).toList();
    return Conversation(
        chatID: doc.id,
        members: [...doc['members']],
        messages: allMessages,
        ownerID: doc['ownerID']);
  }
}
