import 'package:edonation/src/views/ui/settings/settings/change_password.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Help extends StatelessWidget {
  const Help({Key? key}) : super(key: key);

  static const routeName = '/help';

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
        text: 'Help',
        backButton: true,
      ),
      backgroundColor: CustomColors.backgroundColor,
      body: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
          child: Column(
            children: [
              _settingListTile('About Us', () {}),
              _divider(),
              _settingListTile('FAQs', () {}),
              _divider(),
              _settingListTile('Help Center', () {}),
              _divider(),
              _settingListTile('Terms & Conditions', () {}),
              _divider(),
              _settingListTile('Privacy Policy', () {}),
              _divider(),
              _settingListTile('Rate This App', () {}),
              _divider(),
              _settingListTile('Invite Friend', () {}),
            ],
          ),
        ),
      ),
    );
  }

  _settingListTile(String text, void Function()? onTap) {
    return ListTile(
      onTap: onTap,
      title: Text('$text'),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: CustomColors.iconColor,
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
}
