// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_constructors_in_immutables


import 'package:calculatorapp/pages/auth_page.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  // ignore: unused_field
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _showQuizResults = false; // Variable to control showing quiz results

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.red.shade900,
        actions: [
          IconButton(
            onPressed: () => signUserOut(context),
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          children: <Widget>[
        
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showQuizResults =
                      !_showQuizResults; // Toggle quiz results visibility
                });
              },
              child: Text(
                  _showQuizResults ? 'Hide Quiz Results' : 'Quiz Results'),
            ),
            if (_showQuizResults) // Show quiz results if _showQuizResults is true
              QuizResultsPage(userId: FirebaseAuth.instance.currentUser!.uid),
          ],
        ),
      ),
    );
  }

 

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "Choose Profile Photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  takePhoto(ImageSource.camera);
                },
                label: Text("Camera"),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.photo),
                onPressed: () {
                  takePhoto(ImageSource.gallery);
                },
                label: Text("Gallery"),
              )
            ],
          )
        ],
      ),
    );
  }

  void takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
    );
    setState(() {
      _imageFile = pickedFile;
    });
  }
}

void signUserOut(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => AuthPage()),
  );
}

class QuizResultsPage extends StatelessWidget {
  final String userId;

  QuizResultsPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('quizResults')
          .where('userID', isEqualTo: userId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No quiz results found.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var quizResult = snapshot.data!.docs[index];
            String quizId = quizResult['quizID'];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Quiz')
                  .doc(quizId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Quiz: Loading...'),
                    subtitle: Text('Score: ${quizResult['score']}'),
                    trailing: Text('Date: ${quizResult['dateCompleted']}'),
                  );
                }
                if (snapshot.hasError) {
                  return ListTile(
                    title: Text('Quiz: Error'),
                    subtitle: Text('Score: ${quizResult['score']}'),
                    trailing: Text('Date: ${quizResult['dateCompleted']}'),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return ListTile(
                    title: Text('Quiz: Not found'),
                    subtitle: Text('Score: ${quizResult['score']}'),
                    trailing: Text('Date: ${quizResult['dateCompleted']}'),
                  );
                }
                var quizData = snapshot.data!;
                String quizTitle = quizData['quizTitle'];
                return ListTile(
                  title: Text('Quiz: $quizTitle'),
                  subtitle: Text('Score: ${quizResult['score']}'),
                  trailing: Text('Date: ${quizResult['dateCompleted']}'),
                );
              },
            );
          },
        );
      },
    );
  }
}
