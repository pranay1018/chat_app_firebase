import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class StorageService {
  StorageService() {}

  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String?> uploadUserPfp({required File file, required String uid}) async {
    Reference fileRef = await _firebaseStorage
        .ref('users/pfps')
        .child('$uid${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then(
          (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }

  Future<String?> uploadImageToChat({required File file, required String chatId}) async {
    Reference fileRef = await _firebaseStorage
        .ref('chats/$chatId')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');
    UploadTask task = fileRef.putFile(file);
    return task.then(
          (p) {
        if (p.state == TaskState.success) {
          return fileRef.getDownloadURL();
        }
      },
    );
  }
}
