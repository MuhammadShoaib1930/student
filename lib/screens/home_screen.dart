

import 'package:flutter/material.dart';
import 'package:student/database/Student.dart';
import 'package:student/database/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseService? dbService;

  // Initialize the database service
  void getDatabaseInstance() async {
    dbService = await DatabaseService.getInstance();
    setState(() {});  // Trigger a rebuild after initializing the database
  }

  @override
  void initState() {
    super.initState();
    getDatabaseInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student List')),
      body: SafeArea(
        child: dbService == null
            ? Center(child: CircularProgressIndicator()) // Show loading while dbService is being initialized
            : FutureBuilder<List<Student>>(
                future: dbService!.getAllStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No Data Available"));
                  } else {
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text(snapshot.data![index].phone),
                          leading: Text(snapshot.data![index].id.toString()),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: snapshot.data!.length,
                    );
                  }
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var student = Student(name: 'Shoaib', phone: '123-456-7890');
          int studentId = await dbService!.insertStudent(student);
          print('Inserted student ID: $studentId');
          setState(() {});  // Refresh the data after insertion
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
