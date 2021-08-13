import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationCompletedScreen extends StatefulWidget {
  const VerificationCompletedScreen({Key? key}) : super(key: key);

  static const routeName = '/verification-completed';

  @override
  _VerificationCompletedScreenState createState() =>
      _VerificationCompletedScreenState();
}

class _VerificationCompletedScreenState
    extends State<VerificationCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(392.75, 856.75),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xfff0f0f0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Color(0xfff0f0f0),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(
                          top: 22.h, bottom: 22.h, left: 22.w, right: 22.w),
                      padding: EdgeInsets.only(
                          top: 22.h, bottom: 22.h, left: 22.w, right: 22.w),
                      width: MediaQuery.of(context).size.width - 44.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 12.h,
                          ),
                          Container(
                            width: 120.h,
                            height: 120.h,
                            child: Icon(
                              Icons.done,
                              size: 60.h,
                              color: Color(0xFF40aa54),
                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFe0f2f1)),
                          ),
                          SizedBox(height: 34.h),
                          Text(
                            'Verified',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 22.ssp,
                                color: Color(0xff011f32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Text(
                            'Your account verified successfully!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 16.ssp,
                                color: Color(0xff011f32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 34.h),
                          CustomButton(
                              pressedFun: () {},
                              buttonText: 'Finish',
                              margin: [0.0, 15.0, 0.0, 0.0],
                              backgroundColor: 0xFF40aa54,
                              foregroundColor: 0xFFFFFFFF,
                              width: 88,
                              fontColor: 0xFFFFFFFF),
                          SizedBox(height: 12.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
