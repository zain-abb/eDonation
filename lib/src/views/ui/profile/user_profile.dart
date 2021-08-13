import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/chat.dart';
import 'package:edonation/src/models/donors.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/models/reviews.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/messages/chat_screen.dart';
import 'package:edonation/src/views/ui/profile/user_edit_profile.dart';
import 'package:edonation/src/views/ui/profile/user_post_list.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:unsplash_client/unsplash_client.dart' as Unsplash;

class UserProfile extends StatefulWidget {
  UserProfile(this.userId, {Key? key}) : super(key: key);

  final String userId;

  static const routeName = '/user-profile';

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String url = 'https://source.unsplash.com/daily?nature';

  bool isLoading = false;
  int postCount = 0;
  List<Posts> posts = [];
  Users? userData;

  @override
  void initState() {
    getUserProfile();
    getProfilePosts();

    // _unspalshAPI();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getUserProfile();
  }

  @override
  void didUpdateWidget(covariant UserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    getUserProfile();
  }

  _unspalshAPI() async {
    final client = Unsplash.UnsplashClient(
      settings: Unsplash.ClientSettings(
        credentials: Unsplash.AppCredentials(
          accessKey: 'SBbsW4XkRGfqSFlVNyLFml3xsl7yN-2QopDEMCr5T2A',
          secretKey: '3yWOehXbPgbm_2F1RmBTN4SPc6-Ht8pHJz0EcBUBucE',
        ),
      ),
    );
    try {
      final photos = await client.photos
          .random(count: 1, featured: true, query: 'nature')
          .goAndGet();
      final photo = photos.first;
      setState(() {
        url = photo.urls.regular.toString();
      });
    } catch (err) {
      print(err.toString());
    }
  }

  bool userLoading = false;

  getUserProfile() async {
    setState(() {
      userLoading = true;
    });
    final updatedUserSnapshot = await usersRef.doc(widget.userId).get();
    setState(() {
      userData = Users.fromDocument(updatedUserSnapshot);
      userLoading = false;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.userId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Posts.fromDocument(doc)).toList();
      isLoading = false;
    });
  }

  String currentAddresses = '';

  _getLoc(GeoPoint location) async {
    var currentAddress = '';
    final geoPoint = location;
    final lat = geoPoint.latitude;
    final long = geoPoint.longitude;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      currentAddress = place.locality.toString();
    } catch (e) {
      print(e);
    }
    return currentAddress;
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
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        backButton: true,
        text: 'Profile',
      ),
      body: Container(
        color: CustomColors.backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _profileCard(),
              _postsCard(mediaQuery.size.height),
            ],
          ),
        ),
      ),
    );
  }

  _postsCard(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 22.h),
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: CustomColors.whiteColor,
          ),
          height: size * 0.47.h,
          child: isLoading
              ? Center(child: CustomCircularBar(size: 75, padding: 22))
              : ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  child: posts.length == 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/no_posts.png',
                                height: 200,
                                width: 200,
                              ),
                              // SizedBox(height: 22.h),
                              Text(
                                'No Posts Yet'.toUpperCase(),
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    // ignore: deprecated_member_use
                                    fontSize: 14.ssp,
                                    color: CustomColors.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: posts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0),
                          itemBuilder: (BuildContext context, int index) {
                            return ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              child: Material(
                                child: InkWell(
                                  splashColor: CustomColors.errorColor,
                                  onTap: () {
                                    // _placeholder();
                                    // if (donorLoading && reviewLoading)
                                    Navigator.of(context).pushNamed(
                                      UserPostList.routeName,
                                      arguments: PostArguments(
                                          userData!, posts, index),
                                    );
                                  },
                                  child: Ink(
                                    child: Container(
                                      child: CachedNetworkImage(
                                        imageUrl: posts[index].imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ),
    );
  }

  _profileCard() {
    if (!userLoading)
      _getLoc(userData!.loc).then((value) {
        var list = value;
        currentAddresses = list;
        setState(() {
          currentAddresses = list;
        });
      });
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Container(
        height: userLoading ? 300.h : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: CustomColors.whiteColor,
        ),
        child: userLoading
            ? Center(
                child: CustomCircularBar(size: 56, padding: 16),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5)),
                        child: Container(
                          height: 130.h,
                          width: double.infinity,
                          child: FadeInImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                            placeholder: MemoryImage(kTransparentImage),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 22.w,
                        bottom: -50.h,
                        child: CircleAvatar(
                          backgroundColor: CustomColors.whiteColor,
                          foregroundColor: CustomColors.whiteColor,
                          radius: 40,
                          child: CircleAvatar(
                            backgroundColor: CustomColors.whiteColor,
                            radius: 38,
                            child: AspectRatio(
                              aspectRatio: 1 / 1,
                              child: ClipOval(
                                child: FadeInImage(
                                  fit: BoxFit.cover,
                                  placeholder: MemoryImage(kTransparentImage),
                                  image: CachedNetworkImageProvider(
                                    userData!.photoUrl,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(left: 110.w, top: 10.h, right: 22.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData!.username,
                          // 'Zain Abbas',
                          style: GoogleFonts.alata(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 22.ssp,
                              color: CustomColors.headingColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              CustomIcons.location,
                              size: 14,
                              color: CustomColors.primaryColor,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              currentAddresses,
                              // 'Pindi Bhattian',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 16.ssp,
                                  color: CustomColors.primaryColor,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Text(
                          userData!.bio,
                          // 'This is my bio line...',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 12.ssp,
                              color: CustomColors.textColor,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: 10.h, top: 10.h, left: 22.w, right: 22.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChoiceChip(
                          label: RichText(
                            text: TextSpan(
                              text: 'Total Campagins ',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 12.ssp,
                                  color: CustomColors.textColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              children: [
                                TextSpan(
                                  text: '$postCount',
                                  style: TextStyle(
                                      color: CustomColors.primaryColor),
                                )
                              ],
                            ),
                          ),
                          selected: false,
                          backgroundColor: CustomColors.primaryFadeColor,
                          onSelected: (_) {},
                        ),
                        Row(
                          children: [
                            if (userData!.id != userCurrent!.id)
                              InputChip(
                                label: chatScreenLoading
                                    ? Center(
                                        child: CustomCircularBar(
                                            size: 18, padding: 2),
                                      )
                                    : Icon(
                                        CustomIcons.chat,
                                        size: 18,
                                        color: CustomColors.primaryColor,
                                      ),
                                padding: EdgeInsets.zero,
                                backgroundColor: CustomColors.primaryFadeColor,
                                onPressed: () {
                                  createOrGetConversation(
                                      userCurrent!, userData!);
                                },
                              ),
                            if (userData!.id == userCurrent!.id)
                              InputChip(
                                label: Icon(
                                  CustomIcons.edit_square,
                                  size: 18,
                                  color: CustomColors.primaryColor,
                                ),
                                padding: EdgeInsets.zero,
                                backgroundColor: CustomColors.primaryFadeColor,
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(EditUserProfile.routeName)
                                      .then((value) {
                                    if (value != null)
                                      setState(() {
                                        userData = value as Users;
                                      });
                                  });
                                },
                              ),
                            InputChip(
                              label: Icon(
                                CustomIcons.share,
                                size: 18,
                                color: CustomColors.primaryColor,
                              ),
                              padding: EdgeInsets.zero,
                              backgroundColor: CustomColors.primaryFadeColor,
                              onPressed: () {
                                print('Share');
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool chatScreenLoading = false;

  // createOrGetConversation(Users currentUser, Users otherUser) async {
  //   try {
  //     DocumentSnapshot chat = await chatsRef
  //         .doc(userCurrent!.id)
  //         .collection('chat')
  //         .doc(otherUser.id)
  //         .get();
  //     if (chat.exists) {
  //       Chat currentChat = Chat.fromDocument(chat);
  //       Navigator.of(context).pushNamed(ChatScreen.routeName,
  //           arguments: ChatScreenArguments(currentChat, false));
  //     } else {
  //       setState(() {
  //         chatScreenLoading = true;
  //       });
  //       final conversationDocument = conversationsRef.doc();
  //       await conversationDocument.set({
  //         "members": [currentUser.id, otherUser.id],
  //         "ownerID": currentUser.id,
  //         'messages': [],
  //       });
  //       try {
  //         chatsRef
  //             .doc(userCurrent!.id)
  //             .collection('chat')
  //             .doc(otherUser.id)
  //             .snapshots()
  //             .listen((chatStream) {
  //           if (chatStream.exists) {
  //             Chat currentChat = Chat.fromDocument(chatStream);
  //             print('currentChat');
  //             setState(() {
  //               chatScreenLoading = false;
  //             });
  //             Navigator.of(context).pushNamed(ChatScreen.routeName,
  //                 arguments: ChatScreenArguments(currentChat, true));
  //           }
  //         }).onError((error, stackTrace) {
  //           print('this is error state');
  //           print(error);
  //         });
  //       } catch (e) {
  //         print('Error');
  //       }
  //     }
  //   } catch (e) {
  //     print('this is try state');
  //   }
  // }

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
