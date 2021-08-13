import 'package:edonation/src/views/ui/auth/auth_screen.dart';

Future<void> updateUserPresence(String uid) async {
  Map<String, dynamic> presenceStatusTrue = {
    'presence': true,
    'lastSeen': DateTime.now().millisecondsSinceEpoch,
  };

  await databaseReference
      .child(uid)
      .update(presenceStatusTrue)
      .whenComplete(() => print('Updated your presence.'))
      .catchError((e) => print(e));

  Map<String, dynamic> presenceStatusFalse = {
    'presence': false,
    'lastSeen': DateTime.now().millisecondsSinceEpoch,
  };

  databaseReference.child(uid).onDisconnect().update(presenceStatusFalse);
}
