import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Desafios_Services.dart';

class ViewFeedDesafio extends StatefulWidget {
  const ViewFeedDesafio({Key? key}) : super(key: key);

  @override
  State<ViewFeedDesafio> createState() => _ViewFeedDesafioState();
}

class _ViewFeedDesafioState extends State<ViewFeedDesafio> {

  final FeedDataService _feedDataService = FeedDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed de pontuação'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _feedDataService.getFeedStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final publicacoes = snapshot.data!.docs;

          return ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: publicacoes.length,
            itemBuilder: (context, index) {
              final pub = publicacoes[index];
              final autor = pub['Autor'];
              final fotoUrl = pub['FotoUrl'];
              final post = pub['Post'];

              return GestureDetector(
                onTap: () {},
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                          fotoUrl != null ? NetworkImage(fotoUrl) : null,
                        ),
                        const SizedBox(width: 15.0,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              Text(
                                post,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
