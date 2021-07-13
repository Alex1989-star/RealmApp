

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static let shared = StorageManager()
    
    func save(taskList: TaskList) {
        try! realm.write {
            realm.add(taskList)
        }
    }
    
    func save(task: Task, taskList: TaskList) {
        try! realm.write {
            taskList.tasks.append(task)
        }
    }
    
    func delete(taskList: TaskList) {
        try! realm.write {
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
    
    func edit(taskList: TaskList, with newList: String) {
        try! realm.write {
            taskList.name = newList
        }
    }
    
    func done(taskList: TaskList) {
        try! realm.write {
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    func edit(task: Task, with name: String, and note: String) {
        try! realm.write {
            task.name = name
            task.note = note
        }
    }
    
    func delete(task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    func done(task: Task) {
        try! realm.write {
            task.isComplete.toggle()
        }
    }
}
