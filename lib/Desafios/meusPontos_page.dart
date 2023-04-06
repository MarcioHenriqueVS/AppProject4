import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Desafios_Services.dart';

class MeusPontos extends StatelessWidget {
  final PontosDataService _pontosDataService = PontosDataService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _pontosDataService.getCurrentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        final uid = snapshot.data;
        final collectionRef = _pontosDataService.getCollectionRef(uid);

        return Scaffold(
          appBar: AppBar(
            title: Text("Pontos"),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: collectionRef.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Erro ao carregar dados");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // Contagem total de documentos
              int totalDocs = snapshot.data!.docs.length;

              return Center(
                child: Text(
                  "Você tem $totalDocs ponto(s).",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24.0),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
