import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'Event.dart';

class BottomSheetWidget extends StatefulWidget {
  final Function(Event) onCreateEvent;
  final Event? initialEvent;

  BottomSheetWidget({required this.onCreateEvent, this.initialEvent});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  TextEditingController eventNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  String selectedActivity = 'Wake up';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<void> _scheduleNotification(Event newEvent) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Reminder',
      'Time for ${newEvent.eventName}',
      platformChannelSpecifics,
      payload: newEvent.toJsonString(),
    );
  }

  // Future<void> _scheduleNotification(Event newEvent) async {
  //   final int id = DateTime.now().millisecondsSinceEpoch;
  //
  //   final DateTime now = DateTime.now();
  //   final tz.TZDateTime scheduledDate = tz.TZDateTime.local(
  //     now.year,
  //     now.month,
  //     now.day,
  //     int.parse(newEvent.time.split(':')[0]),
  //     int.parse(newEvent.time.split(':')[1]),
  //   );
  //
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     sound: RawResourceAndroidNotificationSound(
  //         'notification'), // Use the 'notification' sound
  //   );
  //
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     id,
  //     'Reminder',
  //     'Time for ${newEvent.eventName}',
  //     scheduledDate,
  //     platformChannelSpecifics,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     androidAllowWhileIdle: true,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //     payload: newEvent.toJsonString(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Create Event',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            DropdownButton<String>(
              value: selectedActivity,
              onChanged: (String? newValue) {
                setState(() {
                  selectedActivity = newValue!;
                });
              },
              items: [
                'Wake up',
                'Go to gym',
                'Breakfast',
                'Meetings',
                'Lunch',
                'Quick nap',
                'Go to library',
                'Dinner',
                'Go to sleep',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: const Text('Select Activity'),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Pick up date',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  dateController.text = pickedDate.toString();
                }
              },
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Pick up time',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  timeController.text = pickedTime.format(context);
                }
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (dateController.text.isNotEmpty &&
                    timeController.text.isNotEmpty) {
                  Event newEvent = Event(
                    eventName: selectedActivity,
                    // description: descriptionController.text,
                    date: dateController.text,
                    time: timeController.text,
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                  );
                  _scheduleNotification(newEvent);
                  widget.onCreateEvent(newEvent);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields.'),
                    ),
                  );
                }
              },
              child: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
