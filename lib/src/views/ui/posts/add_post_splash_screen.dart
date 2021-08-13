import 'package:edonation/src/views/ui/posts/campaign_issues_screen.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_tagline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPostSplashScreen extends StatefulWidget {
  const AddPostSplashScreen({Key? key}) : super(key: key);

  static const routeName = '/post-splash';

  @override
  _AddPostSplashState createState() => _AddPostSplashState();
}

class _AddPostSplashState extends State<AddPostSplashScreen> {
  // List<IconData> iconList = [
  //   CupertinoIcons.waveform, // Campaign
  //   CupertinoIcons.calendar, // Event
  // ];
  int primaryIndex = 0;

  void changeIndex(int index) {
    setState(() {
      primaryIndex = index;
    });
  }

  Widget customRadioButton(IconData icon, int index) {
    return RawMaterialButton(
      onPressed: () => changeIndex(index),
      shape: CircleBorder(),
      padding: EdgeInsets.all(15.0),
      elevation: 1.5,
      fillColor: (primaryIndex == index
          ? CustomColors.primaryColor
          : CustomColors.textFieldBorderColor),
      child: Icon(
        icon,
        color: primaryIndex == index
            ? CustomColors.whiteColor
            : CustomColors.iconColor,
        size: 35.0,
      ),
    );
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
        text: 'New Post',
      ),
      body: Container(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height,
        color: CustomColors.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: 12.h, bottom: 0, right: 22.w, left: 22.w),
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 100),
                  child: TagLine(
                    key: UniqueKey(),
                    tagLine: 'Start ',
                    vip: 'with!',
                    fontSize: 24,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: CustomColors.whiteColor,
                ),
                margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: 12.h),
                    Container(
                      width: 200.h,
                      height: 200.h,
                      child: Image.asset('assets/images/new_post.png'),
                    ),
                    // SizedBox(height: 22.h),
                    Text(
                      'What kind of post you want to create?',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 15.ssp,
                          color: CustomColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // SizedBox(height: 34.h),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   mainAxisSize: MainAxisSize.max,
                    //   children: <Widget>[
                    //     Column(
                    //       children: [
                    //         customRadioButton(iconList[0], 0),
                    //         SizedBox(height: 8.h),
                    //         Text(
                    //           'Campaign',
                    //           style: GoogleFonts.openSans(
                    //             textStyle: TextStyle(
                    //               // ignore: deprecated_member_use
                    //               fontSize: 15.ssp,
                    //               color: primaryIndex == 0
                    //                   ? CustomColors.primaryColor
                    //                   : CustomColors.textColor,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     Column(
                    //       children: [
                    //         customRadioButton(iconList[1], 1),
                    //         SizedBox(height: 8.h),
                    //         Text(
                    //           'Event',
                    //           style: GoogleFonts.openSans(
                    //             textStyle: TextStyle(
                    //               // ignore: deprecated_member_use
                    //               fontSize: 15.ssp,
                    //               color: primaryIndex == 1
                    //                   ? CustomColors.primaryColor
                    //                   : CustomColors.textColor,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 34.h),
                    CustomButton(
                      pressedFun: () {
                        String postType = '';
                        if (primaryIndex == 0) {
                          postType = 'Campaign';
                        } else if (primaryIndex == 1) {
                          postType = 'Event';
                        }
                        Navigator.of(context).pushNamed(
                            CampaignIssuesScreen.routeName,
                            arguments: postType);
                      },
                      buttonText: 'Next',
                      margin: [0.0, 15.0, 0.0, 0.0],
                      backgroundColor: 0xFF40aa54,
                      foregroundColor: 0xFFFFFFFF,
                      width: 44,
                      fontColor: 0xFFFFFFFF,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
