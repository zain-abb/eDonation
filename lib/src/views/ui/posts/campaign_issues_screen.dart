import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/posts/campaign_title_screen.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_tagline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CampaignIssuesScreen extends StatefulWidget {
  CampaignIssuesScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-issues';

  @override
  _CampaignIssuesScreenState createState() => _CampaignIssuesScreenState();
}

class _CampaignIssuesScreenState extends State<CampaignIssuesScreen> {
  List<IconData> iconList = [
    CupertinoIcons.heart,
    CupertinoIcons.ant,
    CupertinoIcons.sun_haze,
    CupertinoIcons.leaf_arrow_circlepath,
    CupertinoIcons.money_dollar,
    CupertinoIcons.sportscourt,
    CupertinoIcons.pencil_outline,
    CupertinoIcons.star_circle,
    CupertinoIcons.car_detailed,
    CupertinoIcons.desktopcomputer,
    CupertinoIcons.alt,
    CupertinoIcons.ellipsis_vertical,
  ];
  int primaryIndex = 0;

  String postType = '';

  void changeIndex(int index) {
    setState(() {
      primaryIndex = index;
    });
  }

  Widget customRadioButton(IconData icon, int index) {
    return RawMaterialButton(
      onPressed: () => changeIndex(index),
      shape: CircleBorder(),
      padding: EdgeInsets.all(18.0),
      elevation: 1.5,
      fillColor: (primaryIndex == index
          ? CustomColors.primaryColor
          : CustomColors.textFieldBorderColor),
      child: Icon(
        icon,
        color: primaryIndex == index
            ? CustomColors.whiteColor
            : CustomColors.iconColor,
        size: 28.0,
      ),
    );
  }

  Widget customRadioTile(IconData icon, int idx, String text) {
    return Column(
      children: [
        customRadioButton(icon, idx),
        SizedBox(height: 8.h),
        Text(
          '$text',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              // ignore: deprecated_member_use
              fontSize: 15.ssp,
              color: primaryIndex == idx
                  ? CustomColors.primaryColor
                  : CustomColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _issueType(int idx) {
    String issueType = '';
    switch (idx) {
      case 0:
        issueType = 'Health';
        break;
      case 1:
        issueType = 'Animal';
        break;
      case 2:
        issueType = 'Nature';
        break;
      case 3:
        issueType = 'Food';
        break;
      case 4:
        issueType = 'Charity';
        break;
      case 5:
        issueType = 'Sports';
        break;
      case 6:
        issueType = 'Education';
        break;
      case 7:
        issueType = 'Rights';
        break;
      case 8:
        issueType = 'Trips';
        break;
      case 9:
        issueType = 'Tech';
        break;
      case 10:
        issueType = 'Disability';
        break;
      case 11:
        issueType = 'Other';
        break;
      default:
        issueType = 'Unkown';
    }
    return issueType;
  }

  @override
  Widget build(BuildContext context) {
    postType = ModalRoute.of(context)!.settings.arguments as String;

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
                        tagLine: 'What kind of issues are you ',
                        vip: 'campaigning on?',
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
                                '1/8',
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  customRadioTile(iconList[0], 0, 'Health'),
                                  customRadioTile(iconList[1], 1, 'Animal'),
                                  customRadioTile(iconList[2], 2, 'Nature'),
                                ],
                              ),
                              SizedBox(height: 22.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  customRadioTile(iconList[3], 3, 'Food'),
                                  customRadioTile(iconList[4], 4, 'Charity'),
                                  customRadioTile(iconList[5], 5, 'Sports'),
                                ],
                              ),
                              SizedBox(height: 22.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  customRadioTile(iconList[6], 6, 'Education'),
                                  customRadioTile(iconList[7], 7, 'Rights'),
                                  customRadioTile(iconList[8], 8, 'Trips'),
                                ],
                              ),
                              SizedBox(height: 22.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  customRadioTile(iconList[9], 9, 'Technology'),
                                  customRadioTile(
                                      iconList[10], 10, 'Disability'),
                                  customRadioTile(iconList[11], 11, 'Other'),
                                ],
                              ),
                              SizedBox(height: 34.h),
                              CustomButton(
                                pressedFun: () {
                                  String issueType = _issueType(primaryIndex);
                                  Navigator.of(context).pushNamed(
                                    CampaignTitleScreen.routeName,
                                    arguments: {
                                      'postType': postType,
                                      'issueType': issueType,
                                    },
                                  );
                                },
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
