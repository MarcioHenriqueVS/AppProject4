import 'package:flutter/material.dart';
import 'DesafiosList_Model.dart';
import 'Desafios_Services.dart';
import 'desafios.dart';

class DesafioListScreen extends StatefulWidget {
  @override
  _DesafioListScreenState createState() => _DesafioListScreenState();
}

class _DesafioListScreenState extends State<DesafioListScreen> {
  List<Desafio> _desafios = [];
  bool _isLoading = true;
  ListaDeDesafiosService _listaDeDesafiosService = ListaDeDesafiosService();

  @override
  void initState() {
    super.initState();
    fetchDesafios();
  }

  Future<void> fetchDesafios() async {
    final desafios = await _listaDeDesafiosService.fetchDesafios();

    setState(() {
      _desafios = desafios.map((e) => Desafio.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Widget buildDesafioCard(Desafio desafio) {
    return Card(
      child: ListTile(
        title: Text(desafio.nome),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Desafios(desafioNome: desafio.nome),
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
        title: Text('Lista de Desafios'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _desafios.length,
        itemBuilder: (context, index) {
          return buildDesafioCard(_desafios[index]);
        },
      ),
    );
  }
}
