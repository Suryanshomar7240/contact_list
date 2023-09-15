import 'package:contract_list/actions/database.dart';
import 'package:contract_list/actions/providers.dart';
import 'package:contract_list/models/contract.dart';
import 'package:contract_list/models/user.dart';
import 'package:contract_list/pages/contact_details.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:math';

extension StringExtension on String {
  String capitalize() {
     return 
       "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class ContactList extends StatefulHookConsumerWidget {
  const ContactList({super.key});

  @override
  ConsumerState<ContactList> createState() => _ContactListState();
}

class _ContactListState extends ConsumerState<ContactList> {
  final random = Random();
  Widget _getImage(String? image, String firstName) {
    if (image == null) {
      return ClipOval(
          child: SizedBox.fromSize(
        size: const Size.fromRadius(20),
        child: Container(
            color: Color.fromARGB(250, random.nextInt(255), random.nextInt(255),
                random.nextInt(255)),
            child: Center(
                child: Text(
              firstName[0],
              style: TextStyle(fontSize: 20),
            ))),
      ));
    } else {
      return ClipOval(
          child: SizedBox.fromSize(
              size: const Size.fromRadius(20),
              child: Image.network(image, fit: BoxFit.cover)));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserStateNotifer userState = ref.watch(userStateProvider.notifier);
    return SafeArea(
        child: Scaffold(
            floatingActionButton: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/add_contact');
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Color.fromARGB(255, 235, 235, 235),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[300] ?? Colors.black,
                            offset: const Offset(
                              4.0,
                              2.0,
                            ),
                            blurRadius: 10.0,
                            spreadRadius: 1.0)
                      ]),
                  child: const Icon(Icons.add),
                )),
            body: Container(
              
              
              child: Column(children: [
                Container(
                  decoration: const BoxDecoration(
                  color: Color.fromARGB(248, 248, 50, 47),
                    boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(117, 191, 191, 191),
                    offset: Offset(
                      5.0,
                      8.0,
                    ),
                    blurRadius: 10.0,
                    spreadRadius: 5.0)
              ]),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Contacts",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                          InkWell(
                              onTap: () {
                                userState.signOut();
                                Navigator.of(context).popAndPushNamed('/login');
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
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            
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
                        child: const TextField(
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(Icons.search),
                                contentPadding: EdgeInsets.only(top: 12),
                                hintText: "Search in Contact",
                                border: UnderlineInputBorder(
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
                SizedBox(height: 2),
                StreamBuilder(
                    stream: DatabaseManager().getContact(userState.state.uid!),
                    builder: (context, contacts) {
                      if (contacts.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue));
                      } else {
                        List<Contact> contact = contacts.data!;
                        return SingleChildScrollView(
                          child: SizedBox(
                          height: MediaQuery.of(context).size.height*0.79,
                            
                            child: ListView.builder(
                                itemCount: contacts.data!.length,
                                itemBuilder: (context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          context: context,
                                          builder: (BuildContext context) =>
                                              ContactDetails(
                                                  contact: contact[index]));
                                    },
                                    child: Container(
                                      
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                          
                                      child: Column(
                                        children: [
                                          Row(children: [
                                            _getImage(contact[index].image,
                                                contact[index].firstName!),
                                            const SizedBox(width: 10),
                                            Text(
                                               ( contact[index].firstName! +
                                                    (contact[index].lastName ??
                                                        "") +
                                                    (contact[index].companyName ??
                                                        "")).capitalize(),
                                                        
                                                style: const TextStyle(
                                                    fontSize: 16,fontWeight: FontWeight.w400)),
                                          ]),
                                          const SizedBox(height: 5),
                                          (index != contact.length - 1)
                                              ? const Divider(
                                                  height: 1, thickness: 0.1)
                                              : const SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        );
                      }
                    })
              ]),
            )));
  }
}
