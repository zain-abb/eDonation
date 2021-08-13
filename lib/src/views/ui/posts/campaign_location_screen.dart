import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/posts/campaign_target_screen.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
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

class CampaignLocationScreen extends StatefulWidget {
  CampaignLocationScreen({Key? key}) : super(key: key);

  static const routeName = '/campaign-location';

  @override
  _CampaignLocationState createState() => _CampaignLocationState();
}

class _CampaignLocationState extends State<CampaignLocationScreen> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _campaignLocation = '';

  bool _isLoading = false;

  Timer? _throttle;
  late List<String> _placesList = [];
  final List<String> _suggestedList = [
    'Islamabad',
    'Lahore',
    'Gujranwala',
    'Rawalpindi',
    'Faisalabad',
  ];

  var uuid = new Uuid();
  String? _sessionToken;

  String? _heading;

  List<double> campaignLoc = [];

  Map<String, dynamic>? previousData;
  String postType = '';
  String issueType = '';
  String campaignTitle = '';
  String campaignReq = '';
  String campaignDescription = '';
  File image = File('');

  _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState?.save();
      print(_campaignLocation);
      List<Location> locations = await locationFromAddress(_campaignLocation);

      final double lat = locations[0].latitude;
      final double long = locations[0].longitude;

      campaignLoc.add(lat);
      campaignLoc.add(long);

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushNamed(
        CampaignTargetScreen.routeName,
        arguments: {
          'postType': postType,
          'issueType': issueType,
          'campaignTitle': campaignTitle,
          'campaignReq': campaignReq,
          'campaignDescription': campaignDescription,
          'image': image,
          'location': campaignLoc,
        },
      );
    }
  }

  @override
  void initState() {
    _heading = "Suggestions";
    _placesList = _suggestedList;
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_throttle?.isActive ?? false) _throttle!.cancel();
    _throttle = Timer(const Duration(milliseconds: 350), () {
      _sessionToken = uuid.v4();
      getLocationResults(_searchController.text);
    });
  }

  void getLocationResults(String input) async {
    if (input.isEmpty) {
      return;
    }

    const String PLACES_API_KEY = 'YOUR_API';

    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String type = '(regions)';

    String request =
        '$baseURL?input=$input&key=$PLACES_API_KEY&type=$type&sessiontoken=$_sessionToken';
    Response response = await Dio().get(request);

    final predictions = response.data['predictions'];

    List<String> _displayResults = [];

    for (var i = 0; i < predictions.length; i++) {
      String name = predictions[i]['description'];
      _displayResults.add(name);
    }

    setState(() {
      _heading = "Results";
      _placesList = _displayResults;
    });
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
                        tagLine: 'Add campaign ',
                        vip: 'location!',
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
                                '6/8',
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
                                'Enter and select the location of the campaign, so the people can find your campaign.',
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
                              CustomFormFieldLabel(hintText: 'Location'),
                              SizedBox(height: 5.h),
                              Form(
                                key: _formKey,
                                child: CustomFormField(
                                  keyValue: 'loc',
                                  obscureText: false,
                                  readOnly: false,
                                  hintText: '123 Street, ZIP, Country',
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(48),
                                  ],
                                  iconType: IconType.Null,
                                  controller: _searchController,
                                  keyboardType: TextInputType.text,
                                  validation: (value) {
                                    if (!_placesList
                                        .any((item) => item == value))
                                      return 'Please choose option from list';
                                    return Validation.validateLocation(value!);
                                  },
                                  onSave: (value) {
                                    _campaignLocation = value!;
                                  },
                                ),
                              ),
                              SizedBox(height: 16.h),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    color: CustomColors.backgroundColor,
                                  ),
                                  height: 200.h,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 10.h),
                                        Text(
                                          '$_heading',
                                          style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                              // ignore: deprecated_member_use
                                              fontSize: 16.ssp,
                                              color: CustomColors.textColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          physics: BouncingScrollPhysics(),
                                          itemCount: _placesList.length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                Material(
                                                  color: CustomColors
                                                      .backgroundColor,
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _searchController.text =
                                                            _placesList[index];
                                                      });
                                                    },
                                                    child: ListTile(
                                                      title: Text(
                                                        '${_placesList[index]}',
                                                        style: TextStyle(
                                                            // ignore: deprecated_member_use
                                                            fontSize: 14.ssp,
                                                            color: CustomColors
                                                                .textColor),
                                                      ),
                                                      trailing: Icon(
                                                          CupertinoIcons
                                                              .arrow_up_left,
                                                          size: 16),
                                                      enableFeedback: true,
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  height: 1,
                                                  indent: 22.w,
                                                  endIndent: 22.w,
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              if (_isLoading)
                                CustomCircularBar(size: 56, padding: 16),
                              if (!_isLoading)
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
