// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:math';
import 'package:contract_list/actions/database.dart';
import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/models/contract.dart';
import 'package:contract_list/models/user.dart';
import 'package:contract_list/pages/edit_contact.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetails extends StatefulHookConsumerWidget {
  final Contact contact;
  const ContactDetails({super.key, required this.contact});

  @override
  ConsumerState<ContactDetails> createState() => _ContactDetailsState();
}

class _ContactDetailsState extends ConsumerState<ContactDetails> {
  final random = Random();
  Widget _setImageView() {
    if (widget.contact.image != null) {
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

  @override
  Widget build(BuildContext context) {
    User userState = ref.watch(userStateProvider);
    return Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0),
            topRight: Radius.circular(25.0),
          ),
        ),
        child: SingleChildScrollView(
            child: Column(children: [
          Container(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20, vertical: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                    },
                    child:const Padding(
                      padding: EdgeInsets.all(10),
                      child:  Icon(Icons.arrow_back_ios,
                          size: 20, color: Colors.blue),
                    )),
                SizedBox(width: MediaQuery.of(context).size.width * 0.25),
                const Text("Contact Detail",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              ])),
          const SizedBox(height: 20),
          _setImageView(),
          const SizedBox(height: 20),
          Text(
              widget.contact.firstName! +
                  (widget.contact.lastName ?? "") +
                  (widget.contact.companyName ?? ""),
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          Uri phoneno = Uri.parse('tel:' +
                              (widget.contact.phone == null
                                  ? ""
                                  : widget.contact.phone!.phoneNumber));
                          await launchUrl(phoneno);
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 223, 71, 71),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromARGB(169, 255, 85, 85),
                                          offset: Offset(
                                            2.0,
                                            2.0,
                                          ),
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0)
                                    ]),
                                child: const Icon(Icons.call,
                                    size: 25, color: Colors.white))),
                      ),
                      SizedBox(height: 10),
                      Text("Call")
                    ],
                  ),
                  // edit
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              context: context,
                              builder: (BuildContext context) =>
                                  EditContact(contact: widget.contact));
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                                padding: EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 223, 71, 71),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromARGB(169, 255, 85, 85),
                                          offset: Offset(
                                            2.0,
                                            2.0,
                                          ),
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0)
                                    ]),
                                child: const Icon(Icons.edit,
                                    size: 25, color: Colors.white))),
                      ),
                      const SizedBox(height: 10),
                      const Text("Edit")
                    ],
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          await DatabaseManager().deleteContact(
                              ref.read(userStateProvider).uid!, widget.contact);
                          Navigator.of(context).pop();
                        },
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 223, 71, 71),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromARGB(169, 255, 85, 85),
                                          offset: Offset(
                                            2.0,
                                            2.0,
                                          ),
                                          blurRadius: 1.0,
                                          spreadRadius: 1.0)
                                    ]),
                                child: const Icon(Icons.delete,
                                    size: 25, color: Colors.white))),
                      ),
                      const SizedBox(height: 10),
                      const Text("Delete")
                    ],
                  ),
                ]),
          ),
          const SizedBox(height: 30),
          (widget.contact.phone == null ||
                      widget.contact.phone!.phoneNumber == "") &&
                  widget.contact.email == null
              ? const SizedBox.shrink()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Divider(height: 1, thickness: 1),
                      widget.contact.phone == null
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: InkWell(
                                    onTap: () async {
                                      Uri phoneno = Uri.parse('tel:' +
                                          (widget.contact.phone == null
                                              ? ""
                                              : widget
                                                  .contact.phone!.phoneNumber));
                                      await launchUrl(phoneno);
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.phone),
                                        const SizedBox(width: 15),
                                        Text((widget.contact.phone == null
                                            ? ""
                                            : widget
                                                .contact.phone!.phoneNumber))
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(height: 1, thickness: 1),
                              ],
                            ),
                      widget.contact.email == null
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.email),
                                        const SizedBox(width: 15),
                                      Text(widget.contact.email!)
                                    ],
                                  ),
                                ),
                                const Divider(height: 1, thickness: 1),
                              ],
                            )
                    ],
                  ),
                ),
        ])));
  }
}
