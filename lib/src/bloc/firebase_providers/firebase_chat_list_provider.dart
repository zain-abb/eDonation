import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/views/ui/home/pager.dart';

class FirebaseChatListProvider {
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await chatsRef
            .doc(userCurrent!.id)
            .collection('chat')
            .orderBy("timestamp", descending: true)
            .limit(20)
            .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await chatsRef
            .doc(userCurrent!.id)
            .collection('chat')
            .orderBy("timestamp", descending: true)
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(20)
            .get())
        .docs;
  }
}
