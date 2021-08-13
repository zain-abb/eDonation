import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';

class FirebaseUserProvider {
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await usersRef
            .orderBy("username", descending: false)
            .limit(10)
            .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await usersRef
            .orderBy("username", descending: false)
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(10)
            .get())
        .docs;
  }
}
