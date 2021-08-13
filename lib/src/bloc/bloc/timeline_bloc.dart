import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/bloc/firebase_providers/firebase_timeline_provider.dart';
import 'package:rxdart/rxdart.dart';

class TimelineListBloc {
  late FirebaseTimelineProvider firebaseTimelineProvider;

  bool showIndicator = false;
  bool endList = false;
  List<DocumentSnapshot>? documentList;

  late BehaviorSubject<List<DocumentSnapshot>> timelineController;

  late BehaviorSubject<bool> showIndicatorController;

  TimelineListBloc() {
    timelineController = BehaviorSubject<List<DocumentSnapshot>>();
    showIndicatorController = BehaviorSubject<bool>();
    firebaseTimelineProvider = FirebaseTimelineProvider();
  }

  bool get listEnd => endList;

  Stream get getShowIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get timelineStream =>
      timelineController.stream;

/*This method will automatically fetch first 10 elements from the document list */
  Future fetchFirstList() async {
    try {
      documentList = await firebaseTimelineProvider.fetchFirstList();
      timelineController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          timelineController.sink.addError("No Data Available");
        }
      } catch (e) {}
    } on SocketException {
      timelineController.sink
          .addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      timelineController.sink.addError(e);
    }
  }

/*This will automatically fetch the next 10 elements from the list*/
  Future fetchNextTimeline() async {
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList =
          await firebaseTimelineProvider.fetchNextList(documentList!);
      documentList!.addAll(newDocumentList);
      timelineController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          timelineController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      } catch (e) {
        updateIndicator(false);
      }
    } on SocketException {
      timelineController.sink
          .addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    } catch (e) {
      updateIndicator(false);
      print(e.toString());
      timelineController.sink.addError(e);
    }
  }

/*For updating the indicator below every list and paginate*/
  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    timelineController.close();
    showIndicatorController.close();
  }
}
