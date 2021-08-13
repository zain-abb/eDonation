import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/single/single_post.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_tagline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignCreatedScreen extends StatefulWidget {
  const CampaignCreatedScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-created';

  @override
  _CampaignCreatedState createState() => _CampaignCreatedState();
}

class _CampaignCreatedState extends State<CampaignCreatedScreen> {
  Map<String, dynamic>? previousData;
  String postId = '';
  @override
  Widget build(BuildContext context) {
    previousData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    postId = previousData!['postId'];
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
        text: 'Campaign Created',
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
                      child: Image.asset('assets/images/congratulations.png'),
                    ),
                    SizedBox(height: 8.h),
                    TagLine(
                      key: UniqueKey(),
                      tagLine: '',
                      vip: 'Congratulations!',
                      fontSize: 24,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Your campaign is created successfully!',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 17.ssp,
                          color: CustomColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // SizedBox(height: 5),
                    // Text(
                    //   'You will shortly receive an email confirmation for your campaign verification',
                    //   style: GoogleFonts.openSans(
                    //     textStyle: TextStyle(
                    //       // ignore: deprecated_member_use
                    //       fontSize: 15.ssp,
                    //       color: CustomColors.textColor,
                    //       fontWeight: FontWeight.w500,
                    //     ),
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    SizedBox(height: 34.h),
                    CustomButton(
                      pressedFun: () {
                        Navigator.of(context).pushNamed(SinglePost.routeName,
                            arguments:
                                SinglePostArguments(userCurrent!.id, postId));
                      },
                      buttonText: 'View Campaign',
                      margin: [0.0, 15.0, 0.0, 0.0],
                      backgroundColor: 0xFF40aa54,
                      foregroundColor: 0xFFFFFFFF,
                      width: 44,
                      fontColor: 0xFFFFFFFF,
                    ),
                    SizedBox(height: 10.h),
                    OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Pager.routeName, (Route<dynamic> route) => false);
                        },
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                              Size(MediaQuery.of(context).size.width, 56.h)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        child: Text(
                          'Brows Home'.toUpperCase(),
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              // ignore: deprecated_member_use
                              fontSize: 15.ssp,
                              color: CustomColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),
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
