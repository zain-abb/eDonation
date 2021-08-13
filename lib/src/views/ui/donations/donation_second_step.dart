import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/addresses.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/models/donors.dart';
import 'package:edonation/src/models/posts.dart';
import 'package:edonation/src/views/ui/donations/thank_you.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/settings/addresses/add_new_address.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
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

class DonationSecondStep extends StatefulWidget {
  DonationSecondStep(this.donation, this.postUserId, {Key? key})
      : super(key: key);

  static const routeName = '/donation-second-step';

  final Donors donation;
  final String postUserId;

  @override
  _DonationSecondStepState createState() => _DonationSecondStepState();
}

class _DonationSecondStepState extends State<DonationSecondStep> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool formLoading = false;

  String _donationPickUpDate = '';
  String _donationPickUpTime = '';

  int _groupValue = -1;
  bool _isChecked = false;

  String recordId = Uuid().v4();

  bool validateAddress() {
    if (_groupValue == -1 && !_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select address or drop off method!'),
          backgroundColor: CustomColors.errorColor,
        ),
      );
      return false;
    }
    return true;
  }

  Addresses? selectedAddress;

  _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (!validateAddress()) return;

    if (isValid) {
      _formKey.currentState?.save();

      String scheduleType = 'pickup';
      if (_isChecked) scheduleType = 'dropoff';

      setState(() {
        formLoading = true;
      });
      DocumentSnapshot getPost = await postsRef
          .doc(widget.postUserId)
          .collection('userPosts')
          .doc(widget.donation.postId)
          .get();

      Posts callBackPost = Posts.fromDocument(getPost);

      await donorsRef
          .doc(widget.donation.postId)
          .collection('donor')
          .doc(widget.donation.donorId)
          .set({
        'description': widget.donation.description,
        'donation': widget.donation.donation,
        'donorId': widget.donation.donorId,
        'postId': widget.donation.postId,
        'timestamp': widget.donation.timestamp,
        'userId': widget.donation.userId,
        'username': widget.donation.username,
        'userPohotUrl': widget.donation.userPhotoUrl,
        'status': widget.donation.status,
      });

      await donationScheduleRef
          .doc(userCurrent!.id)
          .collection('schedule')
          .doc(widget.donation.donorId)
          .set({
        'addressId':
            scheduleType != 'dropoff' ? selectedAddress!.addressId : ' ',
        'userId': userCurrent!.id,
        'postId': widget.donation.postId,
        'donorId': widget.donation.donorId,
        'scheduleType': scheduleType,
        'scheduleTime': _donationPickUpTime,
        'scheduleDate': _donationPickUpDate,
        'status': 'pending',
      });

      if (!(userCurrent!.id == widget.postUserId))
        await feedRef.doc(widget.postUserId).collection('feedItems').add({
          'activityType': 'donation',
          'username': userCurrent!.username,
          'userId': userCurrent!.id,
          'userImageUrl': userCurrent!.photoUrl,
          'postMediaUrl': getPost['imageUrl'],
          'postId': widget.donation.postId,
          'number': widget.donation.donation,
          'description': widget.donation.description,
          'id': widget.donation.donorId,
          'timestamp': FieldValue.serverTimestamp(),
        });

      await donationRecordRef
          .doc(userCurrent!.id)
          .collection('record')
          .doc(widget.donation.donorId)
          .set({
        'postId': widget.donation.postId,
        'postUserId': widget.postUserId,
        'donorId': widget.donation.donorId,
        'campaignTitle': callBackPost.campaignTitle,
        'timestamp': FieldValue.serverTimestamp(),
        'description': widget.donation.description,
        'donation': widget.donation.donation,
        'status': widget.donation.status,
        'addressId':
            scheduleType != 'dropoff' ? selectedAddress!.addressId : ' ',
        'scheduleType': scheduleType,
        'scheduleTime': _donationPickUpTime,
        'scheduleDate': _donationPickUpDate,
      });

      setState(() {
        formLoading = false;
      });
      Navigator.of(context).pushNamed(ThankYou.routeName,
          arguments: ThankYouArguments(callBackPost));
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
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
                        tagLine: 'You\'re spreading ',
                        vip: 'Happiness!',
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
                            'Schedule Pick-Up',
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 18.ssp,
                                color: CustomColors.headingColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(height: 22.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomFormFieldLabel(hintText: 'Date'),
                                    CustomFormField(
                                      keyValue: 'date',
                                      obscureText: false,
                                      readOnly: false,
                                      hintText: 'yyyy-MM-dd',
                                      maxLinesLength: 1,
                                      iconType: IconType.DateRange,
                                      controller: _dateController,
                                      keyboardType: TextInputType.datetime,
                                      validation: (value) {
                                        return Validation.validateDOB(value!);
                                      },
                                      onSave: (value) {
                                        _donationPickUpDate = value!;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomFormFieldLabel(
                                        hintText: 'Time (24 Hrs)'),
                                    CustomFormField(
                                      keyValue: 'time',
                                      obscureText: false,
                                      readOnly: false,
                                      hintText: '00:00',
                                      maxLinesLength: 1,
                                      iconType: IconType.Time,
                                      controller: _timeController,
                                      keyboardType: TextInputType.datetime,
                                      validation: (value) {
                                        return Validation.validateTime(value!);
                                      },
                                      onSave: (value) {
                                        _donationPickUpTime = value!;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 22.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Address',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                    // ignore: deprecated_member_use
                                    fontSize: 16.ssp,
                                    color: CustomColors.headingColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(AddNewAddress.routeName);
                                },
                                child: Text('Add New'),
                                style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.zero),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          CustomColors.primaryColor),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5.h),
                          Container(
                            height: 175.h,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: addressesRef
                                  .doc(userCurrent!.id)
                                  .collection('address')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: CustomCircularBar(
                                        size: 75, padding: 22),
                                  );
                                }
                                if (snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/no_posts.png',
                                          height: 100,
                                          width: 100,
                                        ),
                                        // SizedBox(height: 22.h),
                                        Text(
                                          'No Addresses, please add new!'
                                              .toUpperCase(),
                                          style: GoogleFonts.openSans(
                                            textStyle: TextStyle(
                                              // ignore: deprecated_member_use
                                              fontSize: 14.ssp,
                                              color: CustomColors.textColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      Addresses addresses =
                                          Addresses.fromDocument(
                                              snapshot.data!.docs[index]);
                                      return _myRadioButton(
                                        title: addresses.title,
                                        phoneNumber: addresses.phoneNumber,
                                        address:
                                            '${addresses.addressLineOne} ${addresses.addressLineTwo} ${addresses.city} ${addresses.state}-${addresses.zipCode}',
                                        value: index,
                                        onChanged: (newValue) => setState(() {
                                          _groupValue = newValue as int;
                                          selectedAddress = addresses;
                                        }),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          CheckboxListTile(
                            title: Text('I will drop off'),
                            value: _isChecked,
                            onChanged: (val) {
                              setState(() {
                                _isChecked = val!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            activeColor: CustomColors.primaryColor,
                          ),
                          SizedBox(height: 22.h),
                          if (formLoading)
                            CustomCircularBar(size: 56, padding: 16),
                          if (!formLoading)
                            CustomButton(
                              pressedFun: _trySubmit,
                              buttonText: 'Donate',
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

  Widget _myRadioButton(
      {required String title,
      required String phoneNumber,
      required String address,
      required int value,
      required Function(Object?)? onChanged}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: _groupValue == value && !_isChecked
            ? CustomColors.primaryFadeColor
            : CustomColors.backgroundColor,
        border: Border.all(
          color: _groupValue == value && !_isChecked
              ? CustomColors.primaryColor
              : CustomColors.backgroundColor,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      margin: EdgeInsets.only(bottom: 8.h),
      child: RadioListTile(
        value: value,
        groupValue: _groupValue,
        activeColor: CustomColors.primaryColor,
        contentPadding: EdgeInsets.zero,
        selectedTileColor: CustomColors.primaryFadeColor,
        title: Text(
          title,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              // ignore: deprecated_member_use
              fontSize: 16.ssp,
              color: CustomColors.headingColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        subtitle: Text(
          '$phoneNumber\n$address',
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              // ignore: deprecated_member_use
              fontSize: 14.ssp,
              color: CustomColors.textColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onChanged: _isChecked ? null : onChanged,
      ),
    );
  }
}
