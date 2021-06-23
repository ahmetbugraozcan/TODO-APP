import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/core/extensions/context_extension.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/service/database_helper.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  bool isHaveUnsaved = false;
  List<Todo>? todoList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: context.paddingAllHigh,
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: context.paddingHorizontalLow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildTodolarimText(context),
                    buildAddTodoButton(context)
                  ],
                ),
              ),
              todoList == null
                  ? FutureBuilder(
                      future: databaseHelper.getTodos(),
                      builder: (context, AsyncSnapshot asyncsnapshot) {
                        if (asyncsnapshot.hasData) {
                          todoList = asyncsnapshot.data;
                          return buildTodoListView();
                        } else {
                          return buildLoadingWidget();
                        }
                      })
                  : buildTodoListView(),
            ],
          ),
        ),
      ),
    );
  }

  IconButton buildAddTodoButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          setState(() {
            //Burada bir fake todolist yollanıyor, ishaveunsaved ile iki kez kaydedilmemiş input eklenmesi önleniyor
            isHaveUnsaved = false;
            todoList?.forEach((element) {
              if (!element.isSaved) {
                isHaveUnsaved = true;
              }
            });
            if (!isHaveUnsaved) {
              todoList?.insert(0, Todo("", "", false, false));
            } else {
              showTodoSnackbar(context);
            }
          });
        },
        icon: Icon(
          Icons.add,
          size: context.dynamicHeight(0.04),
          color: context.theme.primaryColor,
        ));
  }

  void showTodoSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text("Lütfen tamamlanmamış ToDo'yu doldurunuz"),
    ));
  }

  Center buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildTodoListView() {
    return todoList?.length == 0
        ? buildTodoNotFound()
        : Expanded(
            child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: todoList?.length,
                itemBuilder: (context, index) {
                  return buildTodoListTile(todoList?[index]);
                }),
          );
  }

  Widget buildTodoNotFound() => Center(child: Text("Bir ToDo bulunamadı."));

  Widget buildTodoListTile(Todo? todo) {
    TextEditingController controller = TextEditingController();

    return Padding(
      padding: context.paddingAllLow,
      child: Opacity(
        opacity: todo!.isCompleted ? 0.5 : 1,
        child: ListTile(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: context.theme.disabledColor, width: 0.5),
              borderRadius: BorderRadius.circular(5)),
          subtitle: Row(
            children: [
              Expanded(
                  flex: 6,
                  child: !todo.isSaved
                      ? TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                              hintText: "Ne yapmak istiyorsunuz?",
                              contentPadding:
                                  EdgeInsets.fromLTRB(12, 12, 12, 0),
                              isDense: true,
                              border: OutlineInputBorder()),
                        )
                      : Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    todo.isCompleted = !todo.isCompleted;
                                    databaseHelper.updateTodo(todo);
                                    updateTodoList();
                                  });
                                },
                                icon: Icon(
                                  Icons.verified,
                                  color: todo.isCompleted
                                      ? context.theme.primaryColor
                                      : context.theme.iconTheme.color,
                                )),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(todo.date ?? ""),
                                  Text(
                                    todo.title ?? "",
                                    style: context.theme.textTheme.subtitle1,
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
              todo.isSaved
                  ? Spacer()
                  : Expanded(
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              todo.isSaved = true;
                              todo.title = controller.text;
                              todo.date = getDate();
                              databaseHelper.addTodo(todo).then((value) {
                                todo.id = value;
                              });

                              // updateTodoList();
                            });
                          },
                          icon: Icon(
                            Icons.save,
                            color: context.theme.primaryColor,
                          ))),
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          if (todo.isSaved) {
                            databaseHelper.deleteTodo(todo.id!);
                            todoList!.remove(todo);
                            // updateTodoList();
                          } else {
                            todoList!.remove(todo);
                          }
                        });
                      },
                      icon: Icon(Icons.delete)))
            ],
          ),
        ),
      ),
    );
  }

  void updateTodoList() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todoListFuture = databaseHelper.getTodos();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
        });
      });
    });
  }

  Text buildTodolarimText(BuildContext context) {
    return Text(
      "Todolarım",
      style: context.theme.textTheme.headline6,
    );
  }

  String getDate() {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(now).toString();
    return formattedDate;
  }
}
