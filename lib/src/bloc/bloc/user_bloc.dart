import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/bloc/firebase_providers/firebase_user_provider.dart';
import 'package:rxdart/rxdart.dart';

class UserBloc {
  late FirebaseUserProvider firebaseUserProvider;

  bool showIndicator = false;
  bool endList = false;
  List<DocumentSnapshot>? documentList;

  late BehaviorSubject<List<DocumentSnapshot>> userController;

  late BehaviorSubject<bool> showIndicatorController;

  UserBloc() {
    userController = BehaviorSubject<List<DocumentSnapshot>>();
    showIndicatorController = BehaviorSubject<bool>();
    firebaseUserProvider = FirebaseUserProvider();
  }

  bool get listEnd => endList;

  Stream get getShowIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get usersStream => userController.stream;

/*This method will automatically fetch first 10 elements from the document list */
  Future fetchFirstList() async {
    try {
      documentList = await firebaseUserProvider.fetchFirstList();
      userController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          userController.sink.addError("No Data Available");
        }
      } catch (e) {}
    } on SocketException {
      userController.sink.addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      userController.sink.addError(e);
    }
  }

/*This will automatically fetch the next 10 elements from the list*/
  Future fetchNextUsers() async {
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList =
          await firebaseUserProvider.fetchNextList(documentList!);
      documentList!.addAll(newDocumentList);
      userController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          userController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      } catch (e) {
        updateIndicator(false);
      }
    } on SocketException {
      userController.sink.addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    } catch (e) {
      updateIndicator(false);
      print(e.toString());
      userController.sink.addError(e);
    }
  }

/*For updating the indicator below every list and paginate*/
  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    userController.close();
    showIndicatorController.close();
  }
}
