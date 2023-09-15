import 'dart:io';
import 'dart:math';
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

class EditContact extends StatefulHookConsumerWidget {
  final Contact contact;
  const EditContact({super.key, required this.contact});

  @override
  ConsumerState<EditContact> createState() => _EditContactState();
}

class _EditContactState extends ConsumerState<EditContact> {
  XFile? imageFile;
  String dropdownValue = "";
  String phoneNumber = "";
  late Contact changedContact;
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
  @override
  void initState() {
    changedContact = Contact(
      firstName: widget.contact.firstName,
      lastName: widget.contact.lastName,
      companyName: widget.contact.companyName,
      image: widget.contact.image,
      phone: widget.contact.phone,
      email: widget.contact.email,
      docId: widget.contact.docId,
    );
    phoneNumber =
        changedContact.phone == null ? "" : changedContact.phone!.phoneNumber;
    super.initState();
    dropdownValue = widget.contact.phone == null
        ? 'Mobile'
        : widget.contact.phone!.phoneType;
  }

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

  final random = Random();
  Widget _setImageView() {
    if (imageFile != null) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: ClipOval(
              child: SizedBox.fromSize(
            size: const Size.fromRadius(70),
            child: Image.file(File(imageFile!.path),
                width: 100, height: 100, fit: BoxFit.cover),
          )));
    } else if (widget.contact.image != null) {
      return Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          child: ClipOval(
              child: SizedBox.fromSize(
            size: const Size.fromRadius(70),
            child: Image.network(widget.contact.image!,
                width: 100, height: 100, fit: BoxFit.cover),
          )));
    } else {
      return ClipOval(
          child: SizedBox.fromSize(
        size: const Size.fromRadius(70),
        child: Container(
            color: Color.fromARGB(250, random.nextInt(255), random.nextInt(255),
                random.nextInt(255)),
            child: Center(
                child: Text(
              widget.contact.firstName![0],
              style: const TextStyle(fontSize: 80),
            ))),
      ));
    }
  }

  bool loading = false;
  String error = "";

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
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
                        const Text("Edit Contact",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        InkWell(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              if (changedContact.firstName == "" ||
                                  changedContact.firstName == null) {
                                setState(() {
                                  error = "First name can't be null";
                                  loading = false;
                                });
                                return;
                              }
                              if(imageFile!=null){
                                changedContact.image = await _uploadFile();}
                              changedContact.phone = Phoneclass(
                                  phoneType: dropdownValue,
                                  phoneNumber: phoneNumber);
                              changedContact.firstName =
                                  changedContact.firstName?.capitalize();
                              await DatabaseManager().updateContact(
                                  userState.uid!, changedContact);
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
                            child: const Text("Change photo",
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
                                  changedContact.firstName = val;
                                },
                                controller: TextEditingController(
                                    text: changedContact.firstName ?? ""),
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
                                  changedContact.lastName = val;
                                },
                                controller: TextEditingController(
                                    text: changedContact.lastName ?? ""),
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
                                    changedContact.companyName = val;
                                  },
                                  controller: TextEditingController(
                                      text: changedContact.companyName ?? ""),
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
                                controller:
                                    TextEditingController(text: phoneNumber),
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
                                      changedContact.email = val;
                                    },
                                    controller: TextEditingController(
                                        text: changedContact.email ?? ""),
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
