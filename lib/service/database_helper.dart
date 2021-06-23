import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/model/todo.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String todoTable = 'todo_table';
  String columnId = 'id';
  String columnTitle = 'title';
  String columnDate = 'date';
  String columnIsSaved = 'isSaved';
  String columnIsCompleted = 'isCompleted';

  DatabaseHelper._init();
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._init();
    }
    return _databaseHelper!;
  }
  Future<Database?> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }

    return _database;
  }

  Future<Database> initializeDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todos.db';
    var todoDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnTitle TEXT, '
        '$columnDate TEXT,$columnIsSaved INTEGER,$columnIsCompleted INTEGER)');
  }

  Future<int> addTodo(Todo todo) async {
    Database? db = await this.database;
    var result = await db!.insert(todoTable, todo.toMap());

    return result;
  }

  Future<List<Todo>> getTodos() async {
    List<Todo> todoList = <Todo>[];
    Database? db = await this.database;
    var result = await db!.query(
      todoTable,
      // orderBy: "id DESC",
      orderBy: "isCompleted ASC, id DESC",
    );
    result.forEach((element) {
      var todo = Todo.fromMap(element);
      todoList.add(todo);
    });
    return todoList;
  }

  Future<int> deleteTodo(int id) async {
    var db = await this.database;
    int result =
        await db!.rawDelete('DELETE FROM $todoTable WHERE $columnId = $id');
    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    var db = await this.database;
    var result = await db!.update(todoTable, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
    return result;
  }
}
