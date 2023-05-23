import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController txtLoginEmail = TextEditingController();

  final TextEditingController txtPassword = TextEditingController();

  String Mensagem = '';
  final estilo = TextStyle(color: Colors.red, fontSize: 14);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: txtLoginEmail,
              decoration: InputDecoration(
                labelText: "E-mail",
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: txtPassword,
              decoration: InputDecoration(
                labelText: "Senha",
              ),
              obscureText: true,
            ),
            Container(
              child: Text(
                Mensagem,
                style: estilo,
              ),
              padding: EdgeInsets.all(10),
            ),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await await auth.signInAnonymously();

                    Navigator.of(context).pushNamed('/question-create');
                  } /* on Exception */ catch (ex) {
                    //AlertDialog, Snackbar, Text
                    print(ex);
                    setState(() => Mensagem = 'Usuário ou senha incorretos');
                  }
                },
                child: Text("Entrar como Anônimo"),
              ),
            ),
            TextButton(
              child: Text("Registrar"),
              onPressed: () =>
                  Navigator.of(context).pushNamed('/user-register'),
            )
          ],
        ),
      ),
    );
  }
}
