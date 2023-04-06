
import 'package:flutter/material.dart';

import 'Videos_Services.dart';

class CriarTema extends StatefulWidget {
  const CriarTema({Key? key}) : super(key: key);

  @override
  State<CriarTema> createState() => _CriarTemaState();
}

class _CriarTemaState extends State<CriarTema> {
  TextEditingController tema = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar tema para vídeos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
                controller: tema,
                decoration: InputDecoration(
                    labelText: 'Tema',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: () async {
                await TemasService.addTema(tema.text);
                tema.clear();
              },
              child: Text('Enviar tema'),
            ),
          ],
        ),
      ),
    );
  }
}
