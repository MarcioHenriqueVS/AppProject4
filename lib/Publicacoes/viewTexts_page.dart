import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:teste4/Publicacoes/text_details_page.dart';
import 'Pub_Models.dart';
import 'package:photo_view/photo_view.dart';

import 'Pubs_Services.dart';

class ViewTexts extends StatefulWidget {
  final String topico;

  const ViewTexts({Key? key, required this.topico}) : super(key: key);

  @override
  State<ViewTexts> createState() => _ViewTextsState();
}

class _ViewTextsState extends State<ViewTexts> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController _bodyController = TextEditingController();
  FocusNode _bodyFocusNode = FocusNode();
  bool _isFocused = false;
  bool _isEmpty = true;
  final getPub _getpub = getPub();
  late Future<List<Publicacao>> _publicationsFuture;
  Map<String, Stream<String>> _displayNameCache = {};
  final PubsService pubsService = PubsService();
  Uint8List? _selectedImageBytes;
  String? _selectedImagePath;
  PlatformFile? _selectedImageFile;

  Future<String?> _showMediaTypeDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Escolha o tipo de mídia'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'photo');
                selectImage();
              },
              child: const Text('Foto'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'video');
              },
              child: const Text('Vídeo'),
            ),
          ],
        );
      },
    );
  }

  Future<void> selectImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result == null) return;

    setState(() {
      _selectedImageFile = result.files.first;
      if (kIsWeb) {
        _selectedImageBytes = _selectedImageFile!.bytes;
      } else {
        _selectedImagePath = _selectedImageFile!.path;
      }
    });
    _showCaptionDialog(context);
  }

  Future<void> _showCaptionDialog(BuildContext context) async {
    TextEditingController captionController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    ValueNotifier<bool> isSubmitting = ValueNotifier(false);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar legenda'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                kIsWeb
                    ? Image.memory(
                  _selectedImageBytes!,
                  height: 200,
                  width: 200,
                )
                    : Image.file(
                  File(_selectedImagePath!),
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: captionController,
                  decoration: InputDecoration(labelText: 'Legenda'),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () async {
                _selectedImageFile = null;
                Navigator.of(context).pop();
              },
            ),
            ValueListenableBuilder(
              valueListenable: isSubmitting,
              builder: (context, bool value, child) {
                return TextButton(
                  child: value ? CircularProgressIndicator() : Text('Enviar'),
                  onPressed: value
                      ? null
                      : () async {
                    isSubmitting.value = true;
                    if (captionController.text.trim().isNotEmpty ||
                        _selectedImageFile != null) {
                      String userDisplayName =
                      await displayName(userUid!);
                      var topico = widget.topico;

                      // Aguarde a conclusão do método addPub
                      await PubsService.addPub(
                        captionController,
                        userDisplayName,
                        userUid,
                        topico,
                        _selectedImageFile,
                      );

                      // Limpe o _selectedImageFile após enviar a publicação
                      setState(() {
                        _selectedImageFile = null;
                      });

                      // Aguarde a conclusão do método _onRefresh antes de fechar a caixa de diálogo
                      await _onRefresh();
                      Navigator.of(context).pop();
                    }
                    isSubmitting.value = false;
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _publicationsFuture = _getpub.getPublicationsOnce(widget.topico);
    _bodyFocusNode.addListener(() {
      if (_bodyFocusNode.hasFocus != _isFocused) {
        setState(() {
          _isFocused = _bodyFocusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _bodyFocusNode.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    final userName = user?.displayName;
    var isCurrentUser;
    var topico = widget.topico;

    return Listener(
        onPointerDown: (_) {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(topico),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    _onRefresh();
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                            ),
                            if (userName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(userName),
                              ),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.blueAccent),
                            const SizedBox(height: 5),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      TextSpan textSpan = TextSpan(
                                        text: _bodyController.text,
                                        style: const TextStyle(
                                          fontSize:
                                              16, // use o mesmo tamanho de fonte do TextFormField
                                        ),
                                      );

                                      TextPainter textPainter = TextPainter(
                                        text: textSpan,
                                        maxLines: null,
                                        textScaleFactor: MediaQuery.of(context)
                                            .textScaleFactor,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                      );

                                      textPainter.layout(
                                          maxWidth: constraints.maxWidth -
                                              24); // subtraia a largura das bordas (10 + 10) e o espaçamento interno (4)
                                      double textHeight =
                                          textPainter.size.height;
                                      double minHeight = 60;
                                      double maxHeight = 100;

                                      return Container(
                                        height: min(max(minHeight, textHeight),
                                            maxHeight),
                                        child: TextFormField(
                                          controller: _bodyController,
                                          focusNode: _bodyFocusNode,
                                          maxLines: null,
                                          expands: true,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Digite sua publicação aqui',
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 10.0,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                RawMaterialButton(
                                  onPressed: () async {
                                    //await selectImage();
                                    await _showMediaTypeDialog(context);
                                  },
                                  constraints: const BoxConstraints.expand(
                                      width: 40, height: 40),
                                  child: const Icon(
                                    Icons.attach_file,
                                    color: Colors.grey,
                                    //size: 30,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                RawMaterialButton(
                                  onPressed: () async {
                                    if (_bodyController.text
                                            .trim()
                                            .isNotEmpty ||
                                        _selectedImageFile != null) {
                                      String userDisplayName =
                                          await displayName(userUid!);
                                      var topico = widget.topico;
                                      PubsService.addPub(
                                        _bodyController,
                                        userDisplayName,
                                        userUid,
                                        topico,
                                        _selectedImageFile,
                                      );
                                      await _onRefresh();

                                      // Limpe o _selectedImageFile após enviar a publicação
                                      setState(() {
                                        _selectedImageFile = null;
                                      });
                                    }
                                  },
                                  shape: const CircleBorder(),
                                  fillColor: Colors.blueAccent,
                                  constraints: const BoxConstraints.expand(
                                      width: 40, height: 40),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    //size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<Publicacao>>(
                        future: _publicationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final publicacoes = snapshot.data!;

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: publicacoes.length,
                            itemBuilder: (context, index) {
                              final pub = publicacoes[index];
                              final fotoUrl = pub.fotoUrl;
                              final post = pub.post;
                              final pubId = pub.pubId;
                              final isCurrentUserPost = pub.userUid;
                              final imageUrl = pub.imagem;
                              isCurrentUser = userUid;

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: fotoUrl != null
                                              ? NetworkImage(fotoUrl)
                                              : null,
                                        ),
                                        const SizedBox(
                                          width: 13.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              StreamBuilder<String>(
                                                stream: getDisplayName(
                                                    topico, pubId),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<String>
                                                        snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator(); // Mostra um indicador de progresso enquanto espera pelo valor do displayName
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Erro: ${snapshot.error}'); // Mostra um texto de erro se algo der errado
                                                  } else {
                                                    return Text(
                                                      snapshot.data ??
                                                          'Sem nome',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ); // Mostra o displayName do usuário quando disponível
                                                  }
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                post,
                                                style: const TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              if (imageUrl !=
                                                  null) // Adicione essa condição
                                                GestureDetector(
                                                  onTap: () {
                                                    _showFullImage(
                                                        context, imageUrl);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  TextButton(
                                                    child: const Text(
                                                      'Ver publicação',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              TextDetailsScreen(
                                                                  pub.pubId,
                                                                  widget
                                                                      .topico),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                    width: 20,
                                                  ),
                                                  if (isCurrentUserPost ==
                                                      isCurrentUser)
                                                    Row(
                                                      children: [
                                                        TextButton(
                                                          onPressed: () async {
                                                            bool? shouldDelete =
                                                                await showConfirmationDialog(
                                                                    context);
                                                            if (shouldDelete ??
                                                                false) {
                                                              await PubsService
                                                                  .excluirPublicacao(
                                                                      widget
                                                                          .topico,
                                                                      pubId);
                                                              await _onRefresh();
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Excluir',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ])))));
  }

  Future<void> _onRefresh() async {
    setState(() {
      _displayNameCache.clear();
      _publicationsFuture = _getpub.getPublicationsOnce(widget.topico);
      //_selectedImageFile = null;
    });
    await _publicationsFuture;
  }

  Stream<String> getDisplayName(topico, pubId) {
    if (!_displayNameCache.containsKey(pubId)) {
      _displayNameCache[pubId] = pubsService.mostraDisplayName(topico, pubId);
    }
    return _displayNameCache[pubId]!;
  }
}

Future<bool?> showConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmação"),
        content: Text("Tem certeza que deseja excluir esta publicação?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text("Excluir"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

void _showFullImage(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            //backgroundDecoration: BoxDecoration(color: Colors.transparent),
          ),
        ),
      );
    },
  );
}
