// ignore_for_file: unused_import, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calculatorapp/pages/admin_page.dart';
import 'package:calculatorapp/service/database.dart';
import 'package:uuid/uuid.dart';

class AddQuestion extends StatefulWidget {
  final String quizId;
  final DatabaseService databaseService;

  AddQuestion({required this.quizId, required this.databaseService});

  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  late DatabaseService databaseService;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String question = "", option1 = "", option2 = "", option3 = "", option4 = "";

  void uploadQuizData() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      Map<String, String> questionMap = {
        "question": question,
        "option1": option1,
        "option2": option2,
        "option3": option3,
        "option4": option4
      };

      widget.databaseService
          .addQuestionData(questionMap, widget.quizId)
          .then((value) {
        setState(() {
          isLoading = false;
          // Reset form fields after adding question
          _formKey.currentState!.reset();
          question = "";
          option1 = "";
          option2 = "";
          option3 = "";
          option4 = "";
        });
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        print(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text(
          "Add Questions",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0.0,
        backgroundColor: Colors.red.shade900,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    TextFormField(
                      validator: (val) =>
                          val!.isEmpty ? "Enter Question" : null,
                      decoration: InputDecoration(
                        hintText: "Question",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        question = val;
                      },
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option1 " : null,
                      decoration: InputDecoration(
                        hintText: "Option1 (Correct Answer)",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option1 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option2 " : null,
                      decoration: InputDecoration(
                        hintText: "Option2",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option2 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option3 " : null,
                      decoration: InputDecoration(
                        hintText: "Option3",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option3 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      validator: (val) => val!.isEmpty ? "Option4 " : null,
                      decoration: InputDecoration(
                        hintText: "Option4",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (val) {
                        option4 = val;
                      },
                    ),
                    SizedBox(height: 8),
                    Spacer(),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminPage()),
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 20,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Cancel",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: uploadQuizData,
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 2 - 40,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade900,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Add Question",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }
}
