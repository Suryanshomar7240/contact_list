import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  String? firstName;
  String? docId;
  String? lastName;
  String? companyName;
  String? image;
  Phoneclass? phone;
  String? email;
  Contact(
      {this.firstName,
      this.lastName,
      this.companyName,
      this.image,
      this.phone,
      this.email,
      this.docId});

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'image': image,
      'email':email,
      'phone': phone == null ? null : phone!.toJson()
    };
  }
}

Contact contactfromJson(DocumentSnapshot data) {
  return Contact(
      docId: data.id,
      firstName: data.get('first_name'),
      lastName: data.get('last_name'),
      companyName: data.get('company_name'),
      image: data.get('image'),
      email: data.get('email'),
      phone: phoneClassfromJson(data.get('phone')));
}

class Phoneclass {
  String phoneType;
  String phoneNumber;
  Phoneclass({required this.phoneType, required this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {'phone_type': phoneType, 'phone_number': phoneNumber};
  }
}

Phoneclass phoneClassfromJson(data) {
  return Phoneclass(
      phoneType: data['phone_type'], phoneNumber: data['phone_number']);
}
