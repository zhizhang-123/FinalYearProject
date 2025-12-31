import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuala_Lumpur'));

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    var androidSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = const DarwinInitializationSettings();

    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'daily_reminder_channel',
      'Daily Reminders',
      description: 'Used for daily task notifications',
      importance: Importance.max,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    _rescheduleAllFromFirebase();
  }

  Future<void> _rescheduleAllFromFirebase() async {
    if (_auth.currentUser == null) return;
    var snapshot = await _userNotifications.get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      _scheduleDailyNotification(
        doc.id,
        data['title'] ?? "",
        data['description'] ?? "",
        DateTime.parse(data['time']),
      );
    }
  }

  CollectionReference get _userNotifications {
    String uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('reminders');
  }

  Future<void> _scheduleDailyNotification(String id, String title, String desc, DateTime time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      desc,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _showDetailDialog(String docId, Map<String, dynamic> data) {
    DateTime time = DateTime.parse(data['time']);
    String timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notification Details", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.title, "Title", data['title']),
            const SizedBox(height: 10),
            _detailRow(Icons.description, "Description", data['description']),
            const SizedBox(height: 10),
            _detailRow(Icons.access_time, "Time", "Everyday $timeStr"),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editNotification(docId, data);
            },
            child: const Text("Edit", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(docId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(child: Text("$label: $value", style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  void _editNotification(String docId, Map<String, dynamic> oldData) async {
    TextEditingController titleController = TextEditingController(text: oldData['title']);
    TextEditingController descController = TextEditingController(text: oldData['description']);
    DateTime oldTime = DateTime.parse(oldData['time']);

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: oldTime.hour, minute: oldTime.minute),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      DateTime newFullDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Edit Notification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _userNotifications.doc(docId).update({
                  'title': titleController.text,
                  'description': descController.text,
                  'time': newFullDateTime.toIso8601String(),
                });
                await _scheduleDailyNotification(docId, titleController.text, descController.text, newFullDateTime);
                Navigator.pop(context);
              },
              child: const Text("Save Edit"),
            )
          ],
        ),
      );
    }
  }

  void _addNotification() async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      DateTime fullDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Set Notification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(hintText: "Title")),
              TextField(controller: descController, decoration: const InputDecoration(hintText: "Description")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                DocumentReference doc = await _userNotifications.add({
                  'title': titleController.text,
                  'description': descController.text,
                  'time': fullDateTime.toIso8601String(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                await _scheduleDailyNotification(doc.id, titleController.text, descController.text, fullDateTime);
                Navigator.pop(context);
              },
              child: const Text("Confirm"),
            )
          ],
        ),
      );
    }
  }

  void _deleteNotification(String id) async {
    await _userNotifications.doc(id).delete();
    await flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_list_bulleted, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Notification",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Click Add Button To Set Your Notification!",
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Management"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userNotifications.orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;
              DateTime time = DateTime.parse(data['time']);
              String timeStr = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.alarm, color: Colors.green),
                  title: Text(data['title']),
                  subtitle: Text("Everyday $timeStr"),
                  onTap: () => _showDetailDialog(doc.id, data),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNotification,
        label: const Text("Add"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}