import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuestionCreate extends StatelessWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController txtQuestion = TextEditingController();

  String user = '';

  bool checkVote = true;

  void insert() {
    firestore.collection('questions').add({
      'question': txtQuestion.text,
      'votes': 0,
      'user': 'Anonymous',
      'uid': auth.currentUser!.uid,
      'userVoted': [],
      'date': DateTime.now()
    });
  }

  void countVotes(String id, int votes) {
    user = auth.currentUser!.uid; //pegar o uid atual

    firestore.collection('questions').doc(id).get().then((documentSnapshot) {
      List users = documentSnapshot
          .data()?['userVoted']; //para armazenar os usuários dentro do "voto"

      if (users != null && users.contains(user)) {
        checkVote = true;
      } else {
        checkVote = false;
      }
      print(checkVote);

      if (checkVote == false) {
        firestore.collection('questions').doc(id).update({
          'userVoted': FieldValue.arrayUnion([user]),
          'votes': votes + 1,
        });
        checkVote = true;
      }
    });
  }

  // void getCampo(id) async {
  //   DocumentReference document =
  //       await FirebaseFirestore.instance.collection("questions").doc(id);

  //   document.get().then((value) {
  //     users = value["userVoted"];
  //   });
  //   print(users);
  // }

  // void countVotes(String id, int votes) {
  //   user = [auth.currentUser!.uid];
  //   print(user);
  //   if (users.contains(user[0])) {
  //     votes = votes;
  //   } else {
  //     votes = (votes + 1);
  //     firestore.collection('questions').doc(id).update({
  //       'userVoted': FieldValue.arrayUnion([user]),
  //       'votes': votes
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Q&A"),
            Text("CODE: CODIGO")
          ],
        ),
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
                    .orderBy('date', descending: false)
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
                                      Key(question.id);

                                      countVotes(
                                          question.id, question['votes']);
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