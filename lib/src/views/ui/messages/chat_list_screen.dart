import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/bloc/bloc/chat_list_bloc.dart';
import 'package:edonation/src/bloc/bloc/user_bloc.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/chat.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/messages/chat_screen.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../utils/widgets/custom/custom_app_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  static const routeName = '/chat-list';

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  TextEditingController searchBarController = TextEditingController();
  TextEditingController chatController = TextEditingController();

  late ChatListBloc chatListBloc;
  late UserBloc userBloc;
  ScrollController controller = ScrollController();
  ScrollController addUserScrollController = ScrollController();

  List<Chat> userChats = [];
  List<Chat> _tempListOfChats = [];

  List<Users> users = [];
  List<Users> _tempListOfUsers = [];

  @override
  void dispose() {
    searchBarController.dispose();
    chatController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    chatListBloc = ChatListBloc();
    userBloc = UserBloc();
    chatListBloc.fetchFirstList();
    userBloc.fetchFirstList();
    controller.addListener(_scrollListener);
    addUserScrollController.addListener(_userScrollListener);
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      chatListBloc.fetchNextChats();
    }
  }

  void _userScrollListener() {
    if (addUserScrollController.offset >=
            addUserScrollController.position.maxScrollExtent &&
        !addUserScrollController.position.outOfRange) {
      userBloc.fetchNextUsers();
    }
  }

  Future<void> refresh() async {
    chatListBloc.fetchFirstList().then((value) {
      setState(() {
        // print('refresh');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    ScreenUtil.init(
      BoxConstraints(
        maxWidth: mediaQuery.size.width,
        maxHeight: mediaQuery.size.height,
      ),
      designSize: Size(392.75, 856.75),
      orientation: Orientation.portrait,
    );

    return Scaffold(
      appBar: CustomAppBar(
        text: 'Messages',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showModal(context);
        },
        backgroundColor: CustomColors.primaryColor,
        child: Icon(
          Icons.person_add_outlined,
          color: Colors.white,
        ),
      ),
      body: Container(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height,
        padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 22.0),
        color: CustomColors.backgroundColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              // if (false)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: CustomColors.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: chatController,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Search',
                                filled: true,
                                fillColor: CustomColors.whiteColor,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _tempListOfChats = _buildSearchList(value);
                                });
                              },
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                chatController.clear();
                                _tempListOfChats.clear();
                                FocusScope.of(context).unfocus();
                              });
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: CustomColors.iconColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(UserProfile.routeName,
                          arguments: userCurrent!.id);
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: CustomColors.whiteColor,
                      child: CircleAvatar(
                        radius: 23,
                        backgroundImage:
                            CachedNetworkImageProvider(userCurrent!.photoUrl),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: chatsRef
                          .doc(userCurrent!.id)
                          .collection('chat')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          userChats.clear();
                          snapshot.data!.docs.forEach((doc) {
                            Chat singleChat = Chat.fromDocument(doc);
                            userChats.add(singleChat);
                          });
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            controller: controller,
                            itemCount: _tempListOfChats.length > 0
                                ? _tempListOfChats.length
                                : userChats.length,
                            itemBuilder: (context, index) {
                              Chat currentChat = _tempListOfChats.length > 0
                                  ? _tempListOfChats[index]
                                  : userChats[index];
                              String rawMessage = currentChat.lastMessage;
                              String senderID = currentChat.senderID;
                              bool imageMessage = currentChat.type == 'image';
                              rawMessage =
                                  imageMessage ? '🖼️ Photo' : rawMessage;

                              String message = senderID == userCurrent!.id
                                  ? 'You: $rawMessage'
                                  : rawMessage;
                              message = message == 'You:  ' || message == ' '
                                  ? 'Let\'s start chat!'
                                  : message;
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ChatScreen.routeName,
                                      arguments: ChatScreenArguments(
                                          currentChat, false));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10.h),
                                  // padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: CustomColors.whiteColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: _tempListOfChats.length > 0
                                      ? buildMessageItem(
                                          index, _tempListOfChats, message)
                                      : buildMessageItem(
                                          index, userChats, message),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: CustomCircularBar(size: 75, padding: 22),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMessageItem(int index, List<Chat> chatList, String message) {
    return ListTile(
      // contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: CustomColors.primaryFadeColor,
        backgroundImage: CachedNetworkImageProvider(chatList[index].image),
      ),
      title: Text(
        chatList[index].name,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
              fontWeight: FontWeight.w600, color: CustomColors.textColor),
        ),
      ),
      subtitle: Text(
        message,
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            // ignore: deprecated_member_use
            fontSize: 12.ssp,
            color: CustomColors.textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        children: [
          Text(
            timeago.format(chatList[index].timestamp.toDate()),
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                // ignore: deprecated_member_use
                fontSize: 10.ssp,
                color: CustomColors.textFieldHintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (chatList[index].unseenCount > 0)
            Expanded(
              child: Container(
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: CustomColors.primaryColor,
                  child: Text(
                    chatList[index].unseenCount.toString(),
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        // ignore: deprecated_member_use
                        fontSize: 10.ssp,
                        color: CustomColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  List<Chat> _buildSearchList(String userSearchTerm) {
    List<Chat> _searchList = [];

    for (int i = 0; i < userChats.length; i++) {
      String name = userChats[i].name;

      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(userChats[i]);
        // print(name);
      }
    }
    return _searchList;
  }

  List<Users> _buildUserSearchList(String userSearchTerm) {
    List<Users> _searchList = [];

    for (int i = 0; i < users.length; i++) {
      String name = users[i].username;

      if (name.toLowerCase().contains(userSearchTerm.toLowerCase())) {
        _searchList.add(users[i]);
        // print(name);
      }
    }
    return _searchList;
  }

  void _showModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      backgroundColor: CustomColors.whiteColor,
      elevation: 5,
      context: context,
      builder: (context) {
        //3
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(22),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: CustomColors.textFieldFillColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchBarController,
                                  decoration: InputDecoration.collapsed(
                                    hintText: 'Search',
                                    filled: true,
                                    fillColor: CustomColors.textFieldFillColor,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _tempListOfUsers =
                                          _buildUserSearchList(value);
                                    });
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    searchBarController.clear();
                                    _tempListOfUsers.clear();
                                    FocusScope.of(context).unfocus();
                                  });
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: CustomColors.iconColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22),
                          child: StreamBuilder<List<DocumentSnapshot>>(
                            stream: userBloc.usersStream,
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                users.clear();
                                snapshot.data!.forEach((doc) {
                                  Users singleUser = Users.fromDocument(doc);

                                  if (!userChats.any((element) =>
                                          element.userId == singleUser.id) &&
                                      (singleUser.id != userCurrent!.id))
                                    users.add(singleUser);
                                });
                                return ListView.separated(
                                  controller: addUserScrollController,
                                  itemCount: _tempListOfUsers.length > 0
                                      ? _tempListOfUsers.length
                                      : users.length,
                                  separatorBuilder: (context, int) {
                                    return Divider(
                                      height: 1,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    Users currentUser =
                                        _tempListOfUsers.length > 0
                                            ? _tempListOfUsers[index]
                                            : users[index];
                                    DateTime lastSeen =
                                        DateTime.fromMillisecondsSinceEpoch(
                                            currentUser.lastSeenEpochs);
                                    DateTime currentDateTime = DateTime.now();

                                    Duration differenceDuration =
                                        currentDateTime.difference(lastSeen);
                                    String durationString = differenceDuration
                                                .inSeconds >
                                            59
                                        ? differenceDuration.inMinutes > 59
                                            ? differenceDuration.inHours > 23
                                                ? '${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : 'days'}'
                                                : '${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? 'hour' : 'hours'}'
                                            : '${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? 'minute' : 'minutes'}'
                                        : 'few moments';

                                    String presenceString = currentUser.presence
                                        ? 'Online'
                                        : '$durationString ago';
                                    return InkWell(
                                      child: ListTile(
                                        leading: Stack(
                                          alignment:
                                              AlignmentDirectional.bottomEnd,
                                          children: [
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor:
                                                  CustomColors.primaryFadeColor,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      _tempListOfUsers.length >
                                                              0
                                                          ? _tempListOfUsers[
                                                                  index]
                                                              .photoUrl
                                                          : users[index]
                                                              .photoUrl),
                                            ),
                                            CircleAvatar(
                                              radius: 7,
                                              backgroundColor:
                                                  CustomColors.whiteColor,
                                              child: CircleAvatar(
                                                radius: 5,
                                                backgroundColor: currentUser
                                                        .presence
                                                    ? CustomColors.primaryColor
                                                    : CustomColors
                                                        .textFieldHintColor,
                                              ),
                                            )
                                          ],
                                        ),
                                        title: Text(
                                          _tempListOfUsers.length > 0
                                              ? _tempListOfUsers[index].username
                                              : users[index].username,
                                          style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: CustomColors.textColor),
                                          ),
                                        ),
                                        trailing: chatScreenLoading
                                            ? Center(
                                                child: CustomCircularBar(
                                                    size: 75, padding: 22),
                                              )
                                            : Text(
                                                presenceString,
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    // ignore: deprecated_member_use
                                                    fontSize: 10.ssp,
                                                    color: CustomColors
                                                        .textFieldHintColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      onTap: () async {
                                        if (!chatScreenLoading) {
                                          Navigator.of(context).pop();
                                          createOrGetConversation(
                                              userCurrent!, currentUser);
                                        }
                                      },
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                  child:
                                      CustomCircularBar(size: 75, padding: 22),
                                );
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  bool chatScreenLoading = false;

  createOrGetConversation(Users currentUser, Users otherUser) async {
    try {
      DocumentSnapshot chat = await chatsRef
          .doc(userCurrent!.id)
          .collection('chat')
          .doc(otherUser.id)
          .get();
      if (chat.exists) {
        Chat currentChat = Chat.fromDocument(chat);
        Navigator.of(context).pushNamed(ChatScreen.routeName,
            arguments: ChatScreenArguments(currentChat, false));
      } else {
        Navigator.of(context).pushNamed(ChatScreen.routeName,
            arguments: ChatScreenArguments(
                Chat(
                    chatId: '',
                    senderID: currentUser.id,
                    userId: otherUser.id,
                    image: otherUser.photoUrl,
                    lastMessage: ' ',
                    name: otherUser.username,
                    timestamp: Timestamp.now(),
                    type: 'text',
                    unseenCount: 0),
                true));
      }
    } catch (e) {
      print('this is try state');
    }
  }
}
