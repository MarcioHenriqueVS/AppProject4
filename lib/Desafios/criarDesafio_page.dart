import 'package:flutter/material.dart';

import 'Desafios_Services.dart';

class CriarDesafio extends StatefulWidget {
  const CriarDesafio({Key? key}) : super(key: key);

  @override
  State<CriarDesafio> createState() => _CriarDesafioState();
}

class _CriarDesafioState extends State<CriarDesafio> {
  CriarDesafioService _criarDesafioService = CriarDesafioService();
  TextEditingController nomeDoDesafio = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar desafio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
                controller: nomeDoDesafio,
                decoration: InputDecoration(
                    labelText: 'Nome do desafio',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: () async {
                submitChallenge();
              },
              child: Text('Enviar arquivo'),
            ),
          ],
        ),
      ),
    );
  }

  submitChallenge() async {
    await _criarDesafioService.addDesafios(nomeDoDesafio.text);
    nomeDoDesafio.clear();
  }
}
