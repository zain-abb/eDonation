import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:edonation/src/views/utils/widgets/picker/profile_pic_viewer.dart';
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

class SubmitReview extends StatefulWidget {
  SubmitReview(this.post, {Key? key}) : super(key: key);

  static const routeName = '/submit-review';

  final Posts post;

  @override
  _SubmitReviewState createState() => _SubmitReviewState();
}

class _SubmitReviewState extends State<SubmitReview> {
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double rating = 0;
  double halfRating = 0.5;

  String _review = '';
  String reviewId = Uuid().v4();

  bool isLoading = false;

  _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      setState(() {
        isLoading = true;
      });

      await reviewsRef
          .doc(widget.post.postId)
          .collection('reviews')
          .doc(reviewId)
          .set({
        'postId': widget.post.postId,
        'rating': rating,
        'review': _review,
        'reviewId': reviewId,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userCurrent!.id,
        'username': userCurrent!.username,
        'userPhotoUrl': userCurrent!.photoUrl
      });

      if (!(userCurrent!.id == widget.post.userId))
        await feedRef.doc(widget.post.userId).collection('feedItems').add({
          'activityType': 'review',
          'username': userCurrent!.username,
          'userId': userCurrent!.id,
          'userImageUrl': userCurrent!.photoUrl,
          'postMediaUrl': widget.post.imageUrl,
          'postId': widget.post.postId,
          'number': rating,
          'description': _review,
          'id': reviewId,
          'timestamp': FieldValue.serverTimestamp(),
        });

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
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
        text: 'Submit Review',
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
                          ProfilePicViewer(
                            size: 46,
                            url: userCurrent!.photoUrl,
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            userCurrent!.username,
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 18.ssp,
                                color: CustomColors.headingColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 22.h),
                          Text(
                            'How would you rate the campaign?',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 18.ssp,
                                color: CustomColors.headingColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rating = 1.0;
                                  });
                                },
                                child: Icon(
                                  CupertinoIcons.star_fill,
                                  size: 28,
                                  color: rating >= 1.0
                                      ? Colors.amber
                                      : CustomColors.backgroundColor,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rating = 2.0;
                                  });
                                },
                                onDoubleTap: () {
                                  setState(() {
                                    rating = 1.5;
                                  });
                                },
                                child: Icon(
                                  rating == 1.5
                                      ? CupertinoIcons.star_lefthalf_fill
                                      : CupertinoIcons.star_fill,
                                  size: 28,
                                  color: rating >= 1.5
                                      ? Colors.amber
                                      : CustomColors.backgroundColor,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rating = 3.0;
                                  });
                                },
                                onDoubleTap: () {
                                  setState(() {
                                    rating = 2.5;
                                  });
                                },
                                child: Icon(
                                  rating == 2.5
                                      ? CupertinoIcons.star_lefthalf_fill
                                      : CupertinoIcons.star_fill,
                                  size: 28,
                                  color: rating >= 2.5
                                      ? Colors.amber
                                      : CustomColors.backgroundColor,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rating = 4.0;
                                  });
                                },
                                onDoubleTap: () {
                                  setState(() {
                                    rating = 3.5;
                                  });
                                },
                                child: Icon(
                                  rating == 3.5
                                      ? CupertinoIcons.star_lefthalf_fill
                                      : CupertinoIcons.star_fill,
                                  size: 28,
                                  color: rating >= 3.5
                                      ? Colors.amber
                                      : CustomColors.backgroundColor,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    rating = 5.0;
                                  });
                                },
                                onDoubleTap: () {
                                  setState(() {
                                    rating = 4.5;
                                  });
                                },
                                child: Icon(
                                  rating == 4.5
                                      ? CupertinoIcons.star_lefthalf_fill
                                      : CupertinoIcons.star_fill,
                                  size: 28,
                                  color: rating >= 4.5
                                      ? Colors.amber
                                      : CustomColors.backgroundColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 34.h),
                          CustomFormFieldLabel(
                              hintText: 'Leave your valueable comments'),
                          SizedBox(height: 5.h),
                          CustomFormField(
                            keyValue: 'comments',
                            obscureText: false,
                            readOnly: false,
                            hintText: 'Reviews about the campaign...',
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
                              _review = value!;
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
                          if (isLoading)
                            CustomCircularBar(size: 56, padding: 16),
                          if (!isLoading)
                            CustomButton(
                              pressedFun: _trySubmit,
                              buttonText: 'Submit',
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
