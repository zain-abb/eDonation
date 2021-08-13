import 'package:edonation/src/models/icon_type.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_form_field.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_formfield_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/reset-password';

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

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
              leading: GestureDetector(
                onTap: () => print('Back'),
                child: Icon(
                  Icons.west,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              centerTitle: true,
              title: Text(
                'Add New Password',
                style: GoogleFonts.openSans(
                  textStyle: TextStyle(
                    // ignore: deprecated_member_use
                    fontSize: 15.ssp,
                    color: Color(0xff011f32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              backgroundColor: Colors.white,
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 12.h,
                    ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 12.h,
                            ),
                            Text(
                              'Add New Password',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 28.ssp,
                                  color: Color(0xff011f32),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 34.h,
                            ),
                            CustomFormFieldLabel(hintText: 'New Password'),
                            SizedBox(height: 5.h),
                            CustomFormField(
                              readOnly: false,
                              obscureText: true,
                              hintText: '*******',
                              maxLinesLength: 1,
                              iconType: IconType.Password,
                              controller: newPasswordController,
                              validation: (value) {
                                return Validation.validatePassword(value!);
                              },
                              onSave: (value) {},
                            ),
                            SizedBox(
                              height: 22.h,
                            ),
                            CustomFormFieldLabel(hintText: 'Confirm Password'),
                            SizedBox(height: 5.h),
                            CustomFormField(
                              readOnly: false,
                              obscureText: true,
                              hintText: '*******',
                              maxLinesLength: 1,
                              iconType: IconType.Password,
                              controller: confirmPasswordController,
                              validation: (value) {
                                return Validation.validatePassword(value!);
                              },
                              onSave: (value) {},
                            ),
                            SizedBox(
                              height: 34.h,
                            ),
                            CustomButton(
                                pressedFun: () {},
                                buttonText: 'Done',
                                margin: [0.0, 15.0, 0.0, 0.0],
                                backgroundColor: 0xFF40aa54,
                                foregroundColor: 0xFFFFFFFF,
                                width: 88,
                                fontColor: 0xFFFFFFFF),
                            SizedBox(
                              height: 12.h,
                            ),
                          ],
                        )),
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
