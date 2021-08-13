import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/users.dart';
import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/validations.dart';
import '../../../models/icon_type.dart';
import '../../utils/widgets/custom/custom_buttons.dart';
import '../../utils/widgets/custom/custom_form_field.dart';
import '../../utils/widgets/custom/custom_formfield_label.dart';
import '../../utils/widgets/picker/profile_pic_picker.dart';
import '../../utils/widgets/custom/custom_colors.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({Key? key}) : super(key: key);

  static const routeName = '/edit-profile';

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final _phoneFocusNode = FocusNode();
  final _genderFocusNode = FocusNode();
  final _dobFocusNode = FocusNode();
  final _bioFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();

  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _locationController = TextEditingController();

  String? _nameValidator = '';
  String? _phoneValidator = '';
  String? _dobValidator = '';
  String? _locValidator = '';

  String _userName = '';
  String _userBio = '';
  String _userPhone = '';
  String _userDob = '';
  GeoPoint _userLoc = GeoPoint(0.0, 0.0);

  List<String> _genderOptions = ['Male', 'Female', 'Rather not say'];
  String? _selectedGender;

  File? _userImageFile;

  bool isLoading = false;

  Map<String, dynamic>? signupData;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      if (_userImageFile == null) {
        _formKey.currentState?.save();

        await usersRef.doc(userCurrent!.id).update(
          {
            'username': _userName,
            'bio': _userBio,
            'phone': _userPhone,
            'gender': _selectedGender,
            'dob': _userDob,
            'loc': _userLoc,
          },
        );
      } else {
        if (isValid) {
          _formKey.currentState?.save();

          FirebaseStorage.instance.refFromURL(userCurrent!.photoUrl).delete();

          final ref = FirebaseStorage.instance
              .ref()
              .child('user_image')
              .child(userCurrent!.id + '.jpg');

          await ref.putFile(_userImageFile!);

          final url = await ref.getDownloadURL();

          await usersRef.doc(userCurrent!.id).update(
            {
              'username': _userName,
              'bio': _userBio,
              'phone': _userPhone,
              'gender': _selectedGender,
              'dob': _userDob,
              'loc': _userLoc,
              'image_url': url,
            },
          );
        }
      }
      final updatedUserSnapshot = await usersRef.doc(userCurrent!.id).get();
      Users updatedUser = Users.fromDocument(updatedUserSnapshot);
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop(updatedUser);
    }
  }

  var currentAddresses = '';

  _getLoc(GeoPoint location) async {
    var currentAddress = '';
    final geoPoint = location;
    final lat = geoPoint.latitude;
    final long = geoPoint.longitude;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      currentAddress = place.locality.toString();
    } catch (e) {
      print(e);
    }
    return currentAddress;
  }

  @override
  void initState() {
    _nameController.text = userCurrent!.username;
    _phoneController.text = userCurrent!.phone;
    _selectedGender = userCurrent!.gender;
    _dobController.text = userCurrent!.dob;
    _bioController.text = userCurrent!.bio;
    _getLoc(userCurrent!.loc).then((value) {
      var list = value;
      currentAddresses = list;
      setState(() {
        currentAddresses = list;
        _locationController.text = currentAddresses;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _genderFocusNode.dispose();
    _dobFocusNode.dispose();
    _phoneFocusNode.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    _bioController.dispose();
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
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        backButton: true,
        text: 'Edit Profile',
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
                    editProfile: true,
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
                    maxLinesLength: 1,
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
                      FocusScope.of(context).requestFocus(_bioFocusNode);
                    },
                  ),
                  SizedBox(height: 22.h),
                  CustomFormFieldLabel(hintText: 'Bio'),
                  SizedBox(height: 5.h),
                  CustomFormField(
                    obscureText: false,
                    readOnly: false,
                    iconType: IconType.Null,
                    hintText: 'e.g. Make me happy...',
                    keyValue: 'bio',
                    maxLinesLength: 1,
                    controller: _bioController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(256),
                    ],
                    focusNode: _bioFocusNode,
                    onSave: (value) {
                      _userBio = value!;
                    },
                    onFieldSubmission: (_) {
                      FocusScope.of(context).requestFocus(_phoneFocusNode);
                    },
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
                    maxLinesLength: 1,
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
                    maxLinesLength: 1,
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
                    maxLinesLength: 1,
                    controller: _locationController,
                    validation: (value) {
                      setState(() {
                        _locValidator = Validation.validateLocation(value!);
                      });
                      return _locValidator;
                    },
                    onSave: (_) {
                      if (CustomFormField.lat == 0.0 &&
                          CustomFormField.long == 0.0) {
                        _userLoc = userCurrent!.loc;
                      } else {
                        _userLoc =
                            GeoPoint(CustomFormField.lat, CustomFormField.long);
                      }
                    },
                  ),
                  SizedBox(height: 34.h),
                  if (isLoading) CustomCircularBar(size: 56, padding: 16),
                  if (!isLoading)
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
