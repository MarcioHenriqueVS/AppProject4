import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teste4/AdminPages/homeAdmin_page.dart';
import 'package:teste4/Home/home_page.dart';
import 'package:teste4/TeleAtendimento/join_call_page.dart';
import 'package:teste4/Videos/criarTemaVideos.dart';
import 'Auth_Services.dart';
import 'login_page.dart';

class ChecagemPage extends StatefulWidget {
  const ChecagemPage({Key? key}) : super(key: key);

  @override
  State<ChecagemPage> createState() => _ChecagemPageState();
}

class _ChecagemPageState extends State<ChecagemPage> {
  StreamSubscription? streamSubscription;
  final ChecagemService _checagemService = ChecagemService();

  @override
  void initState() {
    super.initState();
    streamSubscription = _checagemService.checarUsuario((result) {
      if (result == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeAdminPage(),
          ),
        );
      } else if (result == 'login') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
