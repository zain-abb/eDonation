import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/feed.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/ui/single/single_donation.dart';
import 'package:edonation/src/views/ui/single/single_post.dart';
import 'package:edonation/src/views/ui/single/single_review.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  ActivityFeed({Key? key}) : super(key: key);

  static const routeName = '/activity-feed';

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  Future<List<Feed>> getActivityFeed() async {
    QuerySnapshot snapshot = await feedRef
        .doc(userCurrent!.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<Feed> feeds = [];
    snapshot.docs.forEach((element) {
      feeds.add(Feed.fromDocument(element));
    });
    return feeds;
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
        text: 'Activity Feed',
        backButton: true,
      ),
      body: Container(
        color: CustomColors.backgroundColor,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: CustomColors.whiteColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: FutureBuilder(
                future: getActivityFeed(),
                builder: (context, AsyncSnapshot<List<Feed>> snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: CustomCircularBar(size: 56, padding: 16),
                      ),
                    );
                  }
                  if (snapshot.data!.length == 0) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 75),
                      width: double.infinity,
                      height: double.infinity,
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
                              'No Activity Feed'.toUpperCase(),
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
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, position) {
                      String activityType =
                          snapshot.data![position].activityType;
                      String activityText = '';
                      if (activityType == 'donation')
                        activityText =
                            ' donates ${snapshot.data![position].number.toInt()} to your campaign';
                      else if (activityType == 'review')
                        activityText =
                            ' gives ${snapshot.data![position].number} star rating to your campaign ';
                      return Column(
                        children: [
                          ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    UserProfile.routeName,
                                    arguments: snapshot.data![position].userId);
                              },
                              child: CircleAvatar(
                                backgroundColor: CustomColors.backgroundColor,
                                backgroundImage: CachedNetworkImageProvider(
                                    snapshot.data![position].userImageUrl),
                              ),
                            ),
                            title: GestureDetector(
                              onTap: () {
                                if (activityType == 'donation') {
                                  Navigator.of(context).pushNamed(
                                      SingleDonation.routeName,
                                      arguments: SingleDonationArguments(
                                          snapshot.data![position]));
                                } else if (activityType == 'review') {
                                  Navigator.of(context).pushNamed(
                                      SingleReview.routeName,
                                      arguments: SingleReviewArguments(
                                          snapshot.data![position]));
                                }
                              },
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: snapshot.data![position].username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: CustomColors.headingColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: activityText,
                                      style: TextStyle(
                                        color: CustomColors.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            subtitle: Text(
                              timeago.format(
                                  snapshot.data![position].timestamp.toDate()),
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 10.ssp,
                                  color: CustomColors.iconColor,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    SinglePost.routeName,
                                    arguments: SinglePostArguments(
                                        userCurrent!.id,
                                        snapshot.data![position].postId));
                              },
                              child: Container(
                                height: 50.0,
                                width: 50.0,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              snapshot.data![position]
                                                  .postMediaUrl),
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                            enableFeedback: true,
                          ),
                          Divider(
                            height: 1,
                            indent: 22.w,
                            endIndent: 22.w,
                          )
                        ],
                      );
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }
}
