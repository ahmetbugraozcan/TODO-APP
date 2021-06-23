class Todo {
  //TODO tamamlandı mı alanı eklenecek
  bool isCompleted = false;
  int? id;
  String? title;
  String? date;
  bool isSaved = false;
  Todo(this.title, this.date, this.isSaved, this.isCompleted);
  Todo.withID(this.id, this.title, this.date, this.isSaved, this.isCompleted);
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo.withID(
        map["id"],
        map["title"],
        map["date"],
        map["isSaved"] == 0 ? false : true,
        map["isCompleted"] == 0 ? false : true);
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map["isSaved"] = isSaved ? 1 : 0;
    map["title"] = title;
    map["date"] = date;
    map["isCompleted"] = isCompleted ? 1 : 0;

    return map;

    // return {
    //   'isSaved': isSaved ? 1 : 0,
    //   'title': title,
    //   'date': date,
    //   'isCompleted': isCompleted ? 1 : 0
    // };
  }
}
