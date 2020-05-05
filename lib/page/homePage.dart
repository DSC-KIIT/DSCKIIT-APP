import 'package:dsckiit_app/page/chat_container.dart';
import 'package:dsckiit_app/page/media_page.dart';
import 'package:dsckiit_app/page/mentorPage.dart';
import 'package:dsckiit_app/page/teamPage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dsckiit_app/Widgets/custom_card.dart';
import 'package:dsckiit_app/Widgets/custom_event_card.dart';
import 'package:dsckiit_app/constants.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:dsckiit_app/page/account_page.dart';
import 'package:line_icons/line_icons.dart';
import 'package:dsckiit_app/screen/notification_screen.dart';
import 'package:dsckiit_app/projects/addProject.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  FirebaseUser user;
  bool isSignedIn = false;

  // checkAuthentication() async {
  //   _auth.onAuthStateChanged.listen((user) {
  //     if (user == null) {
  //       Navigator.pushReplacementNamed(context, "/OpeningPage");
  //     }
  //   });
  // }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;

        this.isSignedIn = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    //this.checkAuthentication();
    this.getUser();
  }

  navigateToAddProjects() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return AddProject();
    }));
  }

  int _currentNavBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: FloatingSearchBar.builder(
          pinned: true,
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Ongoing",
                          style: kHeadingStyle,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.grey[900],
                          ),
                          iconSize: 27,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, int index) {
                        return CustomCard(
                          title: 'American Sign Language Recognition',
                          members: index + 1,
                          color: Colors.indigo,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Events and Schedules",
                          style: kHeadingStyle,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: Colors.grey[900],
                          ),
                          iconSize: 27,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          Firestore.instance.collection('events').snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator());
                          default:
                            return new ListView(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                return new CustomEventCard(
                                  title: document['title'],
                                  imgURL: document['image'],
                                  date: document['date'],
                                  registerUrl: document['register'],
                                );
                              }).toList(),
                            );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          trailing: !isSignedIn
              ? CircleAvatar(
                  backgroundImage: AssetImage("assets/animator.gif"),
                  backgroundColor: Colors.transparent,
                )
              : CircleAvatar(
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl)
                      : AssetImage('assets/user.png'),
                  backgroundColor: Colors.transparent,
                ),
          drawer: Drawer(
            child: !isSignedIn
                ? CircularProgressIndicator()
                : ListView(
                    children: <Widget>[
                      UserAccountsDrawerHeader(
                        accountName: Text('${user.displayName}'),
                        accountEmail: Text('${user.email}'),
                        decoration: BoxDecoration(color: Color(0xFF183E8D)),
                        currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 50,
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl)
                                : AssetImage("assets/user.png")),
                      ),
                      ListTile(
                        title: Text("Mentors"),
                        trailing: Icon(Icons.person),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MentorPage()));
                        },
                      ),
                      ListTile(
                        title: Text("Team"),
                        trailing: Icon(Icons.group),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TeamPage()));
                        },
                      ),
                      ListTile(
                        title: Text("Noticeboard"),
                        trailing: Icon(Icons.photo),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MediaPage()));
                        },
                      ),
                      ListTile(
                        title: Text("Feedback From"),
                        trailing: Icon(Icons.feedback),
                        onTap: () {},
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Close"),
                        trailing: Icon(Icons.close),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
          ),
          onChanged: (String value) {},
          onTap: () {},
          decoration: InputDecoration.collapsed(
            hintText: "Search events, people etc.",
          ),
        ),
      ), // Home screen
      !isSignedIn
          ? CircularProgressIndicator()
          : ChatContainer(
              uid: user.uid ?? "",
            ),
      NotificationScreen(),
      AccountPage(user: user),
    ];

    FlutterStatusbarcolor.setStatusBarColor(Colors.grey);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: tabs[_currentNavBarIndex],
        floatingActionButton: _currentNavBarIndex != 0
            ? null
            : FloatingActionButton(
                backgroundColor: Color(0xff183E8D),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: navigateToAddProjects,
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 35,
          unselectedIconTheme: IconThemeData(size: 30),
          currentIndex: _currentNavBarIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(
                  LineIcons.home,
                  color: Colors.black45,
                ),
                title: Text("Home"),
                activeIcon: Icon(
                  LineIcons.home,
                  color: Colors.black,
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  LineIcons.comments,
                  color: Colors.black45,
                ),
                title: Text("Messages"),
                activeIcon: Icon(
                  LineIcons.comments,
                  color: Colors.amber,
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  LineIcons.bell,
                  color: Colors.black45,
                ),
                title: Text("Notifications"),
                activeIcon: Icon(
                  LineIcons.bell,
                  color: Colors.black,
                )),
            BottomNavigationBarItem(
                icon: Icon(
                  LineIcons.user,
                  color: Colors.black45,
                ),
                title: Text("Account"),
                activeIcon: Icon(
                  LineIcons.user,
                  color: Colors.black,
                )),
          ],
          onTap: (index) {
            setState(() {
              _currentNavBarIndex = index;
            });
          },
        ),
      ),
    );
  }
}
