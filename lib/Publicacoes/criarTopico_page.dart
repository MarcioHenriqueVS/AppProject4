
import 'package:flutter/material.dart';

import 'Pubs_Services.dart';

class CriarTopico extends StatefulWidget {
  const CriarTopico({Key? key}) : super(key: key);

  @override
  State<CriarTopico> createState() => _CriarTopicoState();
}

class _CriarTopicoState extends State<CriarTopico> {

  TextEditingController topico = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar tópico na comunidade'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
                controller: topico,
                decoration: InputDecoration(
                    labelText: 'Tópico',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(
              height: 5,
            ),
            ElevatedButton(
              onPressed: () async {
                await PubsService.addTopico(topico.text);
                topico.clear();
              },
              child: Text('Enviar arquivo'),
            ),
          ],
        ),
      ),
    );
  }
}
