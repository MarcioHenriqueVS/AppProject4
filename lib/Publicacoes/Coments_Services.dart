import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCommentsStream(String topico, String documentId) {
    return _firestore
        .collection('Tópicos')
        .doc(topico)
        .collection('Publicação')
        .doc(documentId)
        .collection('Comentários')
        .orderBy('Timestamp', descending: true)
        .snapshots();
  }

  Future<bool?> showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmação"),
          content: const Text("Tem certeza que deseja excluir este comentário?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Excluir"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
  static Future<void> addComment(
      TextEditingController commentController, documentId, topico) async {
    // Adicionar parâmetro topico aqui
    final comment = commentController.text.trim();
    if (comment.isNotEmpty) {
      final user = await FirebaseAuth.instance.currentUser;
      final photoUrl = user?.photoURL;
      final autor = user?.displayName;
      final uid = user?.uid;
      var id = DateTime.now().microsecondsSinceEpoch.toString();
      final commentReference = FirebaseFirestore.instance
          .collection('Tópicos')
          .doc(topico)
          .collection('Publicação')
          .doc(documentId)
          .collection('Comentários')
          .doc(id);

      await commentReference.set({
        'Comentário': comment,
        'Timestamp': Timestamp.now(),
        'Autor': autor,
        'FotoUrl': photoUrl,
        'Id': id,
        'User uid': uid,
      });

      commentController.clear();
    }
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
}
