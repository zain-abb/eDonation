import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/bloc/firebase_providers/firebase_saved_provider.dart';
import 'package:rxdart/rxdart.dart';

class SavedBloc {
  late FirebaseSavedProvider firebaseSavedProvider;

  bool showIndicator = false;
  bool endList = false;
  List<DocumentSnapshot>? documentList;

  late BehaviorSubject<List<DocumentSnapshot>> savedController;

  late BehaviorSubject<bool> showIndicatorController;

  SavedBloc() {
    savedController = BehaviorSubject<List<DocumentSnapshot>>();
    showIndicatorController = BehaviorSubject<bool>();
    firebaseSavedProvider = FirebaseSavedProvider();
  }

  bool get listEnd => endList;

  Stream get getShowIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get savedStream => savedController.stream;

/*This method will automatically fetch first 10 elements from the document list */
  Future fetchFirstList() async {
    try {
      documentList = await firebaseSavedProvider.fetchFirstList();
      savedController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          savedController.sink.addError("No Data Available");
        }
      } catch (e) {}
    } on SocketException {
      savedController.sink.addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      savedController.sink.addError(e);
    }
  }

/*This will automatically fetch the next 10 elements from the list*/
  Future fetchNextTimeline() async {
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList =
          await firebaseSavedProvider.fetchNextList(documentList!);
      documentList!.addAll(newDocumentList);
      savedController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          savedController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      } catch (e) {
        updateIndicator(false);
      }
    } on SocketException {
      savedController.sink.addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    } catch (e) {
      updateIndicator(false);
      print(e.toString());
      savedController.sink.addError(e);
    }
  }

/*For updating the indicator below every list and paginate*/
  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    savedController.close();
    showIndicatorController.close();
  }
}
