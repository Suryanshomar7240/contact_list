import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contract_list/models/contract.dart';

class DatabaseManager {
  // final CollectionReference locationList =
  //     FirebaseFirestore.instance.collection('locations');

  final CollectionReference userModel =
      FirebaseFirestore.instance.collection('users');

  Future<void> createUserData(String name, String email, String uid) async {
    return await userModel.doc(uid).set({'name': name, 'email': email});
  }

  Future<void> addContact(String uid, Contact contact) async {
    await userModel.doc(uid).collection('contacts').doc().set(contact.toJson());
  }

  Future<void> deleteContact(String uid, Contact contact) async {
    await userModel.doc(uid).collection('contacts').doc(contact.docId).delete();
  }

  Future<void> updateContact(String uid, Contact contact) async {
    await userModel
        .doc(uid)
        .collection('contacts')
        .doc(contact.docId)
        .update(contact.toJson());
  }

  Future getUser(String uid) async {
    final data = await userModel.doc(uid).get();
    return data;
  }

  List<Contact> _contactSnapshot(QuerySnapshot snap) {
    return snap.docs.map((doc) => contactfromJson(doc)).toList();
  }

  Stream<List<Contact>> getContact(String uid) {
    return userModel
        .doc(uid)
        .collection('contacts')
        .orderBy('first_name')
        .snapshots()
        .map(_contactSnapshot);
  }
}
