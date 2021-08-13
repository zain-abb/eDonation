import 'dart:io';

import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/posts/campaign_duration_screen.dart';
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

class CampaignTargetScreen extends StatefulWidget {
  CampaignTargetScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-target';

  @override
  _CampaignTargetState createState() => _CampaignTargetState();
}

class _CampaignTargetState extends State<CampaignTargetScreen> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _campaignTarget = '';
  double target = 0;

  Map<String, dynamic>? previousData;
  String postType = '';
  String issueType = '';
  String campaignTitle = '';
  String campaignReq = '';
  String campaignDescription = '';
  File image = File('');
  List<double> location = [];

  _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      print(_campaignTarget);
      Navigator.of(context).pushNamed(
        CampaignDurationScreen.routeName,
        arguments: {
          'postType': postType,
          'issueType': issueType,
          'campaignTitle': campaignTitle,
          'campaignReq': campaignReq,
          'campaignDescription': campaignDescription,
          'image': image,
          'location': location,
          'target': target,
        },
      );
    }
  }

  int? _selectedIndex;
  List<String> _options = ['1500', '2000', '2500', '3000'];
  Color selectedColor = CustomColors.primaryColor;

  Widget _buildChips() {
    List<Widget> chips = [];

    for (int i = 0; i < _options.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,
        label:
            Text(_options[i], style: TextStyle(color: CustomColors.whiteColor)),
        elevation: 1,
        pressElevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        backgroundColor: CustomColors.textFieldBorderColor,
        selectedColor: CustomColors.primaryColor,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
              _textController.text = _options[_selectedIndex!];
            }
          });
        },
      );

      chips.add(choiceChip);
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: chips,
      ),
    );
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
                        tagLine: 'Add ',
                        vip: 'target!',
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
                                '6/7',
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
                                'Select the amount with which you want to make a difference.',
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
                                  hintText: 'Select amount / quantity'),
                              SizedBox(height: 5.h),
                              Form(
                                key: _formKey,
                                child: CustomFormField(
                                  keyValue: 'amount',
                                  obscureText: false,
                                  readOnly: false,
                                  hintText: 'Other...',
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(7),
                                  ],
                                  iconType: IconType.Null,
                                  controller: _textController,
                                  keyboardType: TextInputType.number,
                                  validation: (value) {
                                    try {
                                      target = double.parse(value!);
                                    } catch (error) {
                                      return 'Please enter a valid target value!';
                                    }
                                    return value.length < 2
                                        ? 'Please enter a reasonable amount / quantity!'
                                        : null;
                                  },
                                  onSave: (value) {
                                    _campaignTarget = value!;
                                  },
                                  onChange: (value) {
                                    if (value == _options[0]) {
                                      setState(() {
                                        _selectedIndex = 0;
                                      });
                                    } else if (value == _options[1]) {
                                      setState(() {
                                        _selectedIndex = 1;
                                      });
                                    } else if (value == _options[2]) {
                                      setState(() {
                                        _selectedIndex = 2;
                                      });
                                    } else if (value == _options[3]) {
                                      setState(() {
                                        _selectedIndex = 3;
                                      });
                                    } else {
                                      setState(() {
                                        _selectedIndex = null;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(height: 8.h),
                              _buildChips(),
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
