import 'package:cloud_firestore/cloud_firestore.dart';

class Photos {
  final String name;
  final String url;
  final String description;
  final DateTime dateTime;

  Photos({
    required this.name,
    required this.url,
    required this.description,
    required this.dateTime,
  });

  Photos.fromJson(Map<String, dynamic> json)
      : this(
          name: json['name'] as String,
          url: json['url'] as String,
          description: json['description'] as String,
          dateTime: (json['dateTime'] as Timestamp).toDate(),
        );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
