import 'package:file_picker/file_picker.dart';

class Publicacao {
  final String autor;
  final String? fotoUrl;
  final String post;
  final String pubId;
  final String userUid;
  final String? imagem;

  Publicacao({
    required this.autor,
    this.fotoUrl,
    required this.post,
    required this.pubId,
    required this.userUid,
    this.imagem,
  });

  // Método para converter os dados do documento Firestore em um objeto Publicacao
  factory Publicacao.fromFirestore(Map<String, dynamic> data, String id) {
    return Publicacao(
      autor: data['Autor'],
      fotoUrl: data['FotoUrl'],
      post: data['Post'],
      pubId: id,
      userUid: data['User uid'],
      imagem: data['Imagem']
    );
  }
}