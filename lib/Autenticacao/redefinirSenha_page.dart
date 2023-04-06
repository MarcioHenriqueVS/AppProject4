import 'package:flutter/material.dart';
import 'Auth_Services.dart';
import 'login_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotPasswordService _forgotPasswordService = ForgotPasswordService();
  TextEditingController forgetPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextEditingController forgetPasswordController = TextEditingController();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: 250,
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  controller: forgetPasswordController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Email',
                    enabledBorder: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    resetPassword();
                  },
                  child: Text('Enviar email'))
            ],
          ),
        ),
      ),
    );
  }

  resetPassword() async {
    bool result = await _forgotPasswordService
        .sendPasswordResetEmail(forgetPasswordController.text.trim());
    if (result) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {
      //inserir mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Falha ao enviar email de redefinição de senha. Verifique se o email está correto.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
