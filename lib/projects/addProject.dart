import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dsckiit_app/model/projects.dart';
import 'package:path/path.dart';

class AddProject extends StatefulWidget {
  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  String _projectName = '';
  String _leadName = '';
  String _domain = '';
  String _number = '';
  String _repo = '';
  String _photoUrl = "empty";

  saveProject(BuildContext context) async {
    if (_projectName.isNotEmpty &&
        _leadName.isNotEmpty &&
        _domain.isNotEmpty &&
        _number.isNotEmpty &&
        _repo.isNotEmpty) {
      Project project = Project(this._projectName, this._leadName, this._domain,
          this._number, this._repo, this._photoUrl);

      await _databaseReference.push().set(project.toJson());
      navigateToLastScreen(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Fields are Empty"),
              content: Text("Please fill all the Fields"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
  }

  navigateToLastScreen(context) {
    Navigator.of(context).pop();
  }

  Future pickImage() async {
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 200.0,
      maxWidth: 200.0,
    );
    String fileName = basename(file.path);
    uploadImage(file, fileName);
  }

  void uploadImage(File file, String fileName) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    storageReference.putFile(file).onComplete.then((firebaseFile) async {
      var downloadUrl = await firebaseFile.ref.getDownloadURL();

      setState(() {
        _photoUrl = downloadUrl;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a Project')),
      body: Container(
        child: Padding(
            padding: EdgeInsets.all(20.0),
            child: ListView(children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: GestureDetector(
                    onTap: () {
                      this.pickImage();
                    },
                    child: Center(
                      child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: DecorationImage(
                                  image: _photoUrl == "empty"
                                      ? AssetImage("assets/mascot.png")
                                      : NetworkImage(_photoUrl),
                                  fit: BoxFit.contain))),
                    )),
              ),
              //Project Name
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _projectName = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //Lead Name
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _leadName = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Project Lead',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //Domain
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _domain = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Project Domain',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //Number of members
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _number = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Number of Members',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              //Url
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _repo = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Github Repository Link',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
              // Save BUtton
              Container(
                  padding: EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    padding: EdgeInsets.fromLTRB(100, 20, 100, 20),
                    onPressed: () {
                      saveProject(context);
                    },
                    color: Color(0xff183E8D),
                    child: Text('SAVE',
                        style: TextStyle(fontSize: 20.0, color: Colors.white)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                  ))
            ])),
      ),
    );
  }
}
