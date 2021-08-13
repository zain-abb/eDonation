import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/validations.dart';
import '../../../models/icon_type.dart';
import '../../utils/widgets/custom/custom_buttons.dart';
import '../../utils/widgets/custom/custom_form_field.dart';
import '../../utils/widgets/custom/custom_formfield_label.dart';
import '../../utils/widgets/picker/profile_pic_picker.dart';
import '../../utils/widgets/custom/custom_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  static const routeName = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _phoneFocusNode = FocusNode();
  final _genderFocusNode = FocusNode();
  final _dobFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _locationController = TextEditingController();

  String? _nameValidator = '';
  String? _phoneValidator = '';
  String? _dobValidator = '';
  String? _locValidator = '';

  String _userName = '';
  String _userPhone = '';
  String _userDob = '';
  GeoPoint _userLoc = GeoPoint(0.0, 0.0);

  List<String> _genderOptions = ['Male', 'Female', 'Rather not say'];
  String? _selectedGender;

  File? _userImageFile;

  Map<String, dynamic>? signupData;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (!_validateImage()) return;

    if (isValid) {
      _formKey.currentState?.save();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome $_userName!'),
          backgroundColor: CustomColors.primaryColor,
        ),
      );
      Timer(Duration(seconds: 2), () {
        Navigator.pop(
          context,
          {
            'pic': _userImageFile,
            'username': _userName,
            'phone': _userPhone,
            'gender': _selectedGender,
            'dob': _userDob,
            'loc': _userLoc,
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _genderFocusNode.dispose();
    _dobFocusNode.dispose();
    _phoneFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    signupData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _emailController.text = signupData!['email'];
    _cnicController.text = signupData!['cnic'];

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
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.openSans(
              textStyle: TextStyle(
                // ignore: deprecated_member_use
                fontSize: 15.ssp,
                color: CustomColors.headingColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: CustomColors.whiteColor,
          elevation: 0.5,
        ),
      ),
      body: Container(
        width: mediaQuery.size.width,
        height: mediaQuery.size.height,
        color: CustomColors.backgroundColor,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: CustomColors.whiteColor,
            ),
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
            width: mediaQuery.size.width - 44.w,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: 12.h),
                  ProfilePicPicker(
                    imagePickFun: _pickedImage,
                    size: 64,
                  ),
                  SizedBox(height: 34.h),
                  CustomFormFieldLabel(hintText: 'Name'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    readOnly: false,
                    iconType: IconType.Null,
                    hintText: 'e.g. Muhammad Ali',
                    keyValue: 'name',
                    controller: _nameController,
                    validation: (value) {
                      setState(() {
                        _nameValidator = Validation.validateName(value!);
                      });
                      return _nameValidator;
                    },
                    onSave: (value) {
                      _userName = value!;
                    },
                    onFieldSubmission: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Email Address'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    keyValue: 'email',
                    readOnly: true,
                    hintText: 'someone@domain.com',
                    iconType: IconType.Null,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'CNIC'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    keyValue: 'cinc',
                    readOnly: true,
                    hintText: 'xxxxxxxxxxxxx',
                    iconType: IconType.Null,
                    controller: _cnicController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Phone'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    readOnly: false,
                    iconType: IconType.Null,
                    keyboardType: TextInputType.number,
                    hintText: '03XX-XXXXXXX',
                    keyValue: 'phone',
                    controller: _phoneController,
                    validation: (value) {
                      setState(() {
                        _phoneValidator = Validation.validatePhone(value!);
                      });
                      return _phoneValidator;
                    },
                    onSave: (value) {
                      _userPhone = value!;
                    },
                    onFieldSubmission: (_) {
                      FocusScope.of(context).requestFocus(_genderFocusNode);
                    },
                    focusNode: _phoneFocusNode,
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Gender'),
                  SizedBox(height: 5.h),
                  _genderDropdown(_genderOptions),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Date of Birth'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    readOnly: false,
                    iconType: IconType.Calendar,
                    hintText: 'yyyy-MM-dd',
                    keyValue: 'dob',
                    controller: _dobController,
                    keyboardType: TextInputType.datetime,
                    validation: (value) {
                      setState(() {
                        _dobValidator = Validation.validateDOB(value!);
                      });
                      return _dobValidator;
                    },
                    onSave: (value) {
                      _userDob = value!;
                    },
                    focusNode: _dobFocusNode,
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Location'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    readOnly: true,
                    iconType: IconType.Location,
                    hintText: '123 Street, ZIP, Country',
                    keyValue: 'loc',
                    controller: _locationController,
                    validation: (value) {
                      setState(() {
                        _locValidator = Validation.validateLocation(value!);
                      });
                      return _locValidator;
                    },
                    onSave: (_) {
                      _userLoc =
                          GeoPoint(CustomFormField.lat, CustomFormField.long);
                    },
                  ),
                  SizedBox(height: 34.h),
                  CustomButton(
                      pressedFun: _trySubmit,
                      buttonText: 'Save',
                      margin: [0.0, 0.0, 0.0, 0.0],
                      backgroundColor: 0xFF40aa54,
                      foregroundColor: 0xFFFFFFFF,
                      width: 44,
                      fontColor: 0xFFFFFFFF),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateImage() {
    if (_userImageFile == null) {
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

  Widget _genderDropdown(List<dynamic> options) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: CustomColors.textFieldFillColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.textFieldBorderColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.textFieldBorderColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.errorColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.errorColor,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: CustomColors.textFieldBorderColor,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          hintStyle: TextStyle(
            color: CustomColors.textFieldHintColor,
          ),
        ),
        icon: Icon(Icons.arrow_drop_down_outlined),
        isExpanded: true,
        value: _selectedGender,
        focusNode: _genderFocusNode,
        validator: (value) => value == null ? 'Please select gender!' : null,
        onChanged: (newValue) {
          setState(() {
            _selectedGender = newValue.toString();
          });
        },
        items: options.map((gender) {
          return DropdownMenuItem(
            child: Text(
              '$gender',
            ),
            value: gender,
            onTap: () {
              FocusScope.of(context).requestFocus(_dobFocusNode);
            },
          );
        }).toList(),
      ),
    );
  }
}
