import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:edonation/src/helpers/update_last_seen.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/posts/add_post_splash_screen.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/ui/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'home_screen.dart';
import '../search/search_screen.dart';
import '../messages/chat_list_screen.dart';
import '../settings/preferences_screen.dart';
import '../../utils/widgets/custom/custom_icons.dart';
import '../../utils/widgets/custom/custom_colors.dart';

final postsRef = FirebaseFirestore.instance.collection('posts');
final savedPostsRef = FirebaseFirestore.instance.collection('savedPosts');
final donorsRef = FirebaseFirestore.instance.collection('donors');
final reviewsRef = FirebaseFirestore.instance.collection('reviews');
final addressesRef = FirebaseFirestore.instance.collection('addresses');
final donationScheduleRef =
    FirebaseFirestore.instance.collection('donationSchedule');
final feedRef = FirebaseFirestore.instance.collection('feed');
final timelineRef = FirebaseFirestore.instance.collection('timeline');
final chatsRef = FirebaseFirestore.instance.collection('users');
final conversationsRef = FirebaseFirestore.instance.collection('chats');
final donationRecordRef =
    FirebaseFirestore.instance.collection('donationRecord');
Users? userCurrent;

class Pager extends StatefulWidget {
  Pager({Key? key}) : super(key: key);

  static const routeName = '/pager';

  @override
  _PagerState createState() => _PagerState();
}

class _PagerState extends State<Pager> {
  PageController? pageController;
  int pageIndex = 0;

  int counter = 0;

  bool isLoading = false;

  // ignore: cancel_subscriptions
  StreamSubscription? subscription;

  _initializeUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(auth.currentUser!.uid).get();
    await updateUserPresence(auth.currentUser!.uid);
    setState(() {
      userCurrent = Users.fromDocument(doc);
      isLoading = false;
    });
  }

  @override
  void initState() {
    _initializeUser();
    pageController = PageController();
    subscription =
        Connectivity().onConnectivityChanged.listen(showConnectivitySnackBar);

    super.initState();
  }

  @override
  void dispose() {
    pageController!.dispose();
    subscription!.cancel();
    super.dispose();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController!.jumpToPage(
      pageIndex,
      // duration: Duration(milliseconds: 500),
      // curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? SplashScreen()
          : PageView(
              children: [
                HomeScreen(),
                SearchScreen(),
                AddPostSplashScreen(),
                ChatListScreen(),
                PreferencesScreen(),
              ],
              controller: pageController,
              onPageChanged: onPageChanged,
              physics: NeverScrollableScrollPhysics(),
            ),
      bottomNavigationBar: isLoading
          ? null
          : CupertinoTabBar(
              currentIndex: pageIndex,
              onTap: onTap,
              activeColor: CustomColors.primaryColor,
              inactiveColor: CustomColors.iconColor,
              iconSize: 26,
              backgroundColor: CustomColors.whiteColor,
              items: [
                BottomNavigationBarItem(
                    icon: Container(
                  child: Icon(CustomIcons.home),
                  margin: EdgeInsets.symmetric(vertical: 14),
                )),
                BottomNavigationBarItem(
                    icon: Container(
                  child: Icon(CustomIcons.search),
                  margin: EdgeInsets.symmetric(vertical: 14),
                )),
                BottomNavigationBarItem(
                    icon: Container(
                  child: Icon(CustomIcons.add_new),
                  margin: EdgeInsets.symmetric(vertical: 14),
                )),
                BottomNavigationBarItem(
                    icon: Container(
                  child: Icon(CustomIcons.chat),
                  margin: EdgeInsets.symmetric(vertical: 14),
                )),
                BottomNavigationBarItem(
                    icon: Container(
                  child: Icon(CustomIcons.profile),
                  margin: EdgeInsets.symmetric(vertical: 14),
                )),
              ],
            ),
    );
  }

  void showConnectivitySnackBar(ConnectivityResult result) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    var message = 'Unknown';
    var color = CustomColors.primaryColor;

    try {
      if (connectivityResult == ConnectivityResult.mobile) {
        if (await InternetConnectionChecker().hasConnection) {
          message = 'Connected!';
          color = CustomColors.primaryColor;
        } else {
          message = 'Connected, but no internet!';
          color = CustomColors.errorColor;
        }
      } else if (connectivityResult == ConnectivityResult.wifi) {
        if (await InternetConnectionChecker().hasConnection) {
          message = 'Connected!';
          color = CustomColors.primaryColor;
        } else {
          message = 'Connected, but no internet!';
          color = CustomColors.errorColor;
        }
      } else if (connectivityResult == ConnectivityResult.none) {
        message = 'Connection Lost!';
        color = CustomColors.errorColor;
      }
    } catch (err) {
      message = 'Connected, but no internet!';
      color = CustomColors.errorColor;
    }

    if (counter == 0 && message.contains('Connected!')) {
      return;
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
    counter++;
  }
}
