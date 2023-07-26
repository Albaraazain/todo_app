import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/todo.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo List',
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  late List<Todo> _todoList;

  @override
  void initState() {
    super.initState();
    _updateTodoList();
  }

  _updateTodoList() {
    DatabaseHelper.instance
        .getTodoList()
        .then((todoList) => setState(() => _todoList = todoList));
  }

  _addTodo() async {
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.instance.insertTodo(Todo(
        id: 0,
        title: _controller.text,
        description: '',
      ));
      _controller.clear();
      _updateTodoList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Enter todo item'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoList[index].title),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await DatabaseHelper.instance
                          .deleteTodo(_todoList[index].id);
                      _updateTodoList();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addTodo,
      ),
    );
  }
}
