import 'package:flutter/material.dart';
import 'call_page_web.dart';

class JoinCallPageWeb extends StatefulWidget {
  const JoinCallPageWeb({Key? key}) : super(key: key);

  @override
  _JoinCallPageWebState createState() => _JoinCallPageWebState();
}

class _JoinCallPageWebState extends State<JoinCallPageWeb> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _channelNameController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    _channelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Token:'),
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Digite o seu token',
              ),
            ),
            SizedBox(height: 16),
            Text('Nome da sala:'),
            TextFormField(
              controller: _channelNameController,
              decoration: const InputDecoration(
                labelText: 'Digite o nome da sala',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(
                      token: _tokenController.text,
                      channelName: _channelNameController.text,
                    ),
                  ),
                );
              },
              child: const Text('Entrar no atendimento'),
            ),
          ],
        ),
      ),
    );
  }
}
