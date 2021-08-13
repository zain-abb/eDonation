import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/bloc/bloc/timeline_bloc.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/donors.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/models/reviews.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/donations/donation_first_step.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/profile/user_post_detail.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  late TimelineListBloc timelineListBloc;

  ScrollController controller = ScrollController();

  bool donorLoading = false;

  Future<List<Donors>> _getDonors(Posts postList) async {
    List<Donors> postDonors = [];
    final donorSnapshot =
        await donorsRef.doc(postList.postId).collection('donor').get();
    donorSnapshot.docs.forEach(
      (doc) async {
        final userSnapshot = await usersRef.doc(doc['userId']).get();
        Users postDonorsUser = Users.fromDocument(userSnapshot);
        if (doc['status'] == 'done')
          postDonors.add(
            Donors(
              donorId: doc['donorId'],
              userId: postDonorsUser.id,
              userPhotoUrl: postDonorsUser.photoUrl,
              username: postDonorsUser.username,
              postId: doc['postId'],
              donation: double.parse(doc['donation'].toString()),
              description: doc['description'],
              timestamp: doc['timestamp'],
              status: doc['status'],
            ),
          );
      },
    );

    return postDonors;
  }

  Future<List<Reviews>> _getReviews(Posts postList) async {
    List<Reviews> postReviews = [];
    final reviewSnapshot =
        await reviewsRef.doc(postList.postId).collection('reviews').get();
    reviewSnapshot.docs.forEach(
      (doc) async {
        final userSnapshot = await usersRef.doc(doc['userId']).get();
        Users postReviewUser = Users.fromDocument(userSnapshot);
        postReviews.add(
          Reviews(
            reviewId: doc['reviewId'],
            userId: postReviewUser.id,
            username: postReviewUser.username,
            userPhotoUrl: postReviewUser.photoUrl,
            user: postReviewUser,
            postId: doc['postId'],
            rating: double.parse(doc['rating'].toString()),
            review: doc['review'],
            timestamp: doc['timestamp'],
          ),
        );
      },
    );
    // return Future.value(postReviews);
    return postReviews;
  }

  double _getRating(List<Reviews> review) {
    double rating = 0.0;
    double avgRating = 0.0;
    if (review.length == 0) rating = 0.0;
    for (int j = 0; j < review.length; j++) {
      rating += review[j].rating;
    }
    avgRating = rating / review.length;
    return avgRating.isNaN ? 0.0 : avgRating;
  }

  @override
  void initState() {
    super.initState();
    timelineListBloc = TimelineListBloc();
    timelineListBloc.fetchFirstList();
    controller.addListener(_scrollListener);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(
        Duration(seconds: 1),
        () => timelineListBloc.fetchFirstList().then((value) {
          setState(() {});
        }),
      );
    });

    _initializeSavedPosts();
  }

  bool isLoading = false;

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      timelineListBloc.fetchNextTimeline();
    }
  }

  Future<String> _getLoc(GeoPoint location) async {
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

  Future<void> refresh() async {
    timelineListBloc.fetchFirstList().then((value) {
      setState(() {
        // print('refresh');
      });
    });
  }

  update() {
    setState(() {
      // print('update');
    });
  }

  List<String> savedPostId = [];

  _initializeSavedPosts() async {
    final snapshot =
        await savedPostsRef.doc(userCurrent!.id).collection('saved').get();
    snapshot.docs.forEach((element) {
      savedPostId.add(element['postId']);
    });
  }

  _addToSavedPostsList(Posts post) async {
    final snapshot = await savedPostsRef
        .doc(userCurrent!.id)
        .collection('saved')
        .doc(post.postId)
        .get();
    if (snapshot.exists) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        savedPostId.remove(post.postId);
      });
      await savedPostsRef
          .doc(userCurrent!.id)
          .collection('saved')
          .doc(post.postId)
          .delete();
    } else if (!snapshot.exists) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        savedPostId.add(post.postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  height: 25,
                  width: 25,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Saved',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 16.ssp,
                    color: CustomColors.whiteColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: CustomColors.primaryColor,
        ),
      );
      await savedPostsRef
          .doc(userCurrent!.id)
          .collection('saved')
          .doc(post.postId)
          .set({'postId': post.postId, 'userId': post.userId});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        isLogo: true,
        text: 'Home',
        backButton: false,
        imageUrl: userCurrent!.photoUrl,
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        backgroundColor: CustomColors.whiteColor,
        color: CustomColors.primaryColor,
        child: Container(
          color: CustomColors.backgroundColor,
          height: mediaQuery.size.height,
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: timelineListBloc.timelineStream,
              builder: (context, streamSnapshot) {
                // print('StreamBuilder');
                if (streamSnapshot.data != null) {
                  if (streamSnapshot.data!.length != 0) {
                    return ListView.builder(
                      itemCount: streamSnapshot.data!.length,
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      controller: controller,
                      itemBuilder: (context, index) {
                        Posts post =
                            Posts.fromDocument(streamSnapshot.data![index]);
                        int distance = (Geolocator.distanceBetween(
                                post.userLocation.latitude,
                                post.userLocation.longitude,
                                post.location.latitude,
                                post.userLocation.longitude) ~/
                            1000);
                        if (distance <= 20) {
                          List<Donors> donorsList = [];
                          List<Reviews> reviewsList = [];

                          return FutureBuilder(
                            future: Future.wait([
                              _getReviews(post),
                              _getDonors(post),
                              _getLoc(post.location),
                              _getLoc(post.userLocation),
                            ]),
                            builder: (context,
                                AsyncSnapshot<List<dynamic>>
                                    innerFutureSnapshot) {
                              String userAddress = '';
                              String postAddress = '';

                              if (innerFutureSnapshot.hasData) {
                                reviewsList
                                    .addAll(innerFutureSnapshot.data![0]);
                                donorsList.addAll(innerFutureSnapshot.data![1]);
                                postAddress = innerFutureSnapshot.data![2];
                                userAddress = innerFutureSnapshot.data![3];
                              }
                              if (!isLoading) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      UserPostDetail.routeName,
                                      arguments: PostDetailArguments(
                                          post, donorsList, reviewsList),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(bottom: 22.h),
                                    padding: EdgeInsets.fromLTRB(
                                        22.w, 22.h, 22.w, 10.h),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        color: CustomColors.whiteColor),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        _profileAvatar(post, userAddress),
                                        _campaignImage(
                                            post, postAddress, reviewsList),
                                        _donationDetails(post),
                                        SizedBox(height: 8.h),
                                        _donors(post, donorsList),
                                        Container(
                                          margin: EdgeInsets.only(top: 10.h),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            timeago.format(
                                                post.timestamp.toDate()),
                                            style: GoogleFonts.openSans(
                                              textStyle: TextStyle(
                                                // ignore: deprecated_member_use
                                                fontSize: 10.ssp,
                                                color: CustomColors
                                                    .textFieldHintColor,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Center(
                                  child:
                                      CustomCircularBar(size: 75, padding: 22),
                                );
                              }
                            },
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    );
                  } else {
                    return Container(
                        // margin: EdgeInsets.all(22),
                        padding: EdgeInsets.all(22),
                        decoration: BoxDecoration(
                            color: CustomColors.whiteColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Center(
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
                                'No Campaigns!'.toUpperCase(),
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
                        ));
                  }
                } else {
                  return Container(
                      // margin: EdgeInsets.all(22),
                      padding: EdgeInsets.all(22),
                      decoration: BoxDecoration(
                          color: CustomColors.whiteColor,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Center(
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
                              'No Campaigns!'.toUpperCase(),
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
                      ));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _donorAvatars(List<Donors> donors) {
    List<Widget> donorAvatars = [];

    if (donors.length > 7) {
      for (int i = 0; i < 8; i++) {
        if (i == 0) {
          donorAvatars.add(
            CircleAvatar(
              backgroundColor: CustomColors.backgroundColor,
              radius: 21,
              child: CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                backgroundImage:
                    CachedNetworkImageProvider(donors[i].userPhotoUrl),
                radius: 20,
              ),
            ),
          );
        } else if (i == 7) {
          donorAvatars.add(
            Positioned(
              left: 12.0 * i,
              child: CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                radius: 21,
                child: CircleAvatar(
                  backgroundColor: CustomColors.primaryColor,
                  radius: 20,
                  child: Text(
                    '+${donors.length - 7}'.toUpperCase(),
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        // ignore: deprecated_member_use
                        fontSize: 12.ssp,
                        color: CustomColors.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          donorAvatars.add(
            Positioned(
              left: 12.0 * i,
              child: CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                radius: 21,
                child: CircleAvatar(
                  backgroundColor: CustomColors.backgroundColor,
                  backgroundImage:
                      CachedNetworkImageProvider(donors[i].userPhotoUrl),
                  radius: 20,
                ),
              ),
            ),
          );
        }
      }
      return donorAvatars;
    } else if (donors.length < 7 && donors.length > 0) {
      for (int i = 0; i < donors.length; i++) {
        if (i == 0) {
          donorAvatars.add(
            CircleAvatar(
              backgroundColor: CustomColors.backgroundColor,
              radius: 21,
              child: CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                backgroundImage:
                    CachedNetworkImageProvider(donors[i].userPhotoUrl),
                radius: 20,
              ),
            ),
          );
        }
        donorAvatars.add(
          Positioned(
            left: 12.0 * i,
            child: CircleAvatar(
              backgroundColor: CustomColors.backgroundColor,
              radius: 21,
              child: CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                backgroundImage:
                    CachedNetworkImageProvider(donors[i].userPhotoUrl),
                radius: 20,
              ),
            ),
          ),
        );
      }
      return donorAvatars;
    }
    return donorAvatars;
  }

  _donors(Posts post, List<Donors> donors) {
    final campaignDuration = DateTime.parse(post.duration);
    final currentDate = DateTime.now();
    final daysLeft = campaignDuration.difference(currentDate).inDays;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Stack(
            children: donors.isEmpty
                ? [
                    Text(
                      'No donors',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 15.ssp,
                          color: CustomColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ]
                : _donorAvatars(donors).map((e) => e).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: daysLeft > 0 &&
                  post.raised < post.target &&
                  !(post.userId == userCurrent!.id)
              ? () {
                  Navigator.of(context).pushNamed(DonationFirstStep.routeName,
                      arguments: DonationFirstStepArguments(post));
                }
              : null,
          child: Text(
            'Help'.toUpperCase(),
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                // ignore: deprecated_member_use
                fontSize: 15.ssp,
                color: CustomColors.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(daysLeft > 0 &&
                      post.raised < post.target &&
                      !(post.userId == userCurrent!.id)
                  ? CustomColors.primaryColor
                  : CustomColors.textFieldBorderColor),
              minimumSize: MaterialStateProperty.all<Size>(Size(88.w, 42.h)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ))),
        ),
      ],
    );
  }

  _donationDetails(Posts post) {
    double percentage = post.raised / post.target;
    if (percentage > 1.0) {
      percentage = 1.0;
    } else if (percentage < 0) {
      percentage = 0.0;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Requirements',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 20.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              height: 20,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                alignment: Alignment.centerRight,
                onPressed: () {
                  _addToSavedPostsList(post);
                },
                icon: Icon(
                  savedPostId.any((id) => id == post.postId)
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  color: savedPostId.any((id) => id == post.postId)
                      ? CustomColors.primaryColor
                      : CustomColors.iconColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          post.campaignReq,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              // ignore: deprecated_member_use
              fontSize: 14.ssp,
              color: CustomColors.headingColor,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        SizedBox(height: 7),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: 'Target: ',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 16.ssp,
                    color: CustomColors.textFieldHintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  TextSpan(
                    text: post.target.round().toString(),
                    style: TextStyle(color: CustomColors.textColor),
                  )
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Raised: ',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 16.ssp,
                    color: CustomColors.textFieldHintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  TextSpan(
                    text: post.raised.round().toString(),
                    style: TextStyle(color: CustomColors.primaryColor),
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          child: LinearPercentIndicator(
            animation: true,
            lineHeight: 10.0,
            animationDuration: 800,
            percent: percentage,
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: CustomColors.primaryColor,
            backgroundColor: CustomColors.primaryFadeColor,
            trailing: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 16.ssp,
                    color: CustomColors.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _campaignImage(Posts post, String address, List<Reviews> reviews) {
    double rating = 0;
    rating = _getRating(reviews);
    return Container(
      margin: EdgeInsets.only(top: 15.h, bottom: 10.h),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Container(
              height: 250.h,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: post.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
              child: ChoiceChip(
                label: Text(
                  post.issueType,
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 12.ssp,
                      color: CustomColors.whiteColor,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                selected: false,
                backgroundColor: CustomColors.primaryColor,
                onSelected: (_) {},
              ),
            ),
            Container(
              height: 250.h,
              width: double.infinity,
              padding: EdgeInsets.all(15),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Color(0x000000).withOpacity(0.6),
                    Color(0xFFFFFF).withOpacity(0.0)
                  ],
                ),
              ),
              child: Column(
                children: [
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.campaignTitle,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 16.ssp,
                                color: CustomColors.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                CustomIcons.location,
                                size: 12,
                                color: CustomColors.whiteColor,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                address,
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    // ignore: deprecated_member_use
                                    fontSize: 14.ssp,
                                    color: CustomColors.whiteColor,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 14,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 3),
                          Text(
                            rating.toString(),
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 14.ssp,
                                color: CustomColors.whiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _profileAvatar(Posts post, String address) {
    final campaignDuration = DateTime.parse(post.duration);
    final currentDate = DateTime.now();
    final daysLeft = campaignDuration.difference(currentDate).inDays;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(UserProfile.routeName, arguments: post.userId);
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                backgroundImage: CachedNetworkImageProvider(post.userPhotoUrl),
                radius: 26,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username,
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        // ignore: deprecated_member_use
                        fontSize: 16.ssp,
                        color: CustomColors.headingColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        CustomIcons.location,
                        size: 12,
                        color: CustomColors.primaryColor,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        address,
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            // ignore: deprecated_member_use
                            fontSize: 14.ssp,
                            color: CustomColors.primaryColor,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (daysLeft > 0 && post.raised < post.target)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$daysLeft',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 28.ssp,
                    color: daysLeft < 7
                        ? CustomColors.errorColor
                        : CustomColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Days left',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 12.ssp,
                    color: CustomColors.textColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          )
        else
          Text(
            'Completed',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                // ignore: deprecated_member_use
                fontSize: 12.ssp,
                color: CustomColors.textColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => false;
}
