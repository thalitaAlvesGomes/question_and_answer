import 'dart:html';
import 'dart:js_util';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuestionCreate extends StatelessWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController txtQuestion = TextEditingController();

  List<String> users = [];
  List<String> user = [];
  void insert() {
    firestore.collection('questions').add({
      'question': txtQuestion.text,
      'votes': 0,
      'user': 'Anonymous',
      'userVoted': []
    });
  }

  void getUsers(String id, String campo) async {
    //users = firestore.collection('questions').doc(id).get();
    DocumentSnapshot documentSnapshot =
        await firestore.collection('questions').doc(id).get();
    users = documentSnapshot.data()[campo];
    print(documentSnapshot);
  }

  void currentUser() {
    String user = auth.currentUser!.uid;
    print(user);
  }

  void countVotes(String id, int votes) {
    if (users.contains(user)) {
      votes = votes - 1;
    } else {
      firestore
          .collection('questions')
          .doc(id)
          .update({'userVoted': FieldValue.arrayUnion(user)});
    }
  }

  void votes(String id, int votes) {
    currentUser();
    getUsers(id);
    countVotes(id, votes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        title: Center(child: Text("Q&A")),
      ),
      body: Container(
        margin: EdgeInsets.all(30),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shadowColor: Colors.grey,
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      maxLines: 5,
                      minLines: 1,
                      controller: txtQuestion,
                      decoration: InputDecoration(
                        hintText: "Faça sua pergunta...",
                        prefixIcon: Icon(Icons.edit),
                        /* contentPadding: EdgeInsets.only(bottom: 50), */
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "Enviar como anônimo",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Ação do botão
                            insert();
                            txtQuestion.clear();
                          },
                          child: Text("Enviar"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[200], //cor de fundo
                            foregroundColor: Colors.white, // cor do texto
                            shadowColor: Colors.grey, //sombra
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestore
                    .collection('questions')
                    .orderBy('votes', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();

                  var questions = snapshot.data!.docs;

                  return Expanded(
                    child: ListView(
                      children: questions.map((question) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadowColor: Colors.grey,
                          elevation: 5,
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30.0,
                              foregroundColor: Colors.white,
                              child: Text(question['user'].substring(0, 1)),
                              backgroundColor: Colors.purple[200],
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 5),
                              child: Text(question['user']),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(question['question']),
                            ),
                            trailing: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      key:
                                      Key(question.id);
                                      // countVotes(question.id,question['votes']);
                                      votes(question.id, question['votes']);
                                    },
                                    icon: Icon(Icons.thumb_up)),
                                SizedBox(width: 10),
                                Text(question['votes'].toString()),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
