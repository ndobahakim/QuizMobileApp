// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/pages/home.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications(); // Initialize notifications
  runApp(
    MaterialApp(
      home: Results(
        incorrect: 0,
        total: 10,
        correct: 10,
        userName:
            await loadUserName(), // Load user name from shared preferences
      ),
    ),
  );
}

// Function to load user name from shared preferences
Future<String?> loadUserName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName');
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('classme'); // Replace with your app icon

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      // Handle notification tap
    },
  );
}

class Results extends StatefulWidget {
  final int total, correct, incorrect;
  final String? userName;
  
  // ignore: use_key_in_widget_constructors
  Results({
    required this.incorrect,
    required this.total,
    required this.correct,
    this.userName,
  });

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  void initState() {
    super.initState();

    // Call sendNotification when the page loads
    sendNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results!"),
        centerTitle: true,
        backgroundColor: Colors.red.shade900,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${widget.correct}/ ${widget.total}",
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "you answered ${widget.correct} answers correctly and ${widget.incorrect} answers incorrectly",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900, // Use theme color here
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "Go to home",
                        style: TextStyle(color: Colors.white, fontSize: 19),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quiz_channel', // Replace with your own channel ID
      'Quiz Notifications', // Replace with your own channel name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final userName =
        widget.userName ?? ''; // Use userName from widget or default to 'User'

    await flutterLocalNotificationsPlugin.show(
      0,
      'Well Done! $userName',
      'Congratulations on completing the quiz!',
      platformChannelSpecifics,
    );
  }
}
