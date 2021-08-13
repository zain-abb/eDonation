import 'package:edonation/src/views/ui/auth/auth_screen.dart';
import 'package:edonation/src/views/ui/feed/activity_feed.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/profile/user_edit_profile.dart';
import 'package:edonation/src/views/ui/profile/user_profile.dart';
import 'package:edonation/src/views/ui/settings/addresses/address_list.dart';
import 'package:edonation/src/views/ui/settings/contact_us.dart';
import 'package:edonation/src/views/ui/settings/donations_record.dart';
import 'package:edonation/src/views/ui/settings/help.dart';
import 'package:edonation/src/views/ui/settings/saved_posts.dart';
import 'package:edonation/src/views/ui/settings/settings/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/widgets/custom/custom_colors.dart';
import '../../utils/widgets/custom/custom_icons.dart';
import '../../utils/widgets/picker/profile_pic_viewer.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({Key? key}) : super(key: key);

  static const routeName = '/preferences-screen';

  @override
  _PreferencesScreenState createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  List<String> currentAddresses = [];

  Future<List<String>> _getLoc() async {
    List<String> currentAddress = [];
    final geoPoint = userCurrent!.loc;
    final lat = geoPoint.latitude;
    final long = geoPoint.longitude;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      Placemark place = placemarks[0];
      currentAddress.add('${place.locality}');
    } catch (e) {
      print(e);
    }
    return currentAddress;
  }

  @override
  void initState() {
    currentAddresses = List.filled(1, '');
    _getLoc().then((value) {
      setState(() {
        currentAddresses = value.toList();
      });
    });
    super.initState();
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

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            alignment: Alignment.topCenter),
        color: CustomColors.backgroundColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 74.h),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(UserProfile.routeName,
                    arguments: userCurrent!.id);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 44.w),
                  ProfilePicViewer(size: 48, url: userCurrent!.photoUrl),
                  SizedBox(width: 22.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userCurrent!.username,
                        style: GoogleFonts.alata(
                          textStyle: TextStyle(
                            // ignore: deprecated_member_use
                            fontSize: 24.ssp,
                            color: CustomColors.whiteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            CustomIcons.location,
                            size: 16,
                            color: CustomColors.whiteColor,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            currentAddresses[0],
                            style: GoogleFonts.openSans(
                              textStyle: TextStyle(
                                // ignore: deprecated_member_use
                                fontSize: 18.ssp,
                                color: CustomColors.whiteColor,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 34.h),
            Container(
              width: mediaQuery.size.width - 44.w,
              child: Card(
                color: CustomColors.whiteColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _tileButton('Donations', CustomIcons.wallet, () {
                        Navigator.of(context)
                            .pushNamed(DonationsRecord.routeName);
                      }),
                      _tileButton('Saved', CustomIcons.bookmark, () {
                        Navigator.of(context).pushNamed(SavedPosts.routeName);
                      }),
                      _tileButton('Activity', CustomIcons.chart, () {
                        Navigator.of(context).pushNamed(ActivityFeed.routeName);
                      }),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 34.h),
            Column(
              children: [
                Container(
                  width: mediaQuery.size.width - 44.w,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        children: [
                          _settingListTile(
                              CustomIcons.profile, 'My Profile', true, false,
                              () {
                            Navigator.of(context)
                                .pushNamed(EditUserProfile.routeName);
                          }),
                          _divider(),
                          _settingListTile(
                              CustomIcons.location, 'Addresses', false, false,
                              () {
                            Navigator.of(context)
                                .pushNamed(AddressList.routeName);
                          }),
                          _divider(),
                          _settingListTile(
                              CustomIcons.setting, 'Settings', false, false,
                              () {
                            Navigator.of(context).pushNamed(Settings.routeName);
                          }),
                          _divider(),
                          _settingListTile(
                              CustomIcons.call, 'Contact Us', false, false, () {
                            Navigator.of(context)
                                .pushNamed(ContactUs.routeName);
                          }),
                          _divider(),
                          _settingListTile(
                              CustomIcons.info_square, 'Help', false, true, () {
                            Navigator.of(context).pushNamed(Help.routeName);
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 34.h),
            _logout(mediaQuery.size),
            SizedBox(height: 22.h),
          ],
        ),
      ),
    );
  }

  _tileButton(String text, IconData icon, Function()? onPress) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateColor.resolveWith(
          (states) => CustomColors.primaryFadeColor,
        ),
      ),
      onPressed: onPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: CustomColors.primaryColor,
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            '$text',
            style: TextStyle(
              color: CustomColors.textColor,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }

  _settingListTile(IconData icon, String text, bool first, bool last,
      void Function()? onTap) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: first ? Radius.circular(15) : Radius.circular(0),
          topRight: first ? Radius.circular(15) : Radius.circular(0),
          bottomLeft: last ? Radius.circular(15) : Radius.circular(0),
          bottomRight: last ? Radius.circular(15) : Radius.circular(0),
        ),
      ),
      onTap: onTap,
      leading: Icon(
        icon,
        color: CustomColors.primaryColor,
      ),
      title: Text('$text'),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: CustomColors.primaryColor,
      ),
    );
  }

  _divider() {
    return Divider(
      indent: 22.w,
      endIndent: 22.w,
      height: 1,
    );
  }

  _logout(Size size) {
    return Container(
      width: size.width - 44.w,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logged out...'),
              ),
            );
            setState(() {
              signOut();
            });
            // Navigator.of(context).pushNamedAndRemoveUntil(
            //     AuthScreen.routName, (Route<dynamic> route) => false);
          },
          leading: Icon(
            CustomIcons.logout,
            color: CustomColors.errorColor,
          ),
          title: Text('Log Out'),
        ),
      ),
    );
  }

  signOut() async {
    await auth.signOut();
  }
}
