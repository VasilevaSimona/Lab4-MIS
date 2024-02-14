import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lab4/Model/exam_appointment.dart';
import 'package:lab4/widgets/myCalendar.dart';
import 'package:lab4/widgets/notifications_service.dart';
import 'package:lab4/widgets/nov_element.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './widgets/registerUser.dart';
import './widgets/loginUser.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exams Schedule',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Authentication',style: TextStyle(
          color: Colors.blueGrey,
          fontSize: 24,
          fontWeight: FontWeight.bold
        ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the registration page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 3,
              ),
              child: Text('Register',style: TextStyle(
                color: Colors.blue,

              ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                // NotificationService().showNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Background color
                onPrimary: Colors.white, // Text color
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Padding
                shape: RoundedRectangleBorder( // Border radius
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: TextStyle( // Text style
              fontSize: 16,
              fontWeight: FontWeight.bold,
                ),
                elevation: 3,
                ),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ExamAppointment> _examAppointments = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void _addExamAppointment(BuildContext ctx) {
    showModalBottomSheet(context: ctx, builder: (_) {
      return GestureDetector(
        onTap: () {},
        child: NovElement(_addNewAppointmentToList),
        behavior: HitTestBehavior.opaque,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _loadExamAppointments();
  }

  void _loadExamAppointments() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Query Firestore for examAppointments for the current user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email) // You might want to use UID instead of email for more reliability
          .collection('examAppointments')
          .get();

      final appointments = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ExamAppointment(
          id: doc.id,
          examName: data['examName'],
          date: (data['date'] as Timestamp).toDate(),
        );
      }).toList();

      setState(() {
        _examAppointments = appointments;
      });
    }
  }

  void _addNewAppointmentToList(ExamAppointment ea) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Write the new appointment to Firestore for the current user
      FirebaseFirestore.instance.collection('users').doc(user.email).collection('examAppointments').add({
        'examName': ea.examName,
        'date': ea.date,
      });
      _loadExamAppointments();
    }
  }

  void _openCalendar(BuildContext ctx){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyCalendar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addExamAppointment(context),
          ),
          IconButton(
            icon: Icon(Icons.edit_calendar),
            onPressed: () => _openCalendar(context),
          ),
          ElevatedButton(
            onPressed: () {
              NotificationService().showNotifications();
            },
            child: Text('Notifications'),
          ),
        ],
      ),
      body: Center(
        child: _examAppointments.isEmpty ? Text("There is not exams shedule yet") :  ListView.builder(itemBuilder: (ctx, index){
          return Card(elevation: 3,margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: ListTile(
                title: Text(_examAppointments[index].examName),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(_examAppointments[index].date!)),
              )
          );
        },
            itemCount: _examAppointments.length
        ),
      ),
    );
  }
}