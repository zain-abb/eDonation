import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/donors.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/views/ui/donations/donation_second_step.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../models/icon_type.dart';
import '../../utils/widgets/custom/custom_app_bar.dart';
import '../../utils/widgets/custom/custom_buttons.dart';
import '../../utils/widgets/custom/custom_colors.dart';
import '../../utils/widgets/custom/custom_form_field.dart';
import '../../utils/widgets/custom/custom_formfield_label.dart';
import '../../utils/widgets/custom/custom_tagline.dart';

class DonationFirstStep extends StatefulWidget {
  DonationFirstStep(this.post, {Key? key}) : super(key: key);

  static const routeName = '/donation-first-step';

  final Posts post;

  @override
  _DonationFirstStepState createState() => _DonationFirstStepState();
}

class _DonationFirstStepState extends State<DonationFirstStep> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String donationId = Uuid().v4();

  String _donationDescription = '';
  String _donationAmount = '';

  _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      double donation = double.parse(_donationAmount);
      Navigator.of(context).pushNamed(
        DonationSecondStep.routeName,
        arguments: DonationSecondStepArguments(
            Donors(
              donorId: donationId,
              username: userCurrent!.username,
              userId: userCurrent!.id,
              userPhotoUrl: userCurrent!.photoUrl,
              postId: widget.post.postId,
              donation: donation,
              description: _donationDescription,
              timestamp: Timestamp.now(),
              status: 'pending',
            ),
            widget.post.userId),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
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
        text: 'Donate',
        backButton: true,
      ),
      body: Container(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height,
        color: CustomColors.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
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
                        tagLine:
                            'You\'re 2 steps away from bringing smile on someone\'s ',
                        vip: 'Face!',
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: CustomColors.whiteColor,
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Please enter the quantity or amount you want to donate and describe the donation as well.',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 15.ssp,
                                color: CustomColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 34.h),
                          CustomFormFieldLabel(hintText: 'Amount / Quantity'),
                          SizedBox(height: 5.h),
                          CustomFormField(
                            keyValue: 'amount',
                            obscureText: false,
                            readOnly: false,
                            hintText: 'Enter amount or quantity...',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(5),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                            iconType: IconType.Null,
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            validation: (value) {
                              return value! == '0'
                                  ? 'Please enter some amount or quantity'
                                  : null;
                            },
                            onSave: (value) {
                              _donationAmount = value!;
                            },
                          ),
                          SizedBox(height: 22.h),
                          CustomFormFieldLabel(hintText: 'Description'),
                          SizedBox(height: 5.h),
                          CustomFormField(
                            keyValue: 'description',
                            obscureText: false,
                            readOnly: false,
                            hintText: 'Explain your donation...',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(256),
                            ],
                            iconType: IconType.Null,
                            maxLinesLength: 5,
                            controller: _descController,
                            keyboardType: TextInputType.multiline,
                            validation: (value) {
                              var regExp = new RegExp(r"[\w-]+");
                              int wordscount = regExp.allMatches(value!).length;
                              if (wordscount < 8) {
                                return 'Please enter at least 8 words...';
                              }
                            },
                            onSave: (value) {
                              _donationDescription = value!;
                            },
                          ),
                          SizedBox(height: 5),
                          Container(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Min 8 Words',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  // ignore: deprecated_member_use
                                  fontSize: 12.ssp,
                                  color: CustomColors.textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 34.h),
                          CustomButton(
                            pressedFun: _trySubmit,
                            buttonText: 'Next',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
