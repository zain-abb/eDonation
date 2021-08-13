import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/donors.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/models/reviews.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/donations/donation_first_step.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/profile/user_post_donors.dart';
import 'package:edonation/src/views/ui/profile/user_post_reviews.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserPostDetail extends StatefulWidget {
  UserPostDetail(this.post, this.donors, this.reviews, {Key? key})
      : super(key: key);

  static const routeName = '/user-post-detail';

  final Posts post;
  final List<Donors> donors;
  final List<Reviews> reviews;

  @override
  _UserPostDetailState createState() => _UserPostDetailState();
}

class _UserPostDetailState extends State<UserPostDetail> {
  var currentAddresses = '';
  var campaignAddresses = '';

  @override
  void initState() {
    _getLoc(widget.post.userLocation).then((value) {
      var list = value;
      currentAddresses = list;
      setState(() {
        currentAddresses = list;
      });
    });

    _getLoc(widget.post.location).then((value) {
      var list = value;
      campaignAddresses = list;
      setState(() {
        campaignAddresses = list;
      });
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeSavedPosts(widget.post);
  }

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

  bool isSaved = false;

  _initializeSavedPosts(Posts post) async {
    final snapshot = await savedPostsRef
        .doc(userCurrent!.id)
        .collection('saved')
        .doc(post.postId)
        .get();
    if (snapshot.exists) {
      setState(() {
        isSaved = true;
      });
    } else if (!snapshot.exists) {
      setState(() {
        isSaved = false;
      });
    }
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
        isSaved = false;
      });
      await savedPostsRef
          .doc(userCurrent!.id)
          .collection('saved')
          .doc(post.postId)
          .delete();
    } else if (!snapshot.exists) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
      setState(() {
        isSaved = true;
      });
      await savedPostsRef
          .doc(userCurrent!.id)
          .collection('saved')
          .doc(post.postId)
          .set({'postId': post.postId, 'userId': widget.post.userId});
    }
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

    final campaignDuration = DateTime.parse(widget.post.duration);
    final currentDate = DateTime.now();
    final daysLeft = campaignDuration.difference(currentDate).inDays;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        backButton: true,
        text: 'Post Detail',
      ),
      floatingActionButton: daysLeft > 0 &&
              widget.post.raised < widget.post.target &&
              !(widget.post.userId == userCurrent!.id)
          ? SizedBox(
              width: mediaQuery.size.width - 88.w,
              height: 56.h,
              child: FloatingActionButton.extended(
                backgroundColor: CustomColors.primaryColor,
                foregroundColor: CustomColors.whiteColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                onPressed: () {
                  Navigator.of(context).pushNamed(DonationFirstStep.routeName,
                      arguments: DonationFirstStepArguments(widget.post));
                },
                label: Text(
                  'Help'.toUpperCase(),
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 15.ssp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation:
          daysLeft > 0 ? FloatingActionButtonLocation.centerFloat : null,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
            left: 22.w,
            right: 22.w,
            top: 22.h,
            bottom: daysLeft > 0 && widget.post.raised < widget.post.target
                ? 88.h
                : 22.h,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: CustomColors.backgroundColor),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _campaignHeader(widget.post),
              _campaignDetails(
                  widget.post, daysLeft, widget.donors, widget.reviews),
            ],
          ),
        ),
      ),
    );
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

  List<Widget> _getRatingStars(double rating, double size) {
    List<Widget> stars = [];
    int roundedRating = rating.toInt();
    double difference = rating - roundedRating;
    for (int i = 0; i < 5; i++) {
      if (i < roundedRating) {
        if (difference.isNegative && i == roundedRating - 1) {
          stars.add(
            Icon(
              CupertinoIcons.star_lefthalf_fill,
              size: size,
              color: Colors.amber,
            ),
          );
        } else {
          stars.add(
            Icon(
              CupertinoIcons.star_fill,
              size: size,
              color: Colors.amber,
            ),
          );
        }
      } else {
        stars.add(
          Icon(
            CupertinoIcons.star_fill,
            size: size,
            color: CustomColors.textFieldBorderColor,
          ),
        );
      }
    }
    return stars;
  }

  _campaignDetails(
      Posts post, int daysLeft, List<Donors> donors, List<Reviews> reviews) {
    double percentage = post.raised / post.target;
    if (percentage > 1.0) {
      percentage = 1.0;
    } else if (percentage < 0) {
      percentage = 0.0;
    }
    double rating = _getRating(reviews);
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Container(
        margin: EdgeInsets.only(top: 22.h),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: CustomColors.whiteColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requirements',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 18.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 5),
            Text(
              'Description',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 18.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              post.campaignDescription,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 14.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w300,
                ),
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 5),
            Text(
              'Donations',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 18.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 13.0,
                backgroundWidth: 10,
                animation: true,
                animationDuration: 500,
                percent: percentage,
                center: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 18.ssp,
                      color: CustomColors.headingColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'Target ${post.target.round()}',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        // ignore: deprecated_member_use
                        fontSize: 16.ssp,
                        color: CustomColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: CustomColors.primaryColor,
                backgroundColor: CustomColors.primaryFadeColor,
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: RichText(
                    text: TextSpan(
                      text: 'Donations ',
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
                          text: post.raised.round().toString(),
                          style: TextStyle(color: CustomColors.primaryColor),
                        )
                      ],
                    ),
                  ),
                  selected: false,
                  backgroundColor: CustomColors.primaryFadeColor,
                  onSelected: (_) {},
                ),
                SizedBox(width: 22.w),
                ChoiceChip(
                  label: daysLeft > 0 && post.raised < post.target
                      ? RichText(
                          text: TextSpan(
                            text: 'Days Left ',
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
                                text: daysLeft.toString(),
                                style: TextStyle(
                                  color: daysLeft < 7
                                      ? CustomColors.errorColor
                                      : CustomColors.primaryColor,
                                ),
                              )
                            ],
                          ),
                        )
                      : Text(
                          'Completed',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 12.ssp,
                              color: CustomColors.textColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                  selected: false,
                  backgroundColor: CustomColors.primaryFadeColor,
                  onSelected: (_) {},
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              'Donors',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 18.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: donors.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pushNamed(UserPostDonors.routeName,
                          arguments: PostDetailDonorArguments(donors));
                    },
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      // alignment: AlignmentDirectional.center,
                      children: _donorAvatars(donors).map((e) => e).toList(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 18.ssp,
                      color: CustomColors.headingColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: reviews.isNotEmpty
                      ? () {
                          Navigator.of(context).pushNamed(
                              UserPostReviews.routeName,
                              arguments: PostDetailReviewsArguments(reviews));
                        }
                      : null,
                  child: Row(
                    children: [
                      ..._getRatingStars(rating, 14.0),
                      SizedBox(width: 5),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: reviews.isNotEmpty
                            ? CustomColors.primaryColor
                            : CustomColors.textFieldBorderColor,
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> _donorAvatars(List<Donors> donors) {
    List<Widget> donorAvatars = [];

    if (donors.length > 11) {
      for (int i = 0; i < 12; i++) {
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
        } else if (i == 11) {
          donorAvatars.add(
            Positioned(
              left: 22.0 * i,
              child: CircleAvatar(
                backgroundColor: CustomColors.backgroundColor,
                radius: 21,
                child: CircleAvatar(
                  backgroundColor: CustomColors.primaryColor,
                  radius: 20,
                  child: Text(
                    '+${donors.length - 11}'.toUpperCase(),
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
              left: 22.0 * i,
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
    } else if (donors.length < 11 && donors.length > 0) {
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
            left: 22.0 * i,
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
    } else if (donors.isEmpty) {
      donorAvatars.add(Text(
        'No donors',
        style: GoogleFonts.openSans(
          textStyle: TextStyle(
            // ignore: deprecated_member_use
            fontSize: 15.ssp,
            color: CustomColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ));
      return donorAvatars;
    }
    return donorAvatars;
  }

  String getDate(Timestamp timestamp) {
    DateTime date =
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    String formattedDate = DateFormat('hh:mm aaa, MMMM dd, yyyy').format(date);
    return formattedDate;
  }

  _campaignHeader(Posts post) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: CustomColors.whiteColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Container(
                  height: 200.h,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    child: CachedNetworkImage(
                      imageUrl: post.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  child: ChoiceChip(
                    padding: EdgeInsets.zero,
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
                  height: 200.h,
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
                    borderRadius: BorderRadius.all(Radius.circular(15)),
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
                                    campaignAddresses,
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
                          Text(
                            // getDate(post.timestamp),
                            timeago.format(post.timestamp.toDate()),
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 8.ssp,
                                color: CustomColors.whiteColor,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(UserProfile.routeName,
                          arguments: post.userId);
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: CustomColors.backgroundColor,
                          backgroundImage:
                              CachedNetworkImageProvider(post.userPhotoUrl),
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
                                  currentAddresses,
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
                  Row(
                    children: [
                      InputChip(
                        label: Icon(
                          isSaved
                              ? CupertinoIcons.bookmark_fill
                              : CupertinoIcons.bookmark,
                          color: CustomColors.primaryColor,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        backgroundColor: CustomColors.primaryFadeColor,
                        onPressed: () {
                          _addToSavedPostsList(post);
                        },
                      ),
                      InputChip(
                        label: Icon(
                          CupertinoIcons.share,
                          size: 16,
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
}
