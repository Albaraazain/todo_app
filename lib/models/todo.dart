class Todo {
  int id;
  String title;
  String description;

  Todo({required this.id, required this.title, required this.description});

  // Convert a Todo object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  // Convert a Map object into a Todo object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
    );
  }
}

// These methods are useful for storing and retrieving Todo objects from the database.

