import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edonation/src/helpers/update_last_seen.dart';
import 'package:edonation/src/models/users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/widgets/custom/custom_colors.dart';
import '../../utils/widgets/auth/auth_form.dart';

final usersRef = FirebaseFirestore.instance.collection('users');
final DatabaseReference databaseReference =
    FirebaseDatabase.instance.reference();
Users? currentUser;
final auth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLoading = false;

  void _submitAuthForm(
    String? userName,
    String email,
    String? cnic,
    String? phone,
    String? gender,
    String? dob,
    GeoPoint? loc,
    String password,
    File? pic,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;
    DocumentSnapshot doc;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user!.uid + '.jpg');

        await ref.putFile(pic!);

        final url = await ref.getDownloadURL();

        await usersRef.doc(authResult.user!.uid).set(
          {
            'id': authResult.user!.uid,
            'username': userName,
            'email': email,
            'cnic': cnic,
            'bio': '',
            'phone': phone,
            'gender': gender,
            'dob': dob,
            'loc': loc,
            'image_url': url,
            'timestamp': Timestamp.now(),
            'presence': true,
            'lastSeen': DateTime.now().millisecondsSinceEpoch,
          },
        );
        updateUserPresence(authResult.user!.uid);
      }
      doc = await usersRef.doc(authResult.user!.uid).get();
      currentUser = Users.fromDocument(doc);
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message!;
      }

      print(message);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: CustomColors.errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      var error = '';
      if (err.toString().contains('[firebase_auth/wrong-password]')) {
        error = 'The password is invalid';
      } else if (err.toString().contains('[firebase_auth/user-not-found]')) {
        error = 'There is no account corresponding to this email';
      }
      print(err);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: CustomColors.errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
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
      body: AuthForm(
        isLoading: _isLoading,
        submitFun: _submitAuthForm,
      ),
    );
  }
}
