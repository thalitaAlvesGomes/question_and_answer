import 'package:flutter/material.dart';
import 'questionCreate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

const firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyD9miP1wQrIIBX9kNNKgyC6bqf5R8IMB_8",
    authDomain: "question-and-answer-ee5a1.firebaseapp.com",
    projectId: "question-and-answer-ee5a1",
    storageBucket: "question-and-answer-ee5a1.appspot.com",
    messagingSenderId: "758521985486",
    appId: "1:758521985486:web:2788d63c0e194f4455139f");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    // Verifica se há algum usuário logado:
    if(auth.currentUser == null) {
      // caso não haja, autentica com usuário anônimo
      // isso gerará um usuário sem dados, mas com uid.
      auth.signInAnonymously();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: TaskListPage(),
      initialRoute: '/question-create',
      routes: {
        
        '/question-create': (context) => QuestionCreate(),
      },
    );
  }
}
