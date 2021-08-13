import 'package:edonation/src/models/icon_type.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_form_field.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_formfield_label.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  static const routeName = '/change-password';

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController _existingPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  String _existingPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  bool formLoading = false;

  bool checkCurrentPasswordValid = true;

  final _newPasswordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _existingPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<bool> validatePassword(String password) async {
    var firebaseUser = auth.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser!.email!, password: password);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updatePassword(String password) async {
    var firebaseUser = auth.currentUser;
    firebaseUser!.updatePassword(password);
  }

  trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      setState(() {
        formLoading = true;
      });
      checkCurrentPasswordValid = await validatePassword(_existingPassword);
      if (checkCurrentPasswordValid) {
        await updatePassword(_newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Password Changed Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Your current password is incorrect!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() {
        formLoading = false;
      });
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

    return Scaffold(
      appBar: CustomAppBar(
        text: 'Change Password',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12.h),
                CustomFormFieldLabel(hintText: 'Current Password'),
                SizedBox(height: 5.h),
                CustomFormField(
                  readOnly: false,
                  obscureText: true,
                  hintText: '*******',
                  keyValue: 'current',
                  maxLinesLength: 1,
                  iconType: IconType.Password,
                  controller: _existingPasswordController,
                  validation: (value) {
                    return Validation.validatePassword(value!);
                  },
                  onSave: (value) {
                    _existingPassword = value!;
                  },
                  onFieldSubmission: (_) {
                    FocusScope.of(context).requestFocus(_newPasswordFocusNode);
                  },
                ),
                SizedBox(height: 22.h),
                CustomFormFieldLabel(hintText: 'New Password'),
                SizedBox(height: 5.h),
                CustomFormField(
                  readOnly: false,
                  obscureText: true,
                  hintText: '*******',
                  keyValue: 'new',
                  maxLinesLength: 1,
                  iconType: IconType.Password,
                  controller: _newPasswordController,
                  validation: (value) {
                    return Validation.validatePassword(value!);
                  },
                  onSave: (value) {
                    _newPassword = value!;
                  },
                  onFieldSubmission: (_) {
                    FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode);
                  },
                  focusNode: _newPasswordFocusNode,
                ),
                SizedBox(height: 22.h),
                CustomFormFieldLabel(hintText: 'Confirm Password'),
                SizedBox(height: 5.h),
                CustomFormField(
                  readOnly: false,
                  obscureText: true,
                  hintText: '*******',
                  keyValue: 'confirm',
                  maxLinesLength: 1,
                  iconType: IconType.Password,
                  controller: _confirmPasswordController,
                  validation: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Please validate your entered password';
                    }
                    return Validation.validatePassword(value!);
                  },
                  onSave: (value) {
                    _confirmPassword = value!;
                  },
                  focusNode: _confirmPasswordFocusNode,
                ),
                SizedBox(height: 34.h),
                if (formLoading) CustomCircularBar(size: 56, padding: 16),
                if (!formLoading)
                  CustomButton(
                    pressedFun: trySubmit,
                    buttonText: 'Change Password',
                    margin: [0.0, 15.0, 0.0, 0.0],
                    backgroundColor: 0xFF40aa54,
                    foregroundColor: 0xFFFFFFFF,
                    width: 44,
                    fontColor: 0xFFFFFFFF,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
