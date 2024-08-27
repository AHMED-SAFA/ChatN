import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();

  MediaService() {}

  Future<File?> getImageFromGallery() async {
    final XFile? _file =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (_file != null) return File(_file.path);
    return null;
  }





  Future<String> uploadImageToStorage(File image, String userId) async {
    Reference ref = FirebaseStorage.instance.ref().child('user_images/$userId.jpg');
    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }
}
