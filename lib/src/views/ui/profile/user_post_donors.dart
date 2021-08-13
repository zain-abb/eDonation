import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/donors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserPostDonors extends StatefulWidget {
  UserPostDonors(this.donors, {Key? key}) : super(key: key);

  static const routeName = '/user-post-donors';

  final List<Donors> donors;

  @override
  _UserPostDonorsState createState() => _UserPostDonorsState();
}

class _UserPostDonorsState extends State<UserPostDonors> {
  ScrollController _scrollController = ScrollController();

  List<Donors> sortedDonors = [];
  List<Donors> topDonors = [];
  List<Donors> remainingDonors = [];

  String getDate(Timestamp timestamp) {
    DateTime date =
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    String formattedDate = DateFormat('MMMM dd, yyyy').format(date);
    return formattedDate;
  }

  @override
  void initState() {
    _sortDonors();
    super.initState();
  }

  _sortDonors() {
    setState(() {
      widget.donors.sort((a, b) => a.donation.compareTo(b.donation));
      sortedDonors = widget.donors.reversed.toList();
      topDonors = sortedDonors.take(5).toList();
      remainingDonors = sortedDonors.skip(5).toList();
      // remainingDonors = sortedDonors;
      remainingDonors.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      remainingDonors = remainingDonors.reversed.toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        text: 'Donors',
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
              _topDonors(topDonors),
              _donors(mediaQuery.size.height, remainingDonors),
            ],
          ),
        ),
      ),
    );
  }

  _donors(double height, List<Donors> donors) {
    return Container(
      height: height * 0.52.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: CustomColors.whiteColor,
      ),
      margin: EdgeInsets.only(top: 22.h),
      // padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
      child: donors.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.all(22),
                    child: Image.asset(
                      'assets/images/not_found_2.png',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  // SizedBox(height: 22.h),
                  Text(
                    'No donors'.toUpperCase(),
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
          : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: BouncingScrollPhysics(),
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Material(
                        color: CustomColors.whiteColor,
                        child: InkWell(
                          onTap: () {
                            print("tapped");
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: CustomColors.backgroundColor,
                              backgroundImage: CachedNetworkImageProvider(
                                  donors[index].userPhotoUrl),
                            ),
                            title: Text(donors[index].username),
                            subtitle: Text(
                              // getDate(donors[index].timestamp),
                              timeago.format(donors[index].timestamp.toDate()),
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 10.ssp,
                                  color: CustomColors.textFieldHintColor,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            trailing: Text(
                              donors[index].donation.round().toString(),
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 18.ssp,
                                  color: CustomColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            enableFeedback: true,
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 22.w,
                        endIndent: 22.w,
                      )
                    ],
                  );
                },
              ),
            ),
    );
  }

  _topDonors(List<Donors> donors) {
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
              'Top Donors',
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  // ignore: deprecated_member_use
                  fontSize: 18.ssp,
                  color: CustomColors.headingColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Scrollbar(
              controller: _scrollController,
              radius: Radius.circular(15),
              isAlwaysShown: true,
              child: Container(
                height: 160.h,
                margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: topDonors.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(
                          left: 15.w, right: 15.w, top: 10.h, bottom: 5.h),
                      margin: EdgeInsets.only(
                        right: index == donors.length - 1 ? 0.0 : 15.w,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                            color: CustomColors.textFieldBorderColor),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: CustomColors.backgroundColor,
                            backgroundImage: CachedNetworkImageProvider(
                                donors[index].userPhotoUrl),
                            radius: 30,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            donors[index].username,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 14.ssp,
                                color: CustomColors.textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: CustomColors.primaryFadeColor),
                            padding: EdgeInsets.symmetric(
                                horizontal: 22.w, vertical: 5.h),
                            child: Text(
                              donors[index].donation.round().toString(),
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 12.ssp,
                                  color: CustomColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            // getDate(donors[index].timestamp),
                            timeago.format(donors[index].timestamp.toDate()),
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 8.ssp,
                                color: CustomColors.textFieldHintColor,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
