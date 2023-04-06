import 'package:flutter/material.dart';
import 'Auth_Services.dart';
import 'Cadastro_Model.dart';
import 'checagem_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({Key? key}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final CadastroService _cadastroService = CadastroService();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Faça seu cadastro'),
      ),
      body: ListView(
        padding: EdgeInsets.all(40),
        children: [
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(label: Text('Nome completo')),
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(label: Text('Email')),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(label: Text('Senha')),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  setState(() {
                    _isLoading = true;
                  });
                  UserModel newUser = UserModel(
                    nome: _nomeController.text,
                    email: _emailController.text,
                    senha: _passwordController.text,
                  );

                  final result = await _cadastroService.cadastrar(newUser, _nomeController.text);

                  if (result != null) {
                    await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChecagemPage(),
                        ),
                            (route) => false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ocorreu um erro ao realizar o cadastro'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: Text('Cadastrar'),
              ),
              if (_isLoading)
                CircularProgressIndicator(),
            ],
          ),
        ],
      ),
    );
  }
}
