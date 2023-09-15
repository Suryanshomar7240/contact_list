import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FireBaseApi {
  static UploadTask? uploadFile(String destination, File imageFile) {
    try {
      final storage = FirebaseStorage.instanceFor(
          bucket: "gs://contract-522d7.appspot.com");
      final ref = storage.ref(destination);
      return ref.putFile(File(imageFile.path));
    } on FirebaseException catch (e) {
      return null;
    }
  }
}
