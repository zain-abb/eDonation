import 'package:edonation/src/models/icon_type.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/utils/validations.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_buttons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_form_field.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_formfield_label.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class AddNewAddress extends StatefulWidget {
  AddNewAddress({Key? key}) : super(key: key);

  static const routeName = '/add-new-address';

  @override
  _AddNewAddressState createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  String addressId = Uuid().v4();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  String addressTitle = '';

  TextEditingController _phoneController = TextEditingController();
  String addressPhone = '';

  TextEditingController _addressLine1Controller = TextEditingController();
  String addressLine1 = '';

  TextEditingController _addressLine2Controller = TextEditingController();
  String addressLine2 = '';

  TextEditingController _cityController = TextEditingController();
  String addressCity = '';

  TextEditingController _stateController = TextEditingController();
  String addressState = '';

  TextEditingController _zipController = TextEditingController();
  String addressZip = '';

  final phoneFocusNode = FocusNode();
  final addressLine1FocusNode = FocusNode();
  final addressLine2FocusNode = FocusNode();
  final cityFocusNode = FocusNode();
  final stateFocusNode = FocusNode();
  final zipFocusNode = FocusNode();

  bool formLoading = false;

  trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState?.save();
      setState(() {
        formLoading = true;
      });
      addressesRef
          .doc(userCurrent!.id)
          .collection('address')
          .doc(addressId)
          .set({
        'addressId': addressId,
        'addressLineOne': addressLine1,
        'addressLineTwo': addressLine2,
        'city': addressCity,
        'phoneNumber': addressPhone,
        'state': addressState,
        'title': addressTitle,
        'zipCode': addressZip
      });
      setState(() {
        formLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _titleController.dispose();
    zipFocusNode.dispose();
    stateFocusNode.dispose();
    cityFocusNode.dispose();
    addressLine2FocusNode.dispose();
    addressLine1FocusNode.dispose();
    phoneFocusNode.dispose();
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
        backButton: true,
        text: 'Add New Address',
      ),
      backgroundColor: CustomColors.backgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        // padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomFormFieldLabel(hintText: 'Title'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    keyValue: 'title',
                    obscureText: false,
                    readOnly: false,
                    hintText: 'e.g. Home Address',
                    iconType: IconType.Null,
                    controller: _titleController,
                    keyboardType: TextInputType.emailAddress,
                    validation: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter the title for your address';
                      }
                    },
                    onSave: (value) {
                      addressTitle = value!;
                    },
                    onFieldSubmission: (_) {
                      FocusScope.of(context).requestFocus(phoneFocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Phone Number'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    readOnly: false,
                    obscureText: false,
                    hintText: '03XX XXXXXXX',
                    keyValue: 'phone',
                    keyboardType: TextInputType.phone,
                    maxLinesLength: 1,
                    iconType: IconType.Null,
                    controller: _phoneController,
                    validation: (value) {
                      return Validation.validatePhone(value!);
                    },
                    onSave: (value) {
                      addressPhone = value!;
                    },
                    focusNode: phoneFocusNode,
                    onFieldSubmission: (_) {
                      FocusScope.of(context)
                          .requestFocus(addressLine1FocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Address Line 1'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    readOnly: false,
                    obscureText: false,
                    hintText: 'Address...',
                    keyValue: 'line1',
                    keyboardType: TextInputType.streetAddress,
                    maxLinesLength: 1,
                    iconType: IconType.Null,
                    controller: _addressLine1Controller,
                    validation: (value) {
                      return Validation.validateAddress(value!);
                    },
                    onSave: (value) {
                      addressLine1 = value!;
                    },
                    focusNode: addressLine1FocusNode,
                    onFieldSubmission: (_) {
                      FocusScope.of(context)
                          .requestFocus(addressLine2FocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Address Line 2'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    readOnly: false,
                    obscureText: false,
                    hintText: 'Address...',
                    keyValue: 'line2',
                    keyboardType: TextInputType.streetAddress,
                    maxLinesLength: 1,
                    iconType: IconType.Null,
                    controller: _addressLine2Controller,
                    onSave: (value) {
                      addressLine2 = value!;
                    },
                    focusNode: addressLine2FocusNode,
                    onFieldSubmission: (_) {
                      FocusScope.of(context).requestFocus(cityFocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'City'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    readOnly: false,
                    obscureText: false,
                    hintText: 'e.g. Islamabad',
                    keyValue: 'line1',
                    maxLinesLength: 1,
                    iconType: IconType.Null,
                    controller: _cityController,
                    validation: (value) {
                      return Validation.validateCity(value!);
                    },
                    onSave: (value) {
                      addressCity = value!;
                    },
                    focusNode: cityFocusNode,
                    onFieldSubmission: (_) {
                      FocusScope.of(context).requestFocus(stateFocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CustomFormFieldLabel(hintText: 'State'),
                            SizedBox(height: 5.h),
                            CustomFormField(
                              readOnly: false,
                              obscureText: false,
                              hintText: 'e.g. Punjab',
                              keyValue: 'state',
                              maxLinesLength: 1,
                              iconType: IconType.Null,
                              controller: _stateController,
                              validation: (value) {
                                return Validation.validateCity(value!);
                              },
                              onSave: (value) {
                                addressState = value!;
                              },
                              focusNode: stateFocusNode,
                              onFieldSubmission: (_) {
                                FocusScope.of(context)
                                    .requestFocus(zipFocusNode);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          children: [
                            CustomFormFieldLabel(hintText: 'Zip Code'),
                            SizedBox(height: 5.h),
                            CustomFormField(
                              readOnly: false,
                              obscureText: false,
                              hintText: 'XXXXX',
                              keyValue: 'zip',
                              maxLinesLength: 1,
                              iconType: IconType.Null,
                              controller: _zipController,
                              keyboardType: TextInputType.number,
                              validation: (value) {
                                return Validation.validateZip(value!);
                              },
                              onSave: (value) {
                                addressZip = value!;
                              },
                              focusNode: zipFocusNode,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  if (formLoading) CustomCircularBar(size: 56, padding: 16),
                  if (!formLoading)
                    CustomButton(
                      pressedFun: trySubmit,
                      buttonText: 'Add New',
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
      ),
    );
  }
}
