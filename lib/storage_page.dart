import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'Home/home_page.dart';


class StoragePage extends StatefulWidget {
  const StoragePage({Key? key}) : super(key: key);

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  final _firebaseAuth = FirebaseAuth.instance;
  String? _uid;
  Reference? refs;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  final FirebaseStorage storage = FirebaseStorage.instance;
  bool uploading = false;
  double total = 0;
  String? arquivo;
  bool loading = true;
  late Future<ListResult> futureFiles;
  Map<int, double> downloadProgress = {};


  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    final path = 'videos/${_uid}/video.mp4';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    final firestore = FirebaseFirestore.instance;
    final documentRef = firestore.collection('videos').doc();
    await documentRef.set({'url': downloadUrl});
  }

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<UploadTask> upload(String path) async {
    File file = File(path);
    try {
      String ref = 'profileImages/${_uid.toString()}';
      return storage.ref(ref).putFile(file);
    } on FirebaseException catch (e) {
      throw Exception('Erro no upload: ${e.code}');
    }
  }

  pickAndUploadImage() async {
    _getCurrentUser();
    XFile? file = await getImage();
    if (file != null) {
      UploadTask task = await upload(file.path);

      task.snapshotEvents.listen((TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.running) {
          setState(() {
            uploading = true;
            total = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          });
        } else if (snapshot.state == TaskState.success) {
          setState(() {
            uploading = false;
          });
          _firebaseAuth.currentUser?.updatePhotoURL(arquivo);
          await _firebaseAuth.currentUser?.updatePhotoURL(arquivo);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomePage(profileImageUrl: arquivo),
            ),
          );
        }
      });
    }
  }

  @override
  initState() {
    super.initState();
    _getCurrentUser();
    loadImages();
    futureFiles = FirebaseStorage.instance.ref('/videos').listAll();
  }

  void _getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    setState(() {
      _uid = user?.uid;
    });
  }

  loadImages() async {
    refs = (storage.ref('profileImages').child(_uid.toString()));
    arquivo = (await refs?.getDownloadURL());
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: uploading
            ? const Text('enviando...')
            : const Text('Firebase storage'),
        actions: [
          uploading
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: pickAndUploadImage, icon: const Icon(Icons.upload))
        ],
        elevation: 0,
      ),
      body: /*Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(pickedFile!.name),
                  ),
                ),
              ),
            const SizedBox(
              height: 32,
            ),
            ElevatedButton(
                onPressed: selectFile, child: Text('Selecionar arquivo')),
            ElevatedButton(
                onPressed: uploadFile, child: Text('Enviar arquivo')),*/
            FutureBuilder<ListResult>(
              future: futureFiles,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final files = snapshot.data!.items;
                  return ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) {
                      final file = files[index];
                      double? progress = downloadProgress[index];
                      return ListTile(
                        title: Text(file.name),
                        subtitle: progress != null ? LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black,
                        ) : null,
                        trailing: IconButton(
                          icon: Icon(Icons.download),
                          color: Colors.black,
                          onPressed: () => downloadFile(index, file),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Um erro ocorreu'),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
         /* ],
        ),
      ),*/
    );
  }

  Future<void> openFile(String filePath) async {
    final File file = File(filePath);
    final bool exists = await file.exists();
    if (exists) {
      OpenFile.open(filePath);
    }
  }

  Future downloadFile(int index, Reference ref) async {
    final url = await ref.getDownloadURL();
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${ref.name}';
    await Dio().download(
        url,
        path,
    onReceiveProgress: (received, total){
          double progress = received / total;

          setState(() {
            downloadProgress[index] = progress;
          });
    });

    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path);
    } else if (url.contains('.pdf')) {
      await openFile(path);
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Download ${ref.name}')));
  }
}