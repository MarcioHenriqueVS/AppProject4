import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'Videos_Services.dart';
import 'enviarVideo_page.dart';

class VideoScreen extends StatefulWidget {
  final String tema;

  const VideoScreen({Key? key, required this.tema}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<int, double> downloadProgress = {};
  late String titulo;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final VideosService videosService = VideosService();
    return Scaffold(
        appBar: AppBar(
          title: Text('Vídeos'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                    (context),
                    MaterialPageRoute(
                        builder: (context) => EnviarVideo(widget.tema)));
              },
              child: const Text(
                'Adicionar vídeo',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: videosService.getVideoStream(widget.tema),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final videos = snapshot.data!.docs;

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (BuildContext context, int index) {
                final titulo = videos[index]['nomeDoVideo'];
                final url = videos[index]['url'];
                final thumbnailUrl = videos[index]['thumbnailUrl'];

                return GestureDetector(
                  onTap: () async {
                    final videoPlayerController =
                    await videosService.getVideoPlayerController(url);
                    videoPlayerController.initialize();
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => Scaffold(
                          appBar: AppBar(
                            title: Text('video'),
                          ),
                          body: Center(
                            child: AspectRatio(
                              aspectRatio:
                                  videoPlayerController.value.aspectRatio,
                              child: Chewie(
                                controller: ChewieController(
                                  videoPlayerController: videoPlayerController,
                                  autoPlay: true,
                                  looping: false,
                                  autoInitialize: true,
                                  fullScreenByDefault: true,
                                  materialProgressColors: ChewieProgressColors(
                                    playedColor: Colors.red,
                                    handleColor: Colors.redAccent,
                                    backgroundColor: Colors.grey,
                                    bufferedColor: Colors.white,
                                  ),
                                  placeholder: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    videoPlayerController.dispose();
                  },
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (thumbnailUrl != null)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              // ajuste a proporção desejada
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  thumbnailUrl,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),
                          SizedBox(height: 8.0),
                          Row(
                            children: [
                              Icon(Icons.play_arrow),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titulo,
                                      style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
