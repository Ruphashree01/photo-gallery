import 'package:cloud_firestore/cloud_firestore.dart';

class Photos {
  final String? docId;
  final String name;
  final String url;
  final String description;
  final DateTime dateTime;

  Photos({
    this.docId,
    required this.name,
    required this.url,
    required this.description,
    required this.dateTime,
  });

  Photos.fromJson(Map<String, dynamic> json)
      : this(
          docId: json['docId'] as String?,
          name: json['name'] as String,
          url: json['url'] as String,
          description: json['description'] as String,
          dateTime: (json['dateTime'] as Timestamp).toDate(),
        );

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'name': name,
      'url': url,
      'description': description,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
