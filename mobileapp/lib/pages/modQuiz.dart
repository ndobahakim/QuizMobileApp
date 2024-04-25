// ignore_for_file: file_names, unused_import, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, prefer_const_constructors, unnecessary_null_comparison, unnecessary_cast

import 'package:calculatorapp/pages/about.dart';
import 'package:calculatorapp/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calculatorapp/service/database.dart';

class ModifyQuizPage extends StatefulWidget {
  final String quizId;

  ModifyQuizPage({required this.quizId});

  @override
  _ModifyQuizPageState createState() => _ModifyQuizPageState();
}

class _ModifyQuizPageState extends State<ModifyQuizPage> {
  late Stream<DocumentSnapshot> quizDataStream;
  late Stream<QuerySnapshot> questionDataStream;
  late DatabaseService databaseService;

  @override
  void initState() {
    super.initState();
    databaseService = DatabaseService(uid: widget.quizId);
    // Get the quiz data stream directly
    quizDataStream = databaseService.getQuizData3(widget.quizId);
    // Get the question data stream directly
    questionDataStream = databaseService.getQuestionData2(widget.quizId);
  }

  // Method to delete a question
  Future<void> deleteQuestion(String questionId) async {
    try {
      await databaseService.deleteQuestion(widget.quizId, questionId);
    } catch (e) {
      print('Error deleting question: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Quiz'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Quiz Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: quizDataStream as Stream<DocumentSnapshot<Map<String, dynamic>>>?,
            builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text('No quiz data found.');
              }
              var quizData = snapshot.data!.data() as Map<String, dynamic>;
              if (quizData == null) {
                return Text('No quiz data found.');
              }
              return ListTile(
                title: Text('Title: ${quizData['quizTitle']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${quizData['quizDesc']}'),
                   
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Navigate to a page to edit quiz details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditQuizPage(
                          quizId: widget.quizId,
                          currentTitle: quizData['quizTitle'],
                          currentDesc: quizData['quizDesc'],
                        
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: questionDataStream as Stream<QuerySnapshot<Map<String, dynamic>>>?,
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Text('No questions found.');
                }
                var questions = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var questionData = questions[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text('Question ${index + 1}: ${questionData['question']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Navigate to a page to edit the question
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditQuestionPage(
                                    quizId: widget.quizId,
                                    questionId: questions[index].id,
                                    currentQuestion: questionData['question'],
                                    currentOptions: [
                                      questionData['option1'],
                                      questionData['option2'],
                                      questionData['option3'],
                                      questionData['option4'],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Show a dialog to confirm deleting the question
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Question'),
                                  content: Text('Are you sure you want to delete this question?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Delete the question
                                        deleteQuestion(questions[index].id);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                // Show a dialog to confirm deleting the entire quiz
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Quiz'),
                    content: Text('Are you sure you want to delete this quiz?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Delete the entire quiz
                          databaseService.deleteQuiz(widget.quizId);
                          Navigator.pop(context);
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.delete),
              label: Text('Delete Quiz'),
            ),
          ),
        ],
      ),
    );
  }
}

class EditQuizPage extends StatefulWidget {
  final String quizId;
  final String currentTitle;
  final String currentDesc;
 

  EditQuizPage({required this.quizId, required this.currentTitle, required this.currentDesc});

  @override
  _EditQuizPageState createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
 

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _descController = TextEditingController(text: widget.currentDesc);
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Quiz'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title'),
            TextFormField(
              controller: _titleController,
            ),
            SizedBox(height: 16),
            Text('Description'),
            TextFormField(
              controller: _descController,
            ),
           
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Update quiz details in the database
                DatabaseService(uid: widget.quizId).updateQuizData(
                  widget.quizId,
                  {
                    'quizTitle': _titleController.text,
                    'quizDesc': _descController.text,
                  
                  },
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditQuestionPage extends StatefulWidget {
  final String quizId;
  final String questionId;
  final String currentQuestion;
  final List<String> currentOptions;

  EditQuestionPage({required this.quizId, required this.questionId, required this.currentQuestion, required this.currentOptions});

  @override
  _EditQuestionPageState createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.currentQuestion);
    _optionControllers = List.generate(
      widget.currentOptions.length,
      (index) => TextEditingController(text: widget.currentOptions[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Question'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question'),
            TextFormField(
              controller: _questionController,
            ),
            SizedBox(height: 16),
            Text('Options'),
            for (int i = 0; i < _optionControllers.length; i++)
              TextFormField(
                controller: _optionControllers[i],
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Update question details in the database
                DatabaseService(uid: widget.quizId).updateQuestionData(
                  widget.quizId,
                  widget.questionId,
                  {
                    'question': _questionController.text,
                    'option1': _optionControllers[0].text,
                    'option2': _optionControllers[1].text,
                    'option3': _optionControllers[2].text,
                    'option4': _optionControllers[3].text,
                  },
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}