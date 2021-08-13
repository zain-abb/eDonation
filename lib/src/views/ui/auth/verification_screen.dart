import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  static const routeName = '/verification';

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
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
                      alignment: Alignment.topLeft,
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 12.h,
                          ),
                          Text(
                            'Enter 4-Digit Code',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 22.ssp,
                                color: Color(0xff011f32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            width: 200.h,
                            height: 200.h,
                            child: Image.asset(
                                'assets/images/verification_code.png'),
                          ),
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            onChanged: (value) {},
                            onCompleted: (value) {},
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderWidth: 1,
                              fieldHeight: 45.h,
                              fieldWidth: 45.w,
                              inactiveColor: Color(0xffcfcfcf),
                              activeColor: Color(0xffcfcfcf),
                              selectedColor: Color(0xFF40aa54),
                            ),
                          ),
                          SizedBox(
                            height: 34.h,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                print('Login!');
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Didn\'t receive code? '.toUpperCase(),
                                  style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                      // ignore: deprecated_member_use
                                      fontSize: 12.ssp,
                                      color: Color(0xff595959),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Resend'.toUpperCase(),
                                        style: TextStyle(
                                            color: Color(0xFF40aa54))),
                                  ],
                                ),
                              ),
                            ),
                          ),
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
