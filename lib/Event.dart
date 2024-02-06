import 'dart:convert';

class Event {
  final String id;
  final String eventName;
  // final String description;
  final String date;
  final String time;

  Event({
    required this.id,
    required this.eventName,
    // required this.description,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      // 'description': description,
      'date': date,
      'time': time,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['eventName'],
      //description: json['description'],
      date: json['date'],
      time: json['time'],
    );
  }

  String toJsonString() {
    return json.encode(toJson());
  }

  static Map<String, dynamic> fromJsonString(String jsonString) {
    return json.decode(jsonString);
  }
}
