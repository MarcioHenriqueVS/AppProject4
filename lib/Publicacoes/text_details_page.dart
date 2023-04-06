import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Pub_Models.dart';
import 'Pubs_Services.dart';
import 'Coments_Services.dart';

class TextDetailsScreen extends StatefulWidget {
  final String documentId;
  final String topico;

  const TextDetailsScreen(this.documentId, this.topico);

  @override
  _TextDetailsScreenState createState() => _TextDetailsScreenState();
}

class _TextDetailsScreenState extends State<TextDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  TextDetailsService textDetailsService = TextDetailsService();
  Map<String, Stream<String>> _displayNameCache = {};
  final PubsService pubsService = PubsService();
  CommentsService commentsService = CommentsService();
  late Future<List<Publicacao>> _publicationsFuture;
  final getPub _getpub = getPub();
  FocusNode _bodyFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    getDisplayName(widget.topico, widget.documentId);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    return Listener(
        onPointerDown: (_) {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Detalhes da publicação'),
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
                  child: Center(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: textDetailsService.getTextDetailsStream(
                          widget.topico, widget.documentId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        DocumentSnapshot document = snapshot.data!;
                        final autor = document['Autor'];
                        final post = document['Post'];
                        final photoUrl = document['FotoUrl'];

                        return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(photoUrl),
                                      ),
                                      const SizedBox(width: 8.0),
                                      StreamBuilder<String>(
                                          stream: getDisplayName(
                                              widget.topico, widget.documentId),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<String> snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator(); // Mostra um indicador de progresso enquanto espera pelo valor do displayName
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Erro: ${snapshot.error}'); // Mostra um texto de erro se algo der errado
                                            } else {
                                              return Text(
                                                snapshot.data ?? 'Sem nome',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: Colors.grey[600],
                                                ),
                                              );
                                            }
                                          }),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Text(
                                    post,
                                    style: const TextStyle(fontSize: 20.0),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'Adicionar Comentário',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: LayoutBuilder(
                                              builder: (BuildContext context,
                                                  BoxConstraints constraints) {
                                                TextSpan textSpan = TextSpan(
                                                  text: _commentController.text,
                                                  style: const TextStyle(
                                                    fontSize:
                                                        16, // use o mesmo tamanho de fonte do TextFormField
                                                  ),
                                                );

                                                TextPainter textPainter =
                                                    TextPainter(
                                                  text: textSpan,
                                                  maxLines: null,
                                                  textScaleFactor:
                                                      MediaQuery.of(context)
                                                          .textScaleFactor,
                                                  textAlign: TextAlign.left,
                                                  textDirection:
                                                      TextDirection.ltr,
                                                );

                                                double availableWidth =
                                                    constraints.maxWidth -
                                                        40 -
                                                        10;
                                                textPainter.layout(
                                                    maxWidth: availableWidth);
                                                double textHeight =
                                                    textPainter.size.height;
                                                double minHeight = 60;
                                                double maxHeight = 100;

                                                return Container(
                                                  height: min(
                                                      max(minHeight,
                                                          textHeight),
                                                      maxHeight),
                                                  child: TextFormField(
                                                    controller:
                                                        _commentController,
                                                    focusNode: _bodyFocusNode,
                                                    maxLines: null,
                                                    expands: true,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          'Digite seu comentário',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10.0,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          RawMaterialButton(
                                            onPressed: () async{
                                             await CommentsService.addComment(
                                                  _commentController,
                                                  widget.documentId,
                                                  widget.topico);
                                             await _onRefresh();
                                            },
                                            shape: CircleBorder(),
                                            fillColor: Colors.blueAccent,
                                            constraints:
                                                const BoxConstraints.expand(
                                                    width: 40, height: 40),
                                            child: const Icon(
                                              Icons.send,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: commentsService.getCommentsStream(
                                        widget.topico, widget.documentId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox();
                                      }

                                      final comentarios = snapshot.data!.docs;

                                      if (comentarios.isEmpty) {
                                        return const Text(
                                            'Nenhum comentário ainda');
                                      }

                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: comentarios.length,
                                        itemBuilder: (context, index) {
                                          final comentario = comentarios[index];
                                          final comentarioId = comentario.id;
                                          final isCurrentUserPost =
                                              comentario['User uid'];
                                          final isCurrentUser = userUid;

                                          return Card(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (comentario['FotoUrl'] !=
                                                      null)
                                                    CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              comentario[
                                                                  'FotoUrl']),
                                                    ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        StreamBuilder<String>(
                                                            stream: getDisplayName(
                                                                widget.topico,
                                                                widget
                                                                    .documentId),
                                                            builder: (BuildContext
                                                                    context,
                                                                AsyncSnapshot<
                                                                        String>
                                                                    snapshot) {
                                                              if (snapshot
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .waiting) {
                                                                return CircularProgressIndicator(); // Mostra um indicador de progresso enquanto espera pelo valor do displayName
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    'Erro: ${snapshot.error}'); // Mostra um texto de erro se algo der errado
                                                              } else {
                                                                return Text(
                                                                  snapshot.data ??
                                                                      'Sem nome',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14.0,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                  ),
                                                                );
                                                              }
                                                            }),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          comentario[
                                                              'Comentário'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                                                              await CommentsService
                                                                  .excluirComentario(
                                                                      widget
                                                                          .topico,
                                                                      widget
                                                                          .documentId,
                                                                      comentarioId);
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
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                ],
                              ),
                            ));
                      },
                    ),
                  ),
                ))));
  }

  Stream<String> getDisplayName(topico, pubId) {
    if (!_displayNameCache.containsKey(pubId)) {
      _displayNameCache[pubId] = pubsService.mostraDisplayName(topico, pubId);
    }
    return _displayNameCache[pubId]!;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _displayNameCache.clear();
      _publicationsFuture = _getpub.getPublicationsOnce(widget.topico);
    });
    await _publicationsFuture;
  }
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
