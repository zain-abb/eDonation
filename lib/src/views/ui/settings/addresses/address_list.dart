import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/models/addresses.dart';
import 'package:edonation/src/models/callback_arguments.dart';
import 'package:edonation/src/views/ui/home/pager.dart';
import 'package:edonation/src/views/ui/settings/addresses/add_new_address.dart';
import 'package:edonation/src/views/ui/settings/addresses/edit_address.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_app_bar.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_colors.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_icons.dart';
import 'package:edonation/src/views/utils/widgets/custom/custom_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressList extends StatefulWidget {
  AddressList({Key? key}) : super(key: key);

  static const routeName = '/address-list';

  @override
  _AddressListState createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  deleteAddress(String addressId) async {
    await addressesRef
        .doc(userCurrent!.id)
        .collection('address')
        .doc(addressId)
        .delete();
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
        text: 'Addresses',
      ),
      backgroundColor: CustomColors.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AddNewAddress.routeName);
        },
        child: Icon(Icons.add_location_alt_outlined),
        backgroundColor: CustomColors.primaryColor,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        // padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.w),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: StreamBuilder<QuerySnapshot>(
            stream: addressesRef
                .doc(userCurrent!.id)
                .collection('address')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CustomCircularBar(size: 75, padding: 22),
                );
              }
              if (snapshot.data!.docs.length == 0) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/no_posts.png',
                        height: 200,
                        width: 200,
                      ),
                      // SizedBox(height: 22.h),
                      Text(
                        'No Addresses'.toUpperCase(),
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
              return ListView.separated(
                itemCount: snapshot.data!.docs.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  Addresses addresses =
                      Addresses.fromDocument(snapshot.data!.docs[index]);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        addresses.title,
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
                        '${addresses.phoneNumber}\n${addresses.addressLineOne} ${addresses.addressLineTwo} ${addresses.city} ${addresses.state}-${addresses.zipCode}',
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
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  EditAddress.routeName,
                                  arguments: EditAddressArguments(addresses));
                            },
                            child: Icon(
                              CustomIcons.edit_square,
                              color: CustomColors.iconColor,
                              size: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              deleteAddress(addresses.addressId);
                            },
                            child: Icon(
                              CustomIcons.delete,
                              color: CustomColors.errorColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 1,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
