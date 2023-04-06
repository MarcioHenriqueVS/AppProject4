import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'Cadastro_Model.dart';

class CadastroService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> cadastrar(UserModel userModel, userName) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: userModel.email, password: userModel.senha);
      if (userCredential != null) {
        await addName(userName);
        await userCredential.user!.updateEmail(userModel.email);

        // Carrega a imagem como um Uint8List
        Uint8List imageData = (await rootBundle.load(
            'assets/images/fotoDePerfilNull.jpg')).buffer.asUint8List();

        // Cria uma referência no Firebase Storage com o uid do usuário
        final uid = userCredential.user!.uid;
        final storageReference = FirebaseStorage.instance.ref().child(
            'profileImages/$uid');

        // Envia a imagem para o Firebase Storage
        final uploadTask = storageReference.putData(
            imageData, SettableMetadata(contentType: 'image/jpeg'));

        // Obtem a URL de download após o upload ser concluído
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Atualiza a foto do perfil do usuário
        await userCredential.user!.updatePhotoURL(downloadUrl);

        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }
  static Future<void> addName(userName) async {
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

class ChecagemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?> checarUsuario(Function(String) onResult) {
    return FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firestore
          .collection("admin")
          .doc("adminLogin")
          .snapshots()
          .forEach((element) {
        if (element.data()?['adminEmail'] == user?.email) {
          onResult('admin');
        } else if (user == null) {
          onResult('login');
        } else {
          onResult('home');
        }
      });
    });
  }
}

class LoginService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      return null;
    }
  }
}

class ForgotPasswordService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }
}
