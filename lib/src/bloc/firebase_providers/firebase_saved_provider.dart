import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/views/ui/home/pager.dart';

class FirebaseSavedProvider {
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await savedPostsRef
            .doc(userCurrent!.id)
            .collection('saved')
            .limit(10)
            .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await savedPostsRef
            .doc(userCurrent!.id)
            .collection('saved')
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(10)
            .get())
        .docs;
  }
}
