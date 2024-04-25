// ignore_for_file: unused_import, use_key_in_widget_constructors, prefer_const_constructors, unused_element, avoid_unnecessary_containers, prefer_const_constructors_in_immutables, unused_local_variable, use_build_context_synchronously, avoid_print, dead_code

import 'dart:async';

import 'package:calculatorapp/components/box.dart';
import 'package:calculatorapp/components/button.dart';
import 'package:calculatorapp/main.dart';
import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/auth_page.dart';
import 'package:calculatorapp/pages/calculator.dart';
import 'package:calculatorapp/pages/contact.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/pages/login_or_register_oages.dart';
import 'package:calculatorapp/pages/login_page.dart';
import 'package:calculatorapp/pages/sign_up.dart';
import 'package:calculatorapp/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculatorapp/pages/location.dart';
import 'package:calculatorapp/service/database.dart';
import 'package:calculatorapp/pages/create_quiz.dart';
import 'package:calculatorapp/pages/quiz_play.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:uuid/uuid.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

void signUserOut(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
  );
}

class _UserHomeState extends State<UserHome> {
  late Stream<QuerySnapshot<Map<String, dynamic>>>
      quizStream; // Specify the correct type
  late DatabaseService databaseService;

  late Timer _timer;
  final int sessionTimeoutInSeconds = 500;

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService(uid: Uuid().v4());
    quizStream = Stream.empty();
    loadQuizData();
    _startTimeout();
  }

  @override
  void dispose() {
    _timer.cancel(); // Dispose of the session timeout timer
    super.dispose();
  }

  void _startTimeout() {
    _timer = Timer(Duration(seconds: sessionTimeoutInSeconds), () {
      // Show popup message when session times out
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('Session Timeout'),
            content: Text('Your session has timed out. Please login again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Redirect user to login page
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoginOrRegisterPage(),
                  ));
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  void _resetTimeout() {
    _timer.cancel(); // Cancel the current timer
    _startTimeout(); // Start a new timer
  }

  void loadQuizData() {
    databaseService.getQuizData2().then((value) {
      setState(() {
        quizStream = value;
      });
      displayNewQuizNotification();
    });
  }

  void displayNewQuizNotification() {
    NotificationService.displayNotification(
      'New Quiz Added!',
      'Check out the latest quiz available.',
    );
  }

  Widget quizList() {
  return Container(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: StreamBuilder(
        stream: quizStream,
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No quizzes available.'),
            );
          }
          String userId = FirebaseAuth.instance.currentUser!.uid;
          return ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemExtent: 180,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var quizDoc = snapshot.data!.docs[index];
              String quizId = quizDoc.id;
              String title = quizDoc.data()['quizTitle'];
              String description = quizDoc.data()['quizDesc'];
              return Column(
                children: [
                  QuizTile(
                    title: title,
                    description: description,
                    id: quizId,
                    userId: userId,
                  ),
                  Divider(
                    color: Theme.of(context).primaryColor,
                    thickness: 2.0,
                    height: 2,
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(179, 227, 220, 220),
      appBar: AppBar(
        title: AppLogo(),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 112, 16, 16),
        actions: [
          Row(
            children: [
              MyBox(
                color: Color.fromARGB(255, 5, 5, 5),
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                  MyButton(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    onTap: () {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  )
                ],
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    DrawerHeader(
                      child: Center(
                        child: Text(
                          'Student Dashboard',
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text(
                        'Home',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (coRntext) => HomePage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.calculate),
                      title: Text(
                        'Calculator',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Calculator()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text(
                        'About Me',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => About()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.message),
                      title: Text(
                        'Contacts',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyContact()));
                      },
                    ),
                      ListTile(
                      leading: Icon(Icons.message),
                      title: Text(
                        'Location',
                        style: TextStyle(fontSize: 20),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MapPage()));
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  'Log out',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () => signUserOut(context),
              ),
            ],
          ),
        ),
      ),
      body: quizList(),
    );
  }
}

class QuizTile extends StatelessWidget {
  final String title, id, description, userId;
  

  QuizTile(
      {required this.title,
      required this.description,
      required this.id,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkCompletion(userId, id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(); // Return an empty container while loading
        } else if (snapshot.hasError) {
          return Container(); // Return an empty container if an error occurs
        } else {
          bool isCompleted = snapshot.data ?? false;
          if (isCompleted) {
            // If the quiz is completed, return an empty container to hide it
            return Container();
          } else {
            // If the quiz is not completed, return a clickable tile
            return GestureDetector(
              onTap: () async {
                String currentDate = DateTime.now().toIso8601String();
                String resultId = Uuid().v4();
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                try {
                  await firestore.collection('quizResults').doc(resultId).set({
                    'userID': userId,
                    'quizID': id,
                    'score': 0,
                    'status': 'in progress',
                    'dateCompleted': null,
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPlay(id),
                    ),
                  );
                } catch (error) {
                  print('Error recording quiz result: $error');
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                    
                      Container(
                        color: Colors.black26,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Future<bool> checkCompletion(String userId, String quizId) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('quizResults')
          .where('userID', isEqualTo: userId)
          .where('quizID', isEqualTo: quizId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking completion: $e");
      return false;
    }
  }
}
