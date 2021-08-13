import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/views/ui/home/pager.dart';

class FirebaseTimelineProvider {
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await timelineRef
            .doc(userCurrent!.id)
            .collection('timelinePosts')
            .orderBy("timestamp", descending: true)
            .limit(10)
            .get())
        .docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(
      List<DocumentSnapshot> documentList) async {
    return (await timelineRef
            .doc(userCurrent!.id)
            .collection('timelinePosts')
            .orderBy("timestamp", descending: true)
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(10)
            .get())
        .docs;
  }
}
