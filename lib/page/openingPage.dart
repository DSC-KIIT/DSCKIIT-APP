import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dsckiit_app/Widgets/rounded_button.dart';
import 'package:dsckiit_app/screen/animatorLoader.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dsckiit_app/page/SignUpPage.dart';
import 'package:dsckiit_app/page/SignInPage.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

final kFirebaseAnalytics = FirebaseAnalytics();

class OpeningPage extends StatefulWidget {
  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  FirebaseUser _user;
  final Firestore _db = Firestore.instance;
  String fcmToken;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // If this._busy=true, the buttons are not clickable. This is to avoid
  // clicking buttons while a previous onTap function is not finished.
  bool _busy = false;

  @override
  void initState() {
    _firebaseMessaging.getToken().then((value) => fcmToken = value);
    super.initState();
    FirebaseAuth.instance.currentUser().then(
          (user) => setState(() => this._user = user),
        );
  }

  // Sign in with Google.
  Future<FirebaseUser> _googleSignIn() async {
    final curUser = this._user ?? await FirebaseAuth.instance.currentUser();
    if (curUser != null && !curUser.isAnonymous) {
      return curUser;
    }
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Note: user.providerData[0].photoUrl == googleUser.photoUrl.
    final user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    kFirebaseAnalytics.logLogin();
    setState(() => this._user = user);
    updateUserData(user);
    return user;
  }

  void updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);

    return ref.setData({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoUrl,
      'displayName': user.displayName,
      'admin': false,
      'lastSeen': DateTime.now(),
      'fcmToken':fcmToken
    }, merge: true);
  }

  Future<Null> _signOut() async {
    final user = await FirebaseAuth.instance.currentUser();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(user == null
            ? 'No user logged in.'
            : '"${user.displayName}" logged out.'),
      ),
    );
    FirebaseAuth.instance.signOut();
    setState(() => this._user = null);
  }

  void _showUserProfilePage(FirebaseUser user) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
      return Loader();
    }));
  }

  Widget _signInButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: this._busy
          ? null
          : () async {
              setState(() => this._busy = true);
              final user = await this._googleSignIn();
              this._showUserProfilePage(user);
              setState(() => this._busy = false);
            },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Image.asset(
                        'assets/logo.png',
                        width: 150,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.05,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Companion App.", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                          SizedBox(height: 5),
                          Text("Lets build good", style: TextStyle(fontSize: 30),),
                          SizedBox(height: 5),
                          Text("things together.", style: TextStyle(fontSize: 30),),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                  children: <Widget>[
//                    RoundedButton(
//                      onPressed: () {
//                        Navigator.of(context).push(MaterialPageRoute<Null>(
//                            builder: (BuildContext context) {
//                          return SignupPage();
//                        }));
//                      },
//                      color: Colors.blue,
//                      textColor: Colors.white,
//                      text: 'Sign up',
//                    ),
//                    SizedBox(
//                      width: 20,
//                    ),
//                    RoundedButton(
//                      onPressed: () {
//                        Navigator.of(context).push(MaterialPageRoute<Null>(
//                            builder: (BuildContext context) {
//                          return SigninPage();
//                        }));
//                      },
//                      color: Colors.grey[50],
//                      textColor: Colors.black,
//                      text: 'Sign in',
//                    ),
//                  ],
//                ),
//                const SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(top: 50),
                ),
                Center(
                  child: _signInButton(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// builder: (ctx) => Scaffold(
//   appBar: AppBar(
//     title: Text('user profile'),
//   ),
//   body: ListView(
//     children: <Widget>[
//       ListTile(title: Text('User id: ${user.uid}')),
//       ListTile(title: Text('Display name: ${user.displayName}')),
//       ListTile(title: Text('Anonymous: ${user.isAnonymous}')),
//       ListTile(title: Text('providerId: ${user.providerId}')),
//       ListTile(title: Text('Email: ${user.email}')),
//       ListTile(
//         title: Text('Profile photo: '),
//         trailing: user.photoUrl != null
//             ? CircleAvatar(
//                 backgroundImage: NetworkImage(user.photoUrl),
//               )
//             : CircleAvatar(
//                 child: Text(user.displayName[0]),
//               ),
//       ),
//       ListTile(
//         title: Text('Last sign in: ${user.metadata.lastSignInTime}'),
//       ),
//       ListTile(
//         title: Text('Creation time: ${user.metadata.creationTime}'),
//       ),
//       ListTile(title: Text('ProviderData: ${user.providerData}')),
//     ],
//   ),
// ),
