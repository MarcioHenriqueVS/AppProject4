
import 'package:flutter/material.dart';

import 'Videos_Services.dart';
import 'listVideos.dart';

class TemasListScreen extends StatefulWidget {
  @override
  _TemasListScreenState createState() => _TemasListScreenState();
}

class _TemasListScreenState extends State<TemasListScreen> {
  List<dynamic> _temas = [];
  bool _isLoading = true;
  final TemasListaService temasService = TemasListaService();

  @override
  void initState() {
    super.initState();
    fetchTemas();
  }

  Future<void> fetchTemas() async {
    try {
      final temas = await temasService.fetchTemas();
      setState(() {
        _temas = temas;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Widget buildDesafioCard(dynamic tema) {
    return Card(
      child: ListTile(
        title: Text(tema['Tema']),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoScreen(tema: tema['Tema']),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _temas.length,
        itemBuilder: (context, index) {
          return buildDesafioCard(_temas[index]);
        },
      ),
    );
  }
}
