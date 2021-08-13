import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/reviews.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserPostReviews extends StatefulWidget {
  UserPostReviews(this.reviews, {Key? key}) : super(key: key);

  static const routeName = '/user-post-reviews';

  final List<Reviews> reviews;

  @override
  _UserPostReviewsState createState() => _UserPostReviewsState();
}

class _UserPostReviewsState extends State<UserPostReviews> {
  List<String> userAddresses = [];

  _getUserLocation() async {
    userAddresses = List.filled(widget.reviews.length, '');
    List<String> currentAddress = [];
    for (int i = 0; i < widget.reviews.length; i++) {
      final geoPoint = widget.reviews[i].user.loc;
      final lat = geoPoint.latitude;
      final long = geoPoint.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
        Placemark place = placemarks[0];
        currentAddress.add('${place.locality}');
      } catch (e) {
        print(e);
      }
    }

    return currentAddress;
  }

  String getDate(Timestamp timestamp) {
    DateTime date =
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    String formattedDate = DateFormat('MMM dd, yy').format(date);
    return formattedDate;
  }

  @override
  void initState() {
    _countStars(widget.reviews);
    _getUserLocation().then((value) {
      var list = value;
      userAddresses = list;
      setState(() {
        userAddresses = list;
      });
    });
    super.initState();
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
        text: 'Reviews',
      ),
      body: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: CustomColors.backgroundColor),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _reviewsHeader(widget.reviews),
              _reviewDetails(
                  mediaQuery.size.height, widget.reviews, userAddresses),
            ],
          ),
        ),
      ),
    );
  }

  _reviewDetails(
      double height, List<Reviews> reviews, List<String> userAddresses) {
    return Container(
      height: height * 0.57.h,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: CustomColors.backgroundColor),
      margin: EdgeInsets.only(top: 22.h),
      // padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          physics: BouncingScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: CustomColors.whiteColor),
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.only(
                  top: 10.h, left: 10.w, right: 22.w, bottom: 22.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundColor: CustomColors.backgroundColor,
                            backgroundImage: CachedNetworkImageProvider(
                                reviews[index].userPhotoUrl),
                            radius: 26,
                          ),
                          SizedBox(width: 10.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reviews[index].username,
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
                                    color: CustomColors.textColor,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    userAddresses[index],
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                        // ignore: deprecated_member_use
                                        fontSize: 14.ssp,
                                        color: CustomColors.textColor,
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
                      Text(
                        // getDate(reviews[index].timestamp),
                        timeago.format(reviews[index].timestamp.toDate()),
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            // ignore: deprecated_member_use
                            fontSize: 10.ssp,
                            color: CustomColors.textFieldHintColor,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 62.w),
                    child: Column(
                      children: [
                        Text(
                          reviews[index].review,
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
                        SizedBox(height: 10),
                        Row(
                            children:
                                _getRatingStars(reviews[index].rating, 15)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
        stars.add(
          Icon(
            CupertinoIcons.star_fill,
            size: size,
            color: Colors.amber,
          ),
        );
      } else {
        if (difference == 0.5 && i == roundedRating) {
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
              color: CustomColors.textFieldBorderColor,
            ),
          );
        }
      }
    }
    return stars;
  }

  int fiveStar = 0;
  int fourStar = 0;
  int threeStar = 0;
  int twoStar = 0;
  int oneStar = 0;

  _countStars(List<Reviews> reviews) {
    for (int i = 0; i < reviews.length; i++) {
      double rating = reviews[i].rating;
      if (rating == 5.0) {
        setState(() {
          fiveStar += 1;
        });
      } else if (rating >= 4.0 && rating < 5.0) {
        setState(() {
          fourStar += 1;
        });
      } else if (rating >= 3.0 && rating < 4.0) {
        setState(() {
          threeStar += 1;
        });
      } else if (rating >= 2.0 && rating < 3.0) {
        setState(() {
          twoStar += 1;
        });
      } else {
        setState(() {
          oneStar += 1;
        });
      }
    }
  }

  _reviewsHeader(List<Reviews> reviews) {
    double rating = _getRating(reviews);
    int length = reviews.length;
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: CustomColors.whiteColor,
        ),
        child: Column(
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
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: CustomColors.primaryColor,
                        radius: 30,
                        child: Text(
                          rating.toString(),
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 16.ssp,
                              color: CustomColors.whiteColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: _getRatingStars(rating, 20.0),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        '${reviews.length} Reviews',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            // ignore: deprecated_member_use
                            fontSize: 16.ssp,
                            color: CustomColors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 22.w),
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 3.0,
                            animationDuration: 500,
                            percent: fiveStar / length,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: CustomColors.primaryColor,
                            backgroundColor: CustomColors.primaryFadeColor,
                            leading: Text(
                              '5 Star',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 16.ssp,
                                  color: CustomColors.textFieldHintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Text(
                              fiveStar.toString(),
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
                        SizedBox(height: 5),
                        Container(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 3.0,
                            animationDuration: 500,
                            percent: fourStar / length,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: CustomColors.primaryColor,
                            backgroundColor: CustomColors.primaryFadeColor,
                            leading: Text(
                              '4 Star',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 16.ssp,
                                  color: CustomColors.textFieldHintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Text(
                              fourStar.toString(),
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
                        SizedBox(height: 5),
                        Container(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 3.0,
                            animationDuration: 500,
                            percent: threeStar / length,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: CustomColors.primaryColor,
                            backgroundColor: CustomColors.primaryFadeColor,
                            leading: Text(
                              '3 Star',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 16.ssp,
                                  color: CustomColors.textFieldHintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Text(
                              threeStar.toString(),
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
                        SizedBox(height: 5),
                        Container(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 3.0,
                            animationDuration: 500,
                            percent: twoStar / length,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: CustomColors.primaryColor,
                            backgroundColor: CustomColors.primaryFadeColor,
                            leading: Text(
                              '2 Star',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 16.ssp,
                                  color: CustomColors.textFieldHintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Text(
                              twoStar.toString(),
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
                        SizedBox(height: 5),
                        Container(
                          child: LinearPercentIndicator(
                            animation: true,
                            lineHeight: 3.0,
                            animationDuration: 500,
                            percent: oneStar / length,
                            linearStrokeCap: LinearStrokeCap.roundAll,
                            progressColor: CustomColors.primaryColor,
                            backgroundColor: CustomColors.primaryFadeColor,
                            leading: Text(
                              '1 Star',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 16.ssp,
                                  color: CustomColors.textFieldHintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Text(
                              oneStar.toString(),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
