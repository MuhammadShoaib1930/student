import 'package:student/database/database_constants.dart';

class Student {
  int? id;
  String name;
  String phone;

  Student({this.id, required this.name, required this.phone});

  // Convert a Student object to a Map (for inserting into the database)
  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.id: id,
      DatabaseConstants.name: name,
      DatabaseConstants.phone: phone,
    };
  }

  // Convert a Map to a Student object
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map[DatabaseConstants.id],
      name: map[DatabaseConstants.name],
      phone: map[DatabaseConstants.phone],
    );
  }
}
