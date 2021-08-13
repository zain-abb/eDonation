import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/addresses.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/donation_record.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/views/ui/donations/submit_review.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/single/single_post.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DonationsRecord extends StatefulWidget {
  DonationsRecord({Key? key}) : super(key: key);

  static const routeName = '/donations-record';

  @override
  _DonationsRecordState createState() => _DonationsRecordState();
}

class _DonationsRecordState extends State<DonationsRecord>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  int _selectedIndex = 0;

  List<Widget> list = [
    Tab(text: 'All'),
    Tab(text: 'Pending'),
    Tab(text: 'Accepted'),
    Tab(text: 'Rejected'),
  ];

  String formatTime(String time) {
    final date = DateFormat('HH:mm').parse(time);
    final format = DateFormat('hh:mm a');
    final clockString = format.format(date);
    return clockString;
  }

  String formatDate(String date) {
    final scheduleDate = DateTime.parse(date);
    final format = DateFormat(' MMM dd, yyyy');
    final dateString = format.format(scheduleDate);
    return dateString;
  }

  @override
  void initState() {
    super.initState();
    // Create TabController for getting the index of current tab
    _controller = TabController(length: list.length, vsync: this);

    _controller.addListener(() {
      setState(() {
        _selectedIndex = _controller.index;
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
        text: 'Your Donations',
        backButton: true,
      ),
      body: Container(
        padding: EdgeInsets.all(22),
        height: double.infinity,
        color: CustomColors.backgroundColor,
        child: _allDonations(),
      ),
    );
  }

  _allDonations() {
    return StreamBuilder<QuerySnapshot>(
      stream: donationRecordRef
          .doc(userCurrent!.id)
          .collection('record')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.docs.length != 0) {
            return ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DonationRecord donationRecord =
                        DonationRecord.fromDocumnet(snapshot.data!.docs[index]);
                    Color statusColor = CustomColors.primaryFadeColor;
                    String statusText = 'Pending';
                    if (donationRecord.status == 'pending') {
                      statusColor = CustomColors.primaryFadeColor;
                      statusText = 'Pending';
                    } else if (donationRecord.status == 'done') {
                      statusColor = CustomColors.primaryColor;
                      statusText = 'Accepted';
                    } else {
                      statusColor = CustomColors.errorColor;
                      statusText = 'Rejected';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            color: CustomColors.whiteColor,
                            borderRadius: BorderRadius.circular(15.0)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        donationRecord.campaignTitle,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            // ignore: deprecated_member_use
                                            fontSize: 18.ssp,
                                            color: CustomColors.headingColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ChoiceChip(
                                      label: Text(
                                        statusText,
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            // ignore: deprecated_member_use
                                            fontSize: 12.ssp,
                                            color: donationRecord.status ==
                                                    'pending'
                                                ? CustomColors.textColor
                                                : CustomColors.whiteColor,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                      selected: false,
                                      backgroundColor: statusColor,
                                      onSelected: (_) {},
                                    ),
                                  ],
                                ),
                                Text(
                                  '${donationRecord.donation.toInt().toString()} donation(s)',
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      // ignore: deprecated_member_use
                                      fontSize: 16.ssp,
                                      color: CustomColors.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                            ExpansionTileCard(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              contentPadding: EdgeInsets.zero,
                              baseColor: CustomColors.whiteColor,
                              expandedColor: CustomColors.whiteColor,
                              expandedTextColor: CustomColors.textColor,
                              elevation: 0,
                              title: Text(
                                'Scheduled on:\n${formatTime(donationRecord.scheduleTime)}, ${formatDate(donationRecord.scheduleDate)}',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    // ignore: deprecated_member_use
                                    fontSize: 15.ssp,
                                    color: CustomColors.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Donation Description",
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          // ignore: deprecated_member_use
                                          fontSize: 15.ssp,
                                          color: CustomColors.textColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      donationRecord.description,
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          // ignore: deprecated_member_use
                                          fontSize: 15.ssp,
                                          color: CustomColors.textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (donationRecord.addresId
                                        .trim()
                                        .isNotEmpty) ...[
                                      SizedBox(height: 10),
                                      Text(
                                        "Address",
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            // ignore: deprecated_member_use
                                            fontSize: 15.ssp,
                                            color: CustomColors.textColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      FutureBuilder<DocumentSnapshot>(
                                        future: addressesRef
                                            .doc(userCurrent!.id)
                                            .collection('address')
                                            .doc(donationRecord.addresId)
                                            .get(),
                                        builder: (context, futureSnapshot) {
                                          if (futureSnapshot.hasData) {
                                            Addresses addresses =
                                                Addresses.fromDocument(
                                                    futureSnapshot.data!);
                                            return Text(
                                              'Phone: ${addresses.phoneNumber}\n${addresses.addressLineOne}\n${addresses.addressLineTwo}\n${addresses.city}\n${addresses.state} - ${addresses.zipCode}\nPakistan',
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  // ignore: deprecated_member_use
                                                  fontSize: 15.ssp,
                                                  color: CustomColors.textColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Center(
                                              child: CustomCircularBar(
                                                  size: 75, padding: 22),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                    SizedBox(height: 10),
                                    Text(
                                      donationRecord.scheduleType == 'dropoff'
                                          ? 'You will dropoff the donations at beneficiary\'s location!'
                                          : 'Beneficiary will pickup the donations!',
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          // ignore: deprecated_member_use
                                          fontSize: 15.ssp,
                                          color: CustomColors.textColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    SinglePost.routeName,
                                                    arguments:
                                                        SinglePostArguments(
                                                            donationRecord
                                                                .postUserId,
                                                            donationRecord
                                                                .postId));
                                              },
                                              style: ButtonStyle(
                                                minimumSize:
                                                    MaterialStateProperty.all<
                                                        Size>(Size(150, 44)),
                                                shape:
                                                    MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                'View Post'.toUpperCase(),
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                    // ignore: deprecated_member_use
                                                    fontSize: 15.ssp,
                                                    color: CustomColors
                                                        .primaryColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              )),
                                        ),
                                        SizedBox(width: 22),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                                elevation: MaterialStateProperty
                                                    .all<double>(2),
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                    CustomColors.primaryColor),
                                                foregroundColor:
                                                    MaterialStateProperty.all<Color>(
                                                        CustomColors
                                                            .whiteColor),
                                                minimumSize: MaterialStateProperty
                                                    .all<Size>(Size(150, 44)),
                                                shape: MaterialStateProperty.all<
                                                        RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ))),
                                            onPressed: () async {
                                              DocumentSnapshot postSnapshot =
                                                  await postsRef
                                                      .doc(donationRecord
                                                          .postUserId)
                                                      .collection('userPosts')
                                                      .doc(
                                                          donationRecord.postId)
                                                      .get();
                                              Posts post = Posts.fromDocument(
                                                  postSnapshot);
                                              Navigator.of(context).pushNamed(
                                                  SubmitReview.routeName,
                                                  arguments:
                                                      SubmitReviewArguments(
                                                          post));
                                            },
                                            child: Text(
                                              'Add Review'.toUpperCase(),
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  // ignore: deprecated_member_use
                                                  fontSize: 15.ssp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      timeago.format(
                                          donationRecord.timestamp.toDate()),
                                      style: GoogleFonts.openSans(
                                        textStyle: TextStyle(
                                          // ignore: deprecated_member_use
                                          fontSize: 10.ssp,
                                          color:
                                              CustomColors.textFieldHintColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ));
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
                        'No Donations Yet!'.toUpperCase(),
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
          return Center(
            child: CustomCircularBar(size: 75, padding: 22),
          );
        }
      },
    );
  }
}
