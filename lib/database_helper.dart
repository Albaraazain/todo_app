// Import the necessary packages
import 'package:sqflite/sqflite.dart'; // sqflite package for SQLite in Flutter
import 'package:path_provider/path_provider.dart'; // path_provider to get directory path
import 'dart:io';
import 'dart:async';
import 'package:todo_app/models/todo.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper!;
  }

  // Define a getter for the singleton instance
  static DatabaseHelper get instance {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todos.db';

    var todosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  // Method to create the table
  void _createDb(Database db, int newVersion) async {
    // Execute a SQL query to create a new table with the specified columns
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT)');
  }

  // Insert a Todo object into the database
  Future<int> insertTodo(Todo todo) async {
    Database db = await this.database;
    var result = await db.insert(todoTable, {
      'id': null, // SQLite will auto-generate a unique id
      'title': todo.title,
      'description': todo.description,
    });
    return result;
  }

// Retrieve all Todo objects from the database
  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await this.database;
    var result = await db.query(todoTable);
    return result;
  }

// Update a Todo object in the database
  Future<int> updateTodo(Todo todo) async {
    Database db = await this.database;
    var result = await db.update(todoTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return result;
  }

// Delete a Todo object from the database
  Future<int> deleteTodo(int id) async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $todoTable WHERE $colId = $id');
    return result;
  }

// Get the number of Todo objects in the database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $todoTable');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

// Get the 'Todo' list from the database
  Future<List<Todo>> getTodoList() async {
    var todoMapList = await getTodoMapList(); // Get 'Map List' from database
    int count =
        todoMapList.length; // Count the number of map entries in db table

    List<Todo> todoList = [];
    // For loop to create a 'Todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoList.add(Todo.fromMap(todoMapList[i]));
    }
    return todoList;
  }
}
