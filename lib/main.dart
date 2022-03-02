import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mis_lab3/screens/login_screen.dart';
import 'kolokvium.dart';
import 'package:mis_lab3/screens/register_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mis_lab3/screens/calendar_screen.dart';

FirebaseMessaging messaging = FirebaseMessaging.instance;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up : ${message.messageId}');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAB 04',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const MyHomePage(title: 'LAB 04'),
        '/calendar': (context) => const CalendarScreen(),
      },
    );
  }
}

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> listElements = [];
  final courseNameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  void loadFromDb() async {
    List<Map<String, dynamic>> el = [];
    await _firestore
        .collection('courses')
        .where('userId', isEqualTo: loggedInUser!.uid)
        .get()
        .then((value) => {
              for (var elem in value.docs) {el.add(elem.data())}
            });

    setState(() {
      listElements = el;
    });
  }

  DateTime parseDateTime(String date, String time) {
    return DateTime.parse('${date}T$time');
  }

  Widget getElements() {
    if (listElements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
            child: Text(
          "Во моментов немате додадено колоквиуми",
          style: TextStyle(fontSize: 20),
        )),
      );
    } else {
      return Expanded(
        flex: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: listElements.length,
            itemBuilder: (contx, index) {
              return Kolokvium(
                  listElements[index]['courseName'] as String,
                  listElements[index]['date'] as String,
                  listElements[index]['time'] as String,
                  Theme.of(contx).primaryColor);
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    channelDescription: channel.description,
                    color: Colors.blue,
                    playSound: true,
                    icon: '@mipmap/ic_launcher')));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                  title: Text(notification.title != null
                      ? notification.title!
                      : 'Нотификација'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.body != null
                            ? notification.body!
                            : 'Колоквиум')
                      ],
                    ),
                  ));
            });
      }
    });

    _auth.userChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    loadFromDb();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  listElements.add({
                    "courseName": courseNameController.text,
                    "date": dateController.text,
                    "time": timeController.text
                  });

                  _firestore
                      .collection('courses')
                      .add({
                        'userId': loggedInUser!.uid,
                        'courseName': courseNameController.text,
                        'date': dateController.text,
                        'time': timeController.text
                      })
                      .then((value) => print("Курсот е додаден"))
                      .catchError((error) =>
                          print("Неуспешно додаавње на курсот: $error"));

                  final date =
                      parseDateTime(dateController.text, timeController.text);

                  flutterLocalNotificationsPlugin.schedule(
                      0,
                      'Колоквиум - ${courseNameController.text}',
                      'Потсетник за колоквиум денес во ${timeController.text}',
                      date.subtract(const Duration(hours: 1)),
                      NotificationDetails(
                        android: AndroidNotificationDetails(
                            channel.id, channel.name,
                            channelDescription: channel.description,
                            importance: Importance.high,
                            color: Colors.blue,
                            playSound: true,
                            icon: '@mipmap/ic_launcher'),
                      ));

                  courseNameController.clear();
                  dateController.clear();
                  timeController.clear();
                });

                showDialog(
                    context: context,
                    builder: (context) {
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.of(context).pop(true);
                      });

                      return const AlertDialog(
                          content: Text('Успешно додавање'));
                    });
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
        height: 600,
        child: Column(children: [
          Expanded(
            flex: 1,
            child: Container(
                margin: const EdgeInsets.all(3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      child: const Text('Календар'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/calendar',
                            arguments: listElements);
                      },
                    ),
                    ElevatedButton(
                        child: const Text('Одјави се'),
                        onPressed: () {
                          _auth.signOut();
                          Navigator.pop(context);
                        }),
                  ],
                )),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(5),
                  child: TextField(
                    controller: courseNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Име на предмет',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Датум | YYYY-MM-DD',
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(5),
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Време | HH:MM',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
                'user: ${loggedInUser != null ? loggedInUser!.email : 'loading..'}'),
          ),
          getElements()
        ]),
      ),
    );
  }
}
