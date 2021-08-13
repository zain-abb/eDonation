import 'package:edonation/src/models/icon_type.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_form_field.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_formfield_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  static const routeName = '/forgot-password';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String userEmail = '';

  trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      try {
        await auth.sendPasswordResetEmail(email: userEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('A password reset link has been sent to $userEmail'),
            backgroundColor: Colors.amber,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('There is no account against this $userEmail!'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
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

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(392.75, 856.75),
        orientation: Orientation.portrait);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        text: 'Forgot Password',
        backButton: true,
      ),
      backgroundColor: CustomColors.backgroundColor,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 12.h,
                    ),
                    Text(
                      'Reset Password',
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
                      height: 5.h,
                    ),
                    Text(
                      'Please enter you registered email. We will send a link to your registered email to reset your password',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                          // ignore: deprecated_member_use
                          fontSize: 16.ssp,
                          color: Color(0xff011f32),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 56.h,
                    ),
                    CustomFormFieldLabel(hintText: 'Email Address'),
                    SizedBox(height: 5.h),
                    Form(
                      key: _formKey,
                      child: CustomFormField(
                        keyValue: 'email',
                        obscureText: false,
                        readOnly: false,
                        hintText: 'someone@domain.com',
                        iconType: IconType.Null,
                        controller: passwordController,
                        keyboardType: TextInputType.emailAddress,
                        validation: (value) {
                          return Validation.validateEmail(value!);
                        },
                        onSave: (value) {
                          userEmail = value!;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 34.h,
                    ),
                    CustomButton(
                        pressedFun: trySubmit,
                        buttonText: 'Send me link',
                        margin: [0.0, 15.0, 0.0, 0.0],
                        backgroundColor: 0xFF40aa54,
                        foregroundColor: 0xFFFFFFFF,
                        width: 88,
                        fontColor: 0xFFFFFFFF),
                    SizedBox(
                      height: 12.h,
                    ),
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
