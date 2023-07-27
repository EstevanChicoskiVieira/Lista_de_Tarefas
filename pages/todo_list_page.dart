import 'package:flutter/material.dart';
import 'package:lista_tarefas/Models/todo.dart';
import '../Repositories/TodoRepository.dart';
import '../widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  List<Todo> todos = [];

  Todo? deletedTodo;
  int? deletedTodoPos;

  String? errorText;

  @override
  void initState() {
    super.initState();
    
    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Adicone uma tarefa',
                            hintText: 'Ex. Lavar a louça',
                            errorText: errorText,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.deepPurpleAccent
                              )
                            ),
                          labelStyle: TextStyle(
                              color: Colors.deepPurpleAccent
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if(text.isEmpty) {
                          setState(() {
                            errorText = 'O campo não pode estar vazio!';
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo =
                              Todo(title: text, dateTime: DateTime.now());
                          todos.add(newTodo);
                          errorText = null;
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurpleAccent,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Você possuí ${todos.length} tarefas pendesntes'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                        onPressed: showDeleteTodosConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurpleAccent,
                          padding: EdgeInsets.all(14),
                        ),
                        child: Text('Limpar tudo'))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Tarefa ${todo.title} foi removida com sucesso!',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      action: SnackBarAction(
        label: 'Desfazer',
        textColor: Colors.deepPurpleAccent,
        onPressed: () {
          setState(() {
            todos.insert(deletedTodoPos!, deletedTodo!);
            todoRepository.saveTodoList(todos);
          });
        },
      ),
    ));
  }

  void showDeleteTodosConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('limpar tudo?'),
        content: Text('Você reamlmente deseja apagar todas as suas tarefas?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(primary: Colors.deepPurpleAccent),
              child: Text("Não")
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              style: TextButton.styleFrom(primary: Colors.deepPurpleAccent),
              child: Text("Sim")
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
