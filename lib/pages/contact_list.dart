import 'package:contract_list/actions/database.dart';
import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/models/contract.dart';
import 'package:contract_list/models/user.dart';
import 'package:contract_list/pages/contact_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class ContactList extends StatefulHookConsumerWidget {
  const ContactList({super.key});

  @override
  ConsumerState<ContactList> createState() => _ContactListState();
}

class _ContactListState extends ConsumerState<ContactList> {
  final random = Random();
  var _controller = TextEditingController();
  bool searching = false;
  bool hasFocus = false;
  String? searchQuery;
  // final FocusNode _focus = FocusNode();
  // @override
  // void initState() {
  //   super.initState();
  //   _focus.addListener(_onFocusChange);
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _focus.removeListener(_onFocusChange);
  //   _focus.dispose();
  // }

  // void _onFocusChange() {
  //   setState(() {
  //     hasFocus = _focus.hasFocus;
  //   });
  //   if (_focus.hasFocus == false) {
  //     setState(() {
  //       searchQuery = null;
  //     });
  //   }
  //   print("Focus: ${_focus.hasFocus.toString()}");
  // }

  Widget _getImage(String? image, String firstName) {
    if (image == null) {
      return ClipOval(
          child: SizedBox.fromSize(
        size: const Size.fromRadius(25),
        child: Container(
            color: Color.fromARGB(250, random.nextInt(255), random.nextInt(255),
                random.nextInt(255)),
            child: Center(
                child: Text(
              firstName[0],
              style: TextStyle(fontSize: 25),
            ))),
      ));
    } else {
      return ClipOval(
          child: SizedBox.fromSize(
              size: const Size.fromRadius(20),
              child: Image.network(image, fit: BoxFit.cover)));
    }
  }

  // bool keyboardVisible = false;
  // @protected
  // void initState() {
  //   super.initState();

  //   KeyboardVisibilityNotification().addNewListener(
  //     onChange: (bool visible) {
  //       setState(() {
  //         keyboardVisible = visible;
  //       });
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    UserStateNotifer userState = ref.watch(userStateProvider.notifier);
    return KeyboardDismissOnTap(
      child: SafeArea(
          child: Scaffold(
              floatingActionButton: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/add_contact');
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color.fromARGB(255, 253, 253, 253),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[300] ?? Colors.black,
                              offset: const Offset(
                                4.0,
                                5.0,
                              ),
                              blurRadius: 10.0,
                              spreadRadius: 5.0)
                        ]),
                    child: const Icon(Icons.add),
                  )),
              body:  Container(
                child: Column(children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: Color.fromARGB(248, 248, 50, 47),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromARGB(58, 191, 191, 191),
                              offset: Offset(
                                5.0,
                                8.0,
                              ),
                              blurRadius: 10.0,
                              spreadRadius: 5.0)
                        ]),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Contacts",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20)),
                            InkWell(
                                onTap: () {
                                  userState.signOut();
                                  Navigator.of(context)
                                      .popAndPushNamed('/login');
                                },
                                child: const Text("Logout",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 224, 234, 252),
                                    ))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromARGB(255, 247, 45, 45),
                                    offset: Offset(
                                      0.0,
                                      0.0,
                                    ),
                                    blurRadius: 10.0,
                                    spreadRadius: 1.0)
                              ]),
                          child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  searchQuery = val;
                                  searching = true;
                                });
                              },
                              controller: _controller,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        searchQuery = null;
                                        searching = false;
                                      });
                                      _controller.clear();
                                    },
                                    icon: Icon(Icons.clear),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(Icons.search),
                                  contentPadding: EdgeInsets.only(top: 12),
                                  hintText: "Search in Contact",
                                  border: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white,
                                          width: 0,
                                          style: BorderStyle.none),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))))),
                        )
                      ],
                    ),
                  ),
                  StreamBuilder(
                      stream:
                          DatabaseManager().getContact(userState.state.uid!),
                      builder: (context, contacts) {
                        if (contacts.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue));
                        } else {
                          List<Contact> contact = contacts.data!;
                          return SingleChildScrollView(
                            child: KeyboardVisibilityBuilder(
                              builder: (context, visible) {
                                print(visible);
                                
                                return Container(
                                  height: MediaQuery.of(context).size.height *
                                      (visible ? 0.4 : 0.79),
                                  child: Container(
                                    padding: EdgeInsets.only(top:10),
                                    child: ListView.builder(
                                        itemCount: contacts.data!.length,
                                        itemBuilder: (context, int index) {
                                          return ((searching == false ||
                                                      searchQuery == null) ||
                                                  (contact[index].firstName != null &&
                                                          contact[index]
                                                              .firstName!
                                                              .contains(
                                                                  searchQuery!) ||
                                                      (contact[index].lastName != null &&
                                                          contact[index]
                                                              .lastName!
                                                              .contains(
                                                                  searchQuery!)) ||
                                                      (contact[index].companyName != null &&
                                                          contact[index]
                                                              .companyName!
                                                              .contains(
                                                                  searchQuery!)) ||
                                                      (contact[index].phone != null &&
                                                          contact[index]
                                                              .phone!
                                                              .phoneNumber
                                                              .contains(
                                                                  searchQuery!)) ||
                                                      (contact[index].email != null &&
                                                          contact[index]
                                                              .email!
                                                              .contains(searchQuery!)))
                                              ? InkWell(
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                        isScrollControlled: true,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            ContactDetails(
                                                                contact: contact[
                                                                    index]));
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            20, 5, 20, 10),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(children: [
                                                              _getImage(
                                                                  contact[index]
                                                                      .image,
                                                                  contact[index]
                                                                      .firstName!),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                  (contact[index]
                                                                              .firstName! +
                                                                          (contact[index].lastName ??
                                                                              "") +
                                                                          (contact[index].companyName ??
                                                                              ""))
                                                                      .capitalize(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400)),
                                                            ]),
                                                            InkWell(
                                                                onTap: () async {
                                                                  Uri phoneno =
                                                                      Uri.parse(
                                                                          'tel:${contact[index].phone == null ? "" : contact[index].phone!.phoneNumber}');
                                                                  await launchUrl(
                                                                      phoneno);
                                                                },
                                                                child: const Icon(
                                                                    Icons.call,
                                                                    size: 25,
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            30,
                                                                            30,
                                                                            30)))
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 15),
                                                        (index !=
                                                                contact.length -
                                                                    1)
                                                            ? const Divider(
                                                                height: 1,
                                                                thickness: 0.5)
                                                            : const SizedBox
                                                                .shrink()
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container());
                                        }),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      })
                ]),
              ))),
    );
  }
}
