import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Fireservices {
  final _firebaseAuth = FirebaseAuth.instance;
  String? _uid;
  String? autor;
  String? fotourl;

  Future<String?> getCurrentUserUID() async {
    final user = await _firebaseAuth.currentUser;
    _uid = user?.uid;
    autor = user?.displayName;
  }

  static Future<void> addData(nomeDoDesafio, autor) async {
    var data = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String dataString = data.toString();
    final user = await FirebaseAuth.instance.currentUser;
    String? uid;
    uid = user?.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Desafios')
        .doc(nomeDoDesafio)
        .collection(uid!)
        .where('Data', isEqualTo: dataString)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Já existe um documento com a mesma data
      return;
    }

    var id = DateFormat('yyyy-MM-dd')
        .format(DateTime.now()/*.subtract(Duration(days: 1))*/);
    String idString = id.toString();

    await FirebaseFirestore.instance
        .collection('Desafios')
        .doc(nomeDoDesafio)
        .collection(uid)
        .doc(idString)
        .set({
      'Id': id,
      'Autor': autor,
      'concluido': true,
      'Data': dataString,
    });
  }

  static Future<void> addFeed() async {
    final user = await FirebaseAuth.instance.currentUser;
    String? autor;
    String? uid;
    uid = user?.uid;
    autor = user?.displayName;
    var data = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String dataString = data.toString();
    final photoUrl = user?.photoURL;

    // Obtém a lista de desafios
    final desafiosSnapshot = await FirebaseFirestore.instance
        .collection('Pontuação dos desafios')
        .doc('Pontuação dos usuários')
        .collection('$uid')
        .get();
    final desafios = desafiosSnapshot.docs.map((doc) => doc.id).toList();

    // Conta o número total de documentos para um usuário em todos os desafios
    int numDocs = desafiosSnapshot.docs.length;

    final docId = '$uid-$dataString';
    final querySnapshot = await FirebaseFirestore.instance
        .collection('feedDesafio')
        .doc(docId)
        .get();

    if (querySnapshot.exists) {
      // Já existe um documento com a mesma data
      return;
    }

    await FirebaseFirestore.instance.collection('feedDesafio').doc(docId).set({
      'Post': "$autor tem $numDocs ponto(s).",
      'Autor': autor,
      'FotoUrl': photoUrl,
      'Timestamp': DateTime.now(),
      'Data': dataString
    });
  }

  static Future<void> excluirComentario(
      topico, String publicacaoId, String comentarioId) async {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserUid = user!.uid;

    final comentarioRef = FirebaseFirestore.instance
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .doc(publicacaoId)
        .collection('Comentários')
        .doc(comentarioId);

    final comentarioSnapshot = await comentarioRef.get();
    final autorUid = comentarioSnapshot['User uid'];

    if (currentUserUid == autorUid) {
      await comentarioRef.delete();
    } else {
      // Aqui você pode exibir uma mensagem informando que o usuário não tem permissão para excluir este comentário.
    }
  }

  static addDesafio(String nomeDoDesafio) async {
    // Modifique o parâmetro para String
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Desafios')
        .where('Nome do desafio', isEqualTo: nomeDoDesafio)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Já existe um desafio com o mesmo nome
      return;
    }
    await FirebaseFirestore.instance
        .collection('Desafios')
        .doc(nomeDoDesafio)
        .set({
      'Nome do desafio': nomeDoDesafio,
    });
  }

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

  static addTema(String tema) async {
    // Modifique o parâmetro para String
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Temas dos vídeos')
        .where('Tema', isEqualTo: tema)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Já existe um tópico com o mesmo nome
      return;
    }
    await FirebaseFirestore.instance
        .collection('Temas dos vídeos')
        .doc(tema)
        .set({
      'Tema': tema,
    });
  }

  static addPonto() async {
    final user = FirebaseAuth.instance.currentUser;
    String? uid;
    uid = user?.uid;
    var data = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String dataString = data.toString();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('Pontuação dos desafios')
        .doc('Pontuação dos usuários')
        .collection('$uid')
        .where('Data', isEqualTo: dataString)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Já existe um tópico com o mesmo nome
      return;
    }

    await FirebaseFirestore.instance
        .collection('Pontuação dos desafios')
        .doc('Pontuação dos usuários')
        .collection('$uid')
        .doc(dataString)
        .set({
      'Data': dataString,
    });
  }
}
