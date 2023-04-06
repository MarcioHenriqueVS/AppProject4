import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideosService {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getVideoStream(String tema) {
    return firestore
        .collection('Temas dos vídeos')
        .doc(tema)
        .collection('Vídeos')
        .snapshots();
  }

  Future<VideoPlayerController> getVideoPlayerController(String url) async {
    final videoPlayerController = VideoPlayerController.network(url);
    videoPlayerController.initialize();
    return videoPlayerController;
  }
}

class TemasService {
  Future<void> addTheme(String themeName) async {
    await TemasService.addTema(themeName);
  }
  static addTema(String tema) async {
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
}

class VideoUploadService {
  Future<void> uploadFile(
      String? nomeDoVideo,
      PlatformFile? pickedFile,
      PlatformFile? thumbnailFile,
      String tema) async {
    final user = FirebaseAuth.instance.currentUser;
    final nome = user?.displayName ?? 'unknown';
    final videoPath = 'videos/$nome/$nomeDoVideo.mp4';
    final thumbnailPath = 'videos/$nome/thumbnails/$nomeDoVideo.jpg';

    final videoRef = FirebaseStorage.instance.ref().child(videoPath);
    final thumbnailRef = FirebaseStorage.instance.ref().child(thumbnailPath);

    TaskSnapshot videoSnapshot;
    TaskSnapshot thumbnailSnapshot;

    if (kIsWeb) {
      videoSnapshot = await videoRef.putData(pickedFile!.bytes!);
      thumbnailSnapshot = await thumbnailRef.putData(thumbnailFile!.bytes!);
    } else {
      final videoFile = File(pickedFile!.path!);
      final thumbnail = File(thumbnailFile!.path!);
      videoSnapshot = await videoRef.putFile(videoFile);
      thumbnailSnapshot = await thumbnailRef.putFile(thumbnail);
    }

    final videoDownloadUrl = await videoSnapshot.ref.getDownloadURL();
    final thumbnailDownloadUrl = await thumbnailSnapshot.ref.getDownloadURL();

    var id = DateTime.now().microsecondsSinceEpoch.toString();
    final documentRef = FirebaseFirestore.instance
        .collection('Temas dos vídeos')
        .doc(tema)
        .collection('Vídeos')
        .doc(id);
    await documentRef.set({
      'url': videoDownloadUrl,
      'thumbnailUrl': thumbnailDownloadUrl,
      'nomeDoVideo': nomeDoVideo,
    });
  }
}

class TemasListaService {
  Future<List<dynamic>> fetchTemas() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('Temas dos vídeos').get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}