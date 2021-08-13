import 'dart:io';

import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/posts/campaign_location_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/widgets/custom/custom_app_bar.dart';
import '../../utils/widgets/custom/custom_buttons.dart';
import '../../utils/widgets/custom/custom_colors.dart';
import '../../utils/widgets/custom/custom_formfield_label.dart';
import '../../utils/widgets/custom/custom_icons.dart';
import '../../utils/widgets/custom/custom_tagline.dart';

class CampaignImageScreen extends StatefulWidget {
  CampaignImageScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-image';

  @override
  _CampaignImageState createState() => _CampaignImageState();
}

class _CampaignImageState extends State<CampaignImageScreen> {
  File? imageFile;

  Map<String, dynamic>? previousData;
  String postType = '';
  String issueType = '';
  String campaignTitle = '';
  String campaignReq = '';
  String campaignDescription = '';

  bool _validateImage() {
    if (imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: CustomColors.errorColor,
        ),
      );
      return false;
    }
    return true;
  }

  _trySubmit() {
    if (!_validateImage()) {
      return;
    }
    print('image');
    Navigator.of(context).pushNamed(
      CampaignLocationScreen.routeName,
      arguments: {
        'postType': postType,
        'issueType': issueType,
        'campaignTitle': campaignTitle,
        'campaignReq': campaignReq,
        'campaignDescription': campaignDescription,
        'image': imageFile,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    previousData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    postType = previousData!['postType'];
    issueType = previousData!['issueType'];
    campaignTitle = previousData!['campaignTitle'];
    campaignDescription = previousData!['campaignDescription'];
    campaignReq = previousData!['campaignReq'];

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
                        tagLine: 'Add a ',
                        vip: 'photo!',
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
                                '5/8',
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
                                'Campaigns with a photo receive six times more people attraction than those without. Include one that captures the emotion of your story.',
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
                              CustomFormFieldLabel(hintText: 'Image'),
                              SizedBox(height: 5.h),
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    child: Container(
                                      width: 300.w,
                                      height: 200.h,
                                      decoration: imageFile != null
                                          ? BoxDecoration(
                                              border: Border.all(
                                                color: CustomColors
                                                    .textFieldBorderColor,
                                                width: 0.5,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              image: DecorationImage(
                                                  image: FileImage(imageFile!),
                                                  fit: BoxFit.cover),
                                            )
                                          : BoxDecoration(
                                              border: Border.all(
                                                color: CustomColors
                                                    .textFieldBorderColor,
                                                width: 0.5,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/images/image_placeholder.png'),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    margin: EdgeInsets.all(16),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: CustomColors.whiteColor,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.10),
                                          spreadRadius: 2,
                                          offset: Offset(0, 1),
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Material(
                                        color: Colors.transparent,
                                        clipBehavior: Clip.hardEdge,
                                        shape: CircleBorder(),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            CustomIcons.camera,
                                            color: CustomColors.primaryColor,
                                            size: 24,
                                          ),
                                          onPressed: _imagePick,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
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

  _imagePick() async {
    try {
      FocusScope.of(context).unfocus();
      final picker = ImagePicker();
      PickedFile? pickedImage;

      pickedImage = await picker.getImage(
          source: ImageSource.gallery, imageQuality: 75, maxWidth: 1024);

      setState(() {
        imageFile = File(pickedImage!.path);
      });
    } catch (err) {
      print('Select Image');
    }
  }
}
