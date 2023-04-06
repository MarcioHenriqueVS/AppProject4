import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'Videos_Services.dart';

class EnviarVideo extends StatefulWidget {
  final String tema;

  const EnviarVideo(this.tema, {Key? key}) : super(key: key);

  @override
  State<EnviarVideo> createState() => _EnviarVideoState();
}

class _EnviarVideoState extends State<EnviarVideo> {
  PlatformFile? pickedFile;
  PlatformFile? thumbnailFile;
  String? nomeDoVideo;
  VideoUploadService videoUploadService = VideoUploadService();

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future selectThumbnail() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) return;
    setState(() {
      thumbnailFile = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar vídeos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Text(
                'Arquivo: ${pickedFile!.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            if (thumbnailFile != null)
              Text(
                'Thumbnail: ${thumbnailFile!.name}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
            const SizedBox(height: 5),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nome do vídeo'),
              onChanged: (value) => nomeDoVideo = value,
            ),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: selectFile, child: Text('Selecionar arquivo')),
            ElevatedButton(
                onPressed: selectThumbnail,
                child: Text('Selecionar thumbnail')),
            ElevatedButton(
              onPressed: () {
                videoUploadService
                    .uploadFile(
                        nomeDoVideo, pickedFile, thumbnailFile, widget.tema)
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Arquivo enviado com sucesso'),
                    duration: Duration(seconds: 3),
                  ));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Ocorreu um erro ao enviar o arquivo: $error'),
                    duration: Duration(seconds: 3),
                  ));
                });
              },
              child: Text('Enviar arquivo'),
            ),
          ],
        ),
      ),
    );
  }
}
