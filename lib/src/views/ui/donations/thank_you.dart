import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/views/ui/donations/submit_review.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_tagline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ThankYou extends StatefulWidget {
  const ThankYou(this.post, {Key? key}) : super(key: key);

  static const routeName = '/thank-you';

  final Posts post;

  @override
  _ThankYouState createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
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
        text: 'Thank You',
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
                      vip: 'Thank You!',
                      fontSize: 24,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'We are grateful for your contribution. Its your little efforts that add up to become a huge difference. The beneficiary will contact you soon.',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 15.ssp,
                          color: CustomColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 34.h),
                    // CustomButton(
                    //   pressedFun: () {
                    //     Navigator.of(context).pushNamed(SubmitReview.routeName,
                    //         arguments: SubmitReviewArguments(widget.post));
                    //   },
                    //   buttonText: 'Rate the Campaign',
                    //   margin: [0.0, 15.0, 0.0, 0.0],
                    //   backgroundColor: 0xFF40aa54,
                    //   foregroundColor: 0xFFFFFFFF,
                    //   width: 44,
                    //   fontColor: 0xFFFFFFFF,
                    // ),
                    // SizedBox(height: 10.h),
                    // OutlinedButton(
                    //     onPressed: () {
                    //       Navigator.of(context).pushNamedAndRemoveUntil(
                    //           Pager.routeName, (Route<dynamic> route) => false);
                    //     },
                    //     style: ButtonStyle(
                    //       minimumSize: MaterialStateProperty.all<Size>(
                    //           Size(MediaQuery.of(context).size.width, 56.h)),
                    //       shape:
                    //           MaterialStateProperty.all<RoundedRectangleBorder>(
                    //         RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8.0),
                    //         ),
                    //       ),
                    //     ),
                    //     child: Text(
                    //       'Brows Home'.toUpperCase(),
                    //       style: GoogleFonts.openSans(
                    //         textStyle: TextStyle(
                    //           // ignore: deprecated_member_use
                    //           fontSize: 15.ssp,
                    //           color: CustomColors.primaryColor,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     )),
                    CustomButton(
                      pressedFun: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Pager.routeName, (Route<dynamic> route) => false);
                      },
                      buttonText: 'Brows Home',
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
