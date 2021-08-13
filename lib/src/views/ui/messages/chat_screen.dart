import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/chat.dart';
import 'package:edonation/src/models/conversation.dart';
import 'package:edonation/src/models/message.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:edonation/src/views/utils/widgets/full_screen_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatScreen extends StatefulWidget {
  ChatScreen(this.chat, this.newChat, {Key? key}) : super(key: key);

  static const routeName = '/chat';

  final Chat chat;
  final bool newChat;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool newChat = false;
  String chatId = '';
  bool messageLoading = false;

  File? imageFile;

  bool isSendButton = false;
  bool isSender = true;
  bool isImage = false;

  String message = '';

  bool isLoading = false;

  _updateUnseenCount() async {
    await chatsRef
        .doc(userCurrent!.id)
        .collection('chat')
        .doc(widget.chat.userId)
        .update({'unseenCount': 0});
  }

  @override
  void initState() {
    newChat = widget.newChat;
    if (!newChat) {
      chatId = widget.chat.chatId;
      _updateUnseenCount();
    }
    print(widget.chat.chatId);
    super.initState();
  }

  @override
  void dispose() {
    if (!newChat) {
      _updateUnseenCount();
    }
    super.dispose();
  }

  String getUserStatus(Users recieverUser) {
    DateTime lastSeen =
        DateTime.fromMillisecondsSinceEpoch(recieverUser.lastSeenEpochs);
    DateTime currentDateTime = DateTime.now();

    Duration differenceDuration = currentDateTime.difference(lastSeen);
    String durationString = differenceDuration.inSeconds > 59
        ? differenceDuration.inMinutes > 59
            ? differenceDuration.inHours > 23
                ? '${differenceDuration.inDays} ${differenceDuration.inDays == 1 ? 'day' : 'days'}'
                : '${differenceDuration.inHours} ${differenceDuration.inHours == 1 ? 'hour' : 'hours'}'
            : '${differenceDuration.inMinutes} ${differenceDuration.inMinutes == 1 ? 'minute' : 'minutes'}'
        : 'few moments';

    String presenceString =
        recieverUser.presence ? 'Online' : 'last seen $durationString ago';
    return presenceString;
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
      backgroundColor: CustomColors.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: CustomColors.primaryColor,
        titleSpacing: 0,
        elevation: 2,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(UserProfile.routeName,
                arguments: widget.chat.userId);
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: CustomColors.whiteColor,
                child: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(widget.chat.image),
                ),
              ),
              SizedBox(width: 22.0 * 0.75),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat.name,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        // ignore: deprecated_member_use
                        fontSize: 16.ssp,
                        color: CustomColors.whiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: usersRef.doc(widget.chat.userId).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Users recieverUser = Users.fromDocument(snapshot.data!);
                        return Text(
                          !snapshot.hasData ? '' : getUserStatus(recieverUser),
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 12.ssp,
                              color: CustomColors.whiteColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: CustomColors.whiteColor,
              child: !newChat
                  ? StreamBuilder<DocumentSnapshot>(
                      stream: conversationsRef.doc(chatId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Conversation conversation =
                              Conversation.fromDocument(snapshot.data!);
                          List<Message> messages =
                              conversation.messages.reversed.toList();
                          List<bool> showTime =
                              List.filled(messages.length, false);
                          return ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: messages.length,
                            shrinkWrap: true,
                            reverse: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 22.0),
                            itemBuilder: (context, index) {
                              isSender =
                                  messages[index].senderID == userCurrent!.id;
                              isImage =
                                  messages[index].type == MessageType.Image;
                              return Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  mainAxisAlignment: isSender
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isSender) ...[
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                widget.chat.image),
                                      ),
                                      SizedBox(width: 22.0 / 2),
                                    ],
                                    if (!isImage) ...[
                                      Column(
                                        crossAxisAlignment: isSender
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                showTime[index] =
                                                    !showTime[index];
                                              });
                                              print(showTime);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.0,
                                                vertical: 8.0,
                                              ),
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      mediaQuery.size.width *
                                                          0.60),
                                              decoration: BoxDecoration(
                                                color: isSender
                                                    ? CustomColors.primaryColor
                                                    : CustomColors
                                                        .backgroundColor,
                                                borderRadius: BorderRadius
                                                    .circular(messages[index]
                                                                .message
                                                                .contains(
                                                                    '\n') ||
                                                            messages[index]
                                                                    .message
                                                                    .length >
                                                                32
                                                        ? 8
                                                        : 30),
                                                // borderRadius:
                                                //     BorderRadius.circular(30),
                                              ),
                                              child: Text(
                                                messages[index].message,
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color: isSender
                                                        ? CustomColors
                                                            .whiteColor
                                                        : CustomColors
                                                            .textColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (showTime[index])
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0,
                                                  top: 1,
                                                  right: 10.0),
                                              child: Text(
                                                DateTimeFormat.relative(
                                                    messages[index]
                                                        .timestamp
                                                        .toDate(),
                                                    ifNow: 'Now',
                                                    minUnitOfTime:
                                                        UnitOfTime.minute),
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    color:
                                                        CustomColors.textColor,
                                                    fontWeight: FontWeight.w500,
                                                    // ignore: deprecated_member_use
                                                    fontSize: 10.ssp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                    if (isImage)
                                      GestureDetector(
                                        onTap: () {
                                          String senderName = '';
                                          if (messages[index].senderID ==
                                              userCurrent!.id) {
                                            senderName = userCurrent!.username;
                                          } else {
                                            senderName = widget.chat.name;
                                          }
                                          Navigator.of(context).pushNamed(
                                            FullScreenImage.routeName,
                                            arguments: FullScreenImageArguments(
                                                messages[index], senderName),
                                          );
                                        },
                                        child: Container(
                                          height: 120.w,
                                          width: 120.w,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              imageUrl: messages[index].message,
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder:
                                                  (context, url, progress) {
                                                return Center(
                                                  child: CustomCircularBar(
                                                      size: 75, padding: 22),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    // messageContaint(message),
                                  ],
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
                    )
                  : Container(),
            ),
          ),
          chatInputField(),
        ],
      ),
    );
  }

  chatInputField() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 22.0,
        vertical: 22.0 / 2,
      ),
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: CustomColors.whiteColor,
        border: Border(top: BorderSide(color: CustomColors.backgroundColor)),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 32,
            color: CustomColors.headingColor.withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(right: 10, left: 15),
                decoration: BoxDecoration(
                  color: CustomColors.backgroundColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    // Icon(
                    //   CupertinoIcons.smiley,
                    //   color: CustomColors.iconColor,
                    // ),
                    // SizedBox(width: 22.0 / 4),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 5,
                          controller: messageController,
                          keyboardType: TextInputType.multiline,
                          cursorColor: CustomColors.primaryColor,
                          decoration: InputDecoration(
                            hintText: "Type message...",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                isSendButton = true;
                              });
                            } else {
                              setState(() {
                                isSendButton = false;
                              });
                            }
                          },
                          onSaved: (value) {
                            message = value!;
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        isSendButton
                            ? sendMessage(
                                Message(
                                    message: messageController.text,
                                    senderID: userCurrent!.id,
                                    type: MessageType.Text,
                                    timestamp: Timestamp.now()),
                                widget.chat)
                            : sendImageMessage(widget.chat);
                      },
                      child: messageLoading
                          ? Container(
                              width: 22,
                              height: 22,
                              margin: EdgeInsets.only(right: 5),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                backgroundColor: CustomColors.primaryColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    CustomColors.primaryFadeColor),
                              ),
                            )
                          : Icon(
                              isSendButton
                                  ? CupertinoIcons.arrow_up_circle_fill
                                  : CupertinoIcons.camera_circle_fill,
                              color: CustomColors.primaryColor,
                              size: 32,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendMessage(Message message, Chat chat) async {
    // FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.reset();
      messageController.clear();
      if (!newChat) {
        conversationsRef.doc(chatId).update({
          'messages': FieldValue.arrayUnion([
            {
              'message': message.message,
              'timestamp': message.timestamp,
              'type': message.type == MessageType.Text ? 'text' : 'image',
              'senderID': message.senderID
            }
          ]),
        });
      } else {
        setState(() {
          messageLoading = true;
        });
        final conversationDocument = conversationsRef.doc();
        await conversationDocument.set({
          "members": [userCurrent!.id, chat.userId],
          "ownerID": userCurrent!.id,
          'messages': FieldValue.arrayUnion([
            {
              'message': message.message,
              'timestamp': message.timestamp,
              'type': message.type == MessageType.Text ? 'text' : 'image',
              'senderID': message.senderID
            }
          ]),
        });
        try {
          chatsRef
              .doc(userCurrent!.id)
              .collection('chat')
              .doc(widget.chat.userId)
              .snapshots()
              .listen((doc) {
            if (doc.exists) {
              Timer(Duration(seconds: 2), () {
                setState(() {
                  chatId = conversationDocument.id;
                  newChat = false;
                  messageLoading = false;
                });
                print('false');
              });
            }
          }).onError((error) {
            print(error);
          });
        } catch (e) {
          print(e);
        }
      }
    }
    setState(() {
      isSendButton = false;
    });
  }

  imagePick() async {}

  sendImageMessage(Chat chat) async {
    try {
      FocusScope.of(context).unfocus();
      final picker = ImagePicker();
      PickedFile? pickedImage;

      pickedImage = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 75, maxWidth: 1024);

      setState(() {
        imageFile = File(pickedImage!.path);
      });
    } catch (err) {
      print('Select Image');
    }
    if (imageFile != null) {
      if (!newChat) {
        final timestamp = Timestamp.now();
        String filename = '${userCurrent!.id}_$timestamp.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('messages')
            .child(chatId)
            .child(filename);

        await ref.putFile(imageFile!);

        final url = await ref.getDownloadURL();
        conversationsRef.doc(widget.chat.chatId).update({
          'messages': FieldValue.arrayUnion([
            {
              'message': url,
              'timestamp': timestamp,
              'type': 'image',
              'senderID': userCurrent!.id
            }
          ]),
        });
      } else {
        setState(() {
          messageLoading = true;
        });
        final conversationDocument = conversationsRef.doc();
        final timestamp = Timestamp.now();
        String filename = '${userCurrent!.id}_$timestamp.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('messages')
            .child(chatId)
            .child(filename);

        await ref.putFile(imageFile!);

        final url = await ref.getDownloadURL();
        await conversationDocument.set({
          "members": [userCurrent!.id, chat.userId],
          "ownerID": userCurrent!.id,
          'messages': FieldValue.arrayUnion([
            {
              'message': url,
              'timestamp': timestamp,
              'type': 'image',
              'senderID': userCurrent!.id
            }
          ]),
        });
        try {
          chatsRef
              .doc(userCurrent!.id)
              .collection('chat')
              .doc(widget.chat.userId)
              .snapshots()
              .listen((doc) {
            if (doc.exists) {
              Timer(Duration(seconds: 2), () {
                setState(() {
                  chatId = conversationDocument.id;
                  newChat = false;
                  messageLoading = false;
                });
                print('false');
              });
            }
          }).onError((error) {
            print(error);
          });
        } catch (e) {
          print(e);
        }
      }
    }
    imageFile = null;
  }
}
