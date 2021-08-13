import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/bloc/firebase_providers/firebase_chat_list_provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatListBloc {
  late FirebaseChatListProvider firebaseChatListProvider;

  bool showIndicator = false;
  bool endList = false;
  List<DocumentSnapshot>? documentList;

  late BehaviorSubject<List<DocumentSnapshot>> chatListController;

  late BehaviorSubject<bool> showIndicatorController;

  ChatListBloc() {
    chatListController = BehaviorSubject<List<DocumentSnapshot>>();
    showIndicatorController = BehaviorSubject<bool>();
    firebaseChatListProvider = FirebaseChatListProvider();
  }

  bool get listEnd => endList;

  Stream get getShowIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get chatsStream => chatListController.stream;

/*This method will automatically fetch first 10 elements from the document list */
  Future fetchFirstList() async {
    try {
      documentList = await firebaseChatListProvider.fetchFirstList();
      chatListController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          chatListController.sink.addError("No Data Available");
        }
      } catch (e) {}
    } on SocketException {
      chatListController.sink
          .addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      chatListController.sink.addError(e);
    }
  }

/*This will automatically fetch the next 10 elements from the list*/
  Future fetchNextChats() async {
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList =
          await firebaseChatListProvider.fetchNextList(documentList!);
      documentList!.addAll(newDocumentList);
      chatListController.sink.add(documentList!);
      try {
        if (documentList!.length == 0) {
          chatListController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      } catch (e) {
        updateIndicator(false);
      }
    } on SocketException {
      chatListController.sink
          .addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    } catch (e) {
      updateIndicator(false);
      print(e.toString());
      chatListController.sink.addError(e);
    }
  }

/*For updating the indicator below every list and paginate*/
  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    chatListController.close();
    showIndicatorController.close();
  }
}
