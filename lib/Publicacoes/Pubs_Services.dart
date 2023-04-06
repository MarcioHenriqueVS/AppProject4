import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'Pub_Models.dart';
import 'package:flutter/material.dart';

class PubsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static addTopico(String topico) async {
    // Modifique o parâmetro para String
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Tópicos')
        .where('Tópico', isEqualTo: topico)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Já existe um tópico com o mesmo nome
      return;
    }
    await FirebaseFirestore.instance.collection('Tópicos').doc(topico).set({
      'Tópico': topico,
    });
  }

  static addPub(Body, autor, uid, topico, PlatformFile? imageFile) async {
    final user = await FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    var id = DateTime.now().microsecondsSinceEpoch.toString();

    String? imageUrl;

    if (imageFile != null) {
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('images/${user?.uid}/posts/$id.jpg');

      late TaskSnapshot snapshot;
      if (kIsWeb) {
        snapshot = await imageRef.putData(imageFile.bytes!);
      } else {
        final imageFileMobile = File(imageFile.path!);
        snapshot = await imageRef.putFile(imageFileMobile);
      }
      imageUrl = await snapshot.ref.getDownloadURL();
    }

    var data = {
      'Id': id,
      'User uid': uid,
      'Post': '${Body.text}',
      'Autor': autor,
      'FotoUrl': photoUrl,
      'Timestamp': FieldValue.serverTimestamp()
    };

    if (imageUrl != null) {
      data['Imagem'] = imageUrl;
    }

    await FirebaseFirestore.instance
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .doc(id)
        .set(data);

    Body.clear();
  }

  static excluirPublicacao(topico, String publicacaoId) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserUid = user!.uid;

    final publicacaoRef = FirebaseFirestore.instance
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .doc(publicacaoId);

    final publicacaoSnapshot = await publicacaoRef.get();
    final autorUid = publicacaoSnapshot['User uid'];

    if (currentUserUid == autorUid) {
      await publicacaoRef.delete();
    } else {
      // Aqui você pode exibir uma mensagem informando que o usuário não tem permissão para excluir esta publicação.
    }
  }

  Stream<String> mostraDisplayName(topico, pubId) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    return FirebaseFirestore.instance
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .doc(pubId)
        .snapshots()
        .asyncMap((pubSnapshot) async {
      final userUid = pubSnapshot.data()?['User uid'];

      final docSnapshot = await FirebaseFirestore.instance
          .collection('User Name')
          .doc(userUid)
          .collection('Nome')
          .doc(userUid)
          .get();

      return docSnapshot.data()?['Nome'] ?? 'Sem nome';
    });
  }
}
class TopicoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<dynamic>> fetchTopicos() async {
    final querySnapshot = await _firestore.collection('Tópicos').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}

class TextDetailsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getTextDetailsStream(
      String topico, String documentId) {
    return _firestore
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .doc(documentId)
        .snapshots();
  }
}

Future<String> displayName(String uid) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = _auth.currentUser;
  String userName;

// Busca o valor do campo 'Nome' do banco de dados
  final docSnapshot = await FirebaseFirestore.instance
      .collection('User Name')
      .doc(uid)
      .collection('Nome')
      .doc(uid)
      .get();

  userName = docSnapshot.data()?['Nome'];
  return userName.toString();
}

Future<void> fetchData(streamController, topico) async {

  QuerySnapshot updatedData = await FirebaseFirestore.instance
      .collection('Tópicos')
      .doc(topico)
      .collection('Publicação')
      .orderBy('Timestamp', descending: true)
      .get();

  return streamController.add(updatedData);
}

class getPub {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot> getPublicationsStream(String topico) {
    return _firestore
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .orderBy('Timestamp', descending: true)
        .snapshots();
  }
  Future<List<Publicacao>> getPublicationsOnce(String topico) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .orderBy('Timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Publicacao.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
