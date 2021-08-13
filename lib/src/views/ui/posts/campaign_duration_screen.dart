import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/posts/campaign_created_screen.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import '../../utils/widgets/custom/custom_icons.dart';
import '../../utils/widgets/custom/custom_tagline.dart';

class CampaignDurationScreen extends StatefulWidget {
  CampaignDurationScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-duration';

  @override
  _CampaignDurationState createState() => _CampaignDurationState();
}

class _CampaignDurationState extends State<CampaignDurationScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String postId = Uuid().v4();

  bool isLoading = false;

  String _campaignDuration = '';

  Map<String, dynamic>? previousData;
  String postType = '';
  String issueType = '';
  String campaignTitle = '';
  String campaignReq = '';
  String campaignDescription = '';
  File image = File('');
  List<double> location = [];
  double target = 0;

  _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      setState(() {
        isLoading = true;
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images')
          .child('post_$postId.jpg');

      await ref.putFile(image);

      final url = await ref.getDownloadURL();

      await postsRef
          .doc(auth.currentUser!.uid)
          .collection('userPosts')
          .doc(postId)
          .set({
        'postId': postId,
        'userId': userCurrent!.id,
        'username': userCurrent!.username,
        'userPhotoUrl': userCurrent!.photoUrl,
        'userLocation': userCurrent!.loc,
        'postType': postType,
        'issueType': issueType,
        'campaignTitle': campaignTitle,
        'campaignReq': campaignReq,
        'campaignDescription': campaignDescription,
        'imageUrl': url,
        'location': GeoPoint(location[0], location[1]),
        'target': target,
        'duration': _campaignDuration,
        'timestamp': FieldValue.serverTimestamp(),
        'raised': 0.0,
      });

      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushNamedAndRemoveUntil(
          CampaignCreatedScreen.routeName, (Route<dynamic> route) => false,
          arguments: {
            'postId': postId,
          });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    previousData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    postType = previousData!['postType'];
    issueType = previousData!['issueType'];
    campaignTitle = previousData!['campaignTitle'];
    campaignReq = previousData!['campaignReq'];
    campaignDescription = previousData!['campaignDescription'];
    image = previousData!['image'];
    location = previousData!['location'];
    target = previousData!['target'];

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
        text: 'Add New Campaign',
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
                        tagLine: 'Duration of the ',
                        vip: 'campaign!',
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
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 12),
                              child: Text(
                                '8/8',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    // ignore: deprecated_member_use
                                    fontSize: 14.ssp,
                                    color: CustomColors.textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                icon: Icon(CustomIcons.close_square),
                                color: CustomColors.iconColor,
                                iconSize: 18,
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      Pager.routeName,
                                      (Route<dynamic> route) => false);
                                })
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 22.w, right: 22.w, top: 0, bottom: 22.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Select the end date of the campaign which is the end time before donation is needed.',
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
                              CustomFormFieldLabel(
                                  hintText: 'Campaign End Date'),
                              SizedBox(height: 5.h),
                              Form(
                                key: _formKey,
                                child: CustomFormField(
                                  keyValue: 'endDate',
                                  obscureText: false,
                                  readOnly: false,
                                  hintText: 'yyyy-MM-dd',
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(48),
                                  ],
                                  iconType: IconType.DateRange,
                                  controller: _textController,
                                  keyboardType: TextInputType.datetime,
                                  validation: (value) {
                                    return Validation.validateDOB(value!);
                                  },
                                  onSave: (value) {
                                    _campaignDuration = value!;
                                  },
                                ),
                              ),
                              SizedBox(height: 34.h),
                              if (isLoading)
                                CustomCircularBar(size: 56, padding: 16),
                              if (!isLoading)
                                CustomButton(
                                  pressedFun: _trySubmit,
                                  buttonText: 'Upload',
                                  margin: [0.0, 15.0, 0.0, 0.0],
                                  backgroundColor: 0xFF40aa54,
                                  foregroundColor: 0xFFFFFFFF,
                                  width: 44,
                                  fontColor: 0xFFFFFFFF,
                                ),
                            ],
                          ),
                        ),
                      ],
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
