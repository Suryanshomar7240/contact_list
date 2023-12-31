import 'dart:io';
import 'package:contract_list/actions/database.dart';
import 'package:contract_list/actions/firebase_storage.dart';
import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/models/contract.dart';
import 'package:contract_list/models/user.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class AddContact extends StatefulHookConsumerWidget {
  const AddContact({super.key});

  @override
  ConsumerState<AddContact> createState() => _AddContactState();
}

class _AddContactState extends ConsumerState<AddContact> {
  XFile? imageFile;
  String dropdownValue = 'Mobile';
  Contact contact = Contact();
  String phoneNumber = "";
  List<String> dropdownItems = [
    'Mobile',
    'Work',
    'Home',
    'Main',
    'Work Fax',
    'Home Fax',
    'Pager',
    'Other'
  ];
  bool loading = false;
  String error = "";
  get kBackgroundColor => null;

  void _openGallery(BuildContext context) async {
    final picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  void _openCamera(BuildContext context) async {
    var picture = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }

  Future<void> _showSelectionDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("From where do you want to take the photo?"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: const Text("Gallery"),
                      onTap: () {
                        _openGallery(context);
                      },
                    ),
                    const Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: const Text("Camera"),
                      onTap: () {
                        _openCamera(context);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future _uploadFile() async {
    if (imageFile == null) return null;

    final filename = basename(imageFile!.path);
    final destination = 'users/$filename';

    var task = FireBaseApi.uploadFile(destination, File(imageFile!.path));
    if (task == null) return null;
    final snapshot = await task.whenComplete(() {});
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  Widget _setImageView() {
    if (imageFile != null) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: ClipOval(
              child: SizedBox.fromSize(
            size: const Size.fromRadius(70),
            child: Image.file(File(imageFile!.path),
                width: 200, height: 200, fit: BoxFit.fill),
          )));
    } else {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(70),
              child: Image.asset('assets/avatar.png',
                  width: 200, height: 200, fit: BoxFit.fill),
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    User userState = ref.watch(userStateProvider);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10, vertical: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blue))),
                        const Text("New Contact",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        InkWell(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              if (contact.firstName == "" ||
                                  contact.firstName == null) {
                                setState(() {
                                  error = "Enter the first name";
                                  loading = false;
                                });
                                return;
                              }
                              contact.image = await _uploadFile();
                              contact.phone = Phoneclass(
                                  phoneType: dropdownValue,
                                  phoneNumber: phoneNumber);
                              contact.firstName =
                                  contact.firstName?.capitalize();
                              await DatabaseManager()
                                  .addContact(userState.uid!, contact);
                              Navigator.of(context).pop();
                            },
                            child: const Text("Done",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.blue)))
                      ])),
              const SizedBox(height: 20),
              _setImageView(),
              const SizedBox(height: 15),
              loading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(236, 255, 26, 26)))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(children: [
                        InkWell(
                            onTap: () {
                              _showSelectionDialog(context);
                            },
                            child: const Text("Add photo",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ))),
                        const SizedBox(height: 15),
                        Center(
                            child: Text(error,
                                style: const TextStyle(color: Colors.red))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // SizedBox(width: 30),
                            const Icon(Icons.person, size: 30),
                            const SizedBox(width: 30),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextField(
                                onChanged: (val) {
                                  contact.firstName = val;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'First Name',
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextField(
                                onChanged: (val) {
                                  contact.lastName = val;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Last Name',
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // SizedBox(width: 30),
                              const Icon(Icons.business, size: 30),
                              SizedBox(width: 30),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: TextField(
                                  onChanged: (val) {
                                    contact.companyName = val;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Company Name',
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                ),
                              )
                            ]),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Padding(
                                padding: EdgeInsets.only(bottom: 4),
                                child: Icon(Icons.phone, size: 30)),
                            DropdownButton<String>(
                              value: dropdownValue,
                              items: dropdownItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownValue = newValue!;
                                });
                              },
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                onChanged: (val) {
                                  phoneNumber = val;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Phone Number',
                                    contentPadding:
                                        EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // SizedBox(width: 30),
                              const Icon(Icons.email, size: 30),
                              SizedBox(width: 30),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  child: TextField(
                                    onChanged: (val) {
                                      contact.email = val;
                                    },
                                    decoration: const InputDecoration(
                                        hintText: 'Email',
                                        contentPadding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0)),
                                  ))
                            ]),
                      ]),
                    ),
            ],
          ),
        )),
      ),
    );
  }
}
