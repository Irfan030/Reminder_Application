import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BottomSheet.dart';
import 'Event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> eventsData = prefs.getStringList('events') ?? [];
    setState(() {
      events = eventsData.map((eventString) {
        Map<String, dynamic> eventMap = Event.fromJsonString(eventString);
        return Event.fromJson(eventMap);
      }).toList();
    });
  }

  Future<void> _saveEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> eventsData =
        events.map((event) => event.toJsonString()).toList();
    prefs.setStringList('events', eventsData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Tracker'),
      ),
      body: events.isEmpty
          ? Center(
              child: Text('No events yet. Tap the "+" button to add an event.'),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                Event event = events[index];
                return Dismissible(
                  key: Key(event.id),
                  onDismissed: (direction) {
                    _deleteEvent(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Icon(Icons.event),
                      title: Text(event.eventName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Text('Description: ${event.description}'),
                          Text('Date: ${event.date}'),
                          Text('Time: ${event.time}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editEvent(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteEvent(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, [Event? eventToEdit]) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return BottomSheetWidget(
          onCreateEvent: (newEvent) {
            if (eventToEdit == null) {
              _createEvent(newEvent);
            } else {
              _updateEvent(events.indexOf(eventToEdit), newEvent);
            }
          },
          initialEvent: eventToEdit,
        );
      },
    );
  }

  dynamic _createEvent(Event newEvent) {
    setState(() {
      events.add(newEvent);
    });
    _saveEvents();
    Navigator.pop(context);
    // You can return something if needed
    return 'Event created successfully';
  }

  void _editEvent(int index) {
    Event eventToEdit = events[index];
    _showBottomSheet(context, eventToEdit);
  }

  void _updateEvent(int index, Event editedEvent) {
    setState(() {
      events[index] = editedEvent;
    });
    _saveEvents();
  }

  void _deleteEvent(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeEvent(index);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _removeEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
    _saveEvents();
  }
}

// Assume you have an EditEventPage widget where the user can edit event details.
