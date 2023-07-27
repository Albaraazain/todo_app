import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_helper.dart';
import 'models/todo.dart';
import 'package:intl/intl.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: ThemeData(
        // primary swatch is the primary color of the app (the color of the app bar) and the default color of the app while pri

        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreenAccent),
        primaryColor: Theme.of(context).colorScheme.onPrimary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
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
  final _focusNode = FocusNode(); // Create a FocusNode instance
  var isHovering = false;
  late List<Todo> _todoList = [];

  // Add a ValueNotifier for each todo item to manage its hover state
  late List<ValueNotifier<bool>> _hoverNotifiers;

  @override
  void initState() {
    super.initState();
    _updateTodoList();
  }

  _updateTodoList() {
    DatabaseHelper.instance.getTodoList().then((todoList) {
      // Initialize the hover state notifiers for each item
      _hoverNotifiers =
          List.generate(todoList.length, (index) => ValueNotifier<bool>(false));
      setState(() => _todoList = todoList);
    });
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
      _focusNode.requestFocus(); // Request focus for the node
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 100, 0, 100),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: 'Today ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                DateFormat('EEE d MMM').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _todoList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _todoList.length) {
                            // If this is the last item, return the form
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Add Todo',
                                    suffixIcon: IconButton(
                                      onPressed: _addTodo,
                                      icon: Icon(Icons.add),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) {
                                    _addTodo();
                                  },
                                ),
                              ),
                            );
                          }

                          // Return the list item
                          return ListTile(
                            leading: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => _hoverNotifiers[index].value =
                                  true, // Set hover to true when mouse enters
                              onExit: (_) => _hoverNotifiers[index].value =
                                  false, // Set hover to false when mouse exits
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _hoverNotifiers[index],
                                builder: (context, isHovering, child) {
                                  return GestureDetector(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 200),
                                      child: isHovering
                                          ? Icon(
                                              Icons.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              key:
                                                  UniqueKey(), // Provide a unique key to ensure the icon gets replaced
                                            )
                                          : Icon(
                                              Icons.circle_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              key:
                                                  UniqueKey(), // Provide a unique key to ensure the icon gets replaced
                                            ),
                                    ),
                                    onTap: () async {
                                      await DatabaseHelper.instance
                                          .deleteTodo(_todoList[index].id);
                                      _updateTodoList();
                                    },
                                  );
                                },
                              ),
                            ),
                            title: Text(_todoList[index].title),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
