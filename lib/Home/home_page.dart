
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../Autenticacao/checagem_page.dart';
import '../Desafios/desafioList_page.dart';
import '../Desafios/meusPontos_page.dart';
import '../Desafios/viewFeedDesafio_page.dart';
import '../Perfil/perfil_page.dart';
import '../Publicacoes/topicosList_page.dart';
import '../TeleAtendimento/join_call_page.dart';
import '../TeleAtendimento/join_call_page_web.dart';
import '../Videos/temasVideosList_page.dart';

class HomePage extends StatefulWidget {
  final String? profileImageUrl;
  const HomePage({Key? key, this.profileImageUrl}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  String? _uid;
  String? _profileImageUrl;
  final _firebaseAuth = FirebaseAuth.instance;
  String nome = '';
  String email = '';

  @override
  initState() {
    super.initState();
    pegarUsuario();
    _getCurrentUser();
    _getProfileImageUrl();
  }

  Future<void> _getProfileImageUrl() async {
    final storageRef = FirebaseStorage.instance
        .ref('profileImages')
        .child(_uid.toString());
    try {
      final url = await storageRef.getDownloadURL();
      setState(() {
        _profileImageUrl = url;
      });
    } catch (e) {
      //('Erro ao obter URL da imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page', style: TextStyle(color: Colors.white),),
        titleTextStyle: (const TextStyle(fontSize: 21)),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              accountEmail: Text(
                email,
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 16.0,
                ),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: _profileImageUrl != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(_profileImageUrl!),
                )
                    : const CircleAvatar(
                  backgroundColor: Colors.white,
                ),
              ),
            ),


            ListTile(
              dense: true,
              title: const Text(
                'Sair',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              trailing: const Icon(Icons.exit_to_app),
              onTap: () {
                sair();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push((context),
                      MaterialPageRoute(builder: (context) => TopicosListScreen()));
                },
                child: const Text('Publicações'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push((context),
                        MaterialPageRoute(builder: (context) => JoinCallPage()));
                  },
                  child: const Text('Video chamada')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        (context),
                        MaterialPageRoute(
                            builder: (context) => TemasListScreen()));
                  },
                  child: const Text('Lista de videos')),

              ElevatedButton(
                  onPressed: () {
                    Navigator.push((context),
                        MaterialPageRoute(builder: (context) => DesafioListScreen()));
                  },
                  child: const Text('Desafios')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push((context),
                        MaterialPageRoute(builder: (context) => MeusPontos()));
                  },
                  child: const Text('Meus pontos')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push((context),
                        MaterialPageRoute(builder: (context) => ViewFeedDesafio()));
                  },
                  child: const Text('Feed desafio')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push((context),
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                  },
                  child: const Text('Ver perfil')),
            ],
          ),
        ),
      ),
    );
  }

  pegarUsuario() async {
    User? usuario = await _firebaseAuth.currentUser;
    if (usuario != null) {
      setState(() {
        nome = usuario.displayName!;
        email = usuario.email!;
      });
    }
  }

  sair() async {
    await _firebaseAuth.signOut().then((user) => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ChecagemPage(),
          ),
        ));
  }

  void _getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    setState(() {
      _uid = user?.uid;
      _profileImageUrl = user?.photoURL;
    });
  }
}
