import 'dart:developer';
import 'package:flutter/material.dart';

import 'call_page_mobile.dart';

class JoinCallPageMobile extends StatefulWidget {
  const JoinCallPageMobile({Key? key}) : super(key: key);

  @override
  State<JoinCallPageMobile> createState() => _JoinCallPageMobileState();
}

class _JoinCallPageMobileState extends State<JoinCallPageMobile> {
  final _channelController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _validateError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoCall'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20,),
              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(
                  errorText: _validateError ? 'Nome do canal é obrigatorio' : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  hintText: 'Token',
                ),
              ),
              TextFormField(
                controller: _channelController,
                decoration: InputDecoration(
                  errorText: _validateError ? 'Nome do canal é obrigatorio' : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  hintText: 'Nome do canal',
                ),
              ),

              ElevatedButton(onPressed: onJoin,
                child: const Text('Entrar na consulta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Future<void> onJoin() async {
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CallPageMobile(
            token: _tokenController.text,
            channelName: _channelController.text,
          )));
    }
  }
}