import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileDataService {
  final User _user = FirebaseAuth.instance.currentUser!;

  Future<void> updateDisplayName(String newDisplayName) async {
    await _user.updateDisplayName(newDisplayName);
  }

  Future<void> updatePhotoURL(String photoUrl) async {
    await _user.updatePhotoURL(photoUrl);
  }

  Future<String> uploadImage(Uint8List bytes) async {
    final storageRef = FirebaseStorage.instance.ref('profileImages/${_user.uid}');
    final uploadTask = storageRef.putData(bytes);

    final snapshot = await uploadTask.whenComplete(() => null);
    final photoUrl = await snapshot.ref.getDownloadURL();

    return photoUrl;
  }
  Future<void> addName(userName) async {
    final user = await FirebaseAuth.instance.currentUser;
    String? uid;
    uid = user?.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('User Name')
        .doc(uid)
        .collection('Nome')
        .where('Nome', isEqualTo: userName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Já existe um documento com a mesma data
      return;
    }

    await FirebaseFirestore.instance
        .collection('User Name')
        .doc(uid)
        .collection('Nome')
        .doc(uid)
        .set({
      'Nome': userName,
    });
    if (user != null) {
      await user.updateDisplayName(userName);
      await user.reload();
    }
  }
}
