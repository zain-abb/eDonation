import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUs extends StatelessWidget {
  const ContactUs({Key? key}) : super(key: key);

  static const routeName = '/contact-us';

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
        text: 'Contact Us',
        backButton: true,
      ),
      backgroundColor: CustomColors.backgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Row(
              children: [
                Container(
                  width: 60.h,
                  height: 60.h,
                  child: Icon(
                    Icons.phone_outlined,
                    size: 30.h,
                    color: CustomColors.primaryColor,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomColors.primaryFadeColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  children: [
                    Text(
                      '+92 344 6852373',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 15.ssp,
                          color: CustomColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '+92 324 8448636',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 15.ssp,
                          color: CustomColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Container(
                  width: 60.h,
                  height: 60.h,
                  child: Icon(
                    Icons.mail_outline_rounded,
                    size: 30.h,
                    color: CustomColors.primaryColor,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomColors.primaryFadeColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'e.donation.app.0@gmail.com',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 15.ssp,
                      color: CustomColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            Row(
              children: [
                Container(
                  width: 60.h,
                  height: 60.h,
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 30.h,
                    color: CustomColors.primaryColor,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomColors.primaryFadeColor,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'University of Engineering and \nTechnology, Taxila - 47050',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      // ignore: deprecated_member_use
                      fontSize: 15.ssp,
                      color: CustomColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
