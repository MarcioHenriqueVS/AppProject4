
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:teste4/Autenticacao/redefinirSenha_page.dart';
import 'Auth_Services.dart';
import 'cadastro_page.dart';
import 'checagem_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double logoHeight = size.height * 0.4;
    final double inputWidth = size.width * 0.8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: logoHeight,
                child: Image.asset('assets/images/logo.png'),
              ),
              SizedBox(
                width: inputWidth,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      label: Text('Email'),
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey))),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: inputWidth,
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      label: Text('Senha'),
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.redAccent)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey))),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CadastroPage(),
                    ),
                  );
                },
                child: const Text(
                  'Criar conta',
                  style: TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Esqueci a senha',
                  style: TextStyle(color: Colors.redAccent, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  login() async {
    UserCredential? userCredential = await _loginService.login(_emailController.text, _passwordController.text);
    if (userCredential != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChecagemPage(),
        ),
      );
    } else {
      // Exiba uma mensagem de erro genérica ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login. Verifique suas credenciais.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}