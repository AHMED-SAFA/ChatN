import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _file =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (_file != null) return File(_file.path);
    return null;
  }

  //save to firestore
  Future<String> uploadImageToStorage(File image, String userId) async {
    Reference ref = firebaseStorage
        .ref('users/profile_images')
        .child('$userId${p.extension(image.path)}');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> uploadImageToStorageFromChatUpload(
      {required File file, required String chatId}) async {
    Reference fileRef = firebaseStorage
        .ref('chats/$chatId')
        .child('${DateTime.now().toIso8601String()}${p.extension(file.path)}');

    UploadTask task = fileRef.putFile(file);
    return task.then((p) {
      if (p.state == TaskState.success) {
        return fileRef.getDownloadURL();
      }
    });
  }
}

// TaskSnapshot snapshot = await task;
// return await snapshot.ref.getDownloadURL();
