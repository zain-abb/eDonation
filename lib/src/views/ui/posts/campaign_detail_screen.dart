import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/posts/campaign_image_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/icon_type.dart';
import '../../utils/widgets/custom/custom_app_bar.dart';
import '../../utils/widgets/custom/custom_buttons.dart';
import '../../utils/widgets/custom/custom_colors.dart';
import '../../utils/widgets/custom/custom_form_field.dart';
import '../../utils/widgets/custom/custom_formfield_label.dart';
import '../../utils/widgets/custom/custom_icons.dart';
import '../../utils/widgets/custom/custom_tagline.dart';

class CampaignDetailScreen extends StatefulWidget {
  CampaignDetailScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-detail';

  @override
  _CampaignDetailState createState() => _CampaignDetailState();
}

class _CampaignDetailState extends State<CampaignDetailScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _campaignDescription = '';

  Map<String, dynamic>? previousData;
  String postType = '';
  String issueType = '';
  String campaignTitle = '';
  String campaignReq = '';

  _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      print(_campaignDescription);
      Navigator.of(context).pushNamed(
        CampaignImageScreen.routeName,
        arguments: {
          'postType': postType,
          'issueType': issueType,
          'campaignTitle': campaignTitle,
          'campaignReq': campaignReq,
          'campaignDescription': _campaignDescription,
        },
      );
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
                        tagLine: 'Explain the problem you want to ',
                        vip: 'solve!',
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
                                '4/8',
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
                                'People more likely to support your campaign if it\'s clear why you care. ' +
                                    'Explain how this change will impact you, your family, or your community. ' +
                                    'Please include contact details as well, so people can reach out you!',
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
                              CustomFormFieldLabel(hintText: 'Description'),
                              SizedBox(height: 5.h),
                              Form(
                                key: _formKey,
                                child: CustomFormField(
                                  keyValue: 'description',
                                  obscureText: false,
                                  readOnly: false,
                                  hintText: 'Explain your problem...',
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(512),
                                  ],
                                  iconType: IconType.Null,
                                  maxLinesLength: 10,
                                  controller: _textController,
                                  keyboardType: TextInputType.multiline,
                                  validation: (value) {
                                    var regExp = new RegExp(r"[\w-]+");
                                    int wordscount =
                                        regExp.allMatches(value!).length;
                                    if (wordscount < 32) {
                                      return 'Please enter at least 32 words...';
                                    }
                                  },
                                  onSave: (value) {
                                    _campaignDescription = value!;
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Min 32 Words',
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
