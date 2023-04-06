import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class CriarDesafioService {
  Future<void> addDesafios(String challengeName) async {
    await DesafioDataService.addDesafio(challengeName);
  }
}

class ListaDeDesafiosService {
  Future<List<dynamic>> fetchDesafios() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Desafios').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}

class DesafioDataService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    User? user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  Future<String?> getCurrentUserDisplayName() async {
    User? user = _firebaseAuth.currentUser;
    return user?.displayName;
  }

  Future<Map<String, dynamic>> fetchDocumentData(String nomeDoDesafio, String? uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Desafios')
        .doc(nomeDoDesafio)
        .collection('$uid')
        .get();
    final data = Map<String, dynamic>.fromEntries(snapshot.docs
        .map((doc) => MapEntry(doc.id, doc.data()))
        .where((entry) => entry.value is Map));
    return data;
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
}

class PontosDataService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<String?> getCurrentUserId() async {
    User? user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  Future<String?> getCurrentUserDisplayName() async {
    User? user = _firebaseAuth.currentUser;
    return user?.displayName;
  }

  CollectionReference getCollectionRef(String? uid) {
    return FirebaseFirestore.instance.collection('Pontuação dos desafios')
        .doc('Pontuação dos usuários')
        .collection('$uid');
  }
}

class FeedDataService {
  Stream<QuerySnapshot> getFeedStream() {
    return FirebaseFirestore.instance
        .collection('feedDesafio')
        .orderBy('Timestamp', descending: true)
        .snapshots();
  }
}

class fetchDoc {
  Future<void> fetchDocumentData(
      String nomeDoDesafio, String uid, Function(Map<String, dynamic>) onDone) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Desafios')
        .doc(nomeDoDesafio)
        .collection(uid)
        .get();
    final data = Map<String, dynamic>.fromEntries(snapshot.docs
        .map((doc) => MapEntry(doc.id, doc.data()))
        .where((entry) => entry.value is Map));
    onDone(data);
  }

  void getCurrentUser(Function(String?, String?) onDone) async {
    User? user = FirebaseAuth.instance.currentUser;
    onDone(user?.uid, user?.displayName);
  }
}

class DateTimeService {
  List<DateTime> getWeekDays() {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local).toLocal();
    return List.generate(
        7,
            (i) => tz.TZDateTime(
            tz.local, now.year, now.month, now.day - now.weekday + i));
  }
}

