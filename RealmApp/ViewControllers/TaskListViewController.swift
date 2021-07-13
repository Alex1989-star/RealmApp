

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    var taskLists: Results<TaskList>!

    override func viewDidLoad() {
        super.viewDidLoad()
        taskLists = realm.objects(TaskList.self)
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func  addButtonPressed(_ sender: Any) {
        showALert()
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            taskLists = taskLists.sorted(byKeyPath: "name")
        } else {
            taskLists = taskLists.sorted(byKeyPath: "date")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.shared.delete(taskList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showALert(with: currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            StorageManager.shared.done(taskList: currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [editAction, doneAction, deleteAction])
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let taskList = taskLists[indexPath.row]
        let tasksVC = segue.destination as! TasksViewController
        tasksVC.currentList = taskList
    }

}

extension TaskListViewController {
    
    private func showALert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let alert = AlertController(title: "New List", message: "Please insert new value", preferredStyle: .alert)
        
        alert.actionWIthTaskList(for: taskList) { newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList: taskList, with: newValue)
                completion()
            } else {
                let taskList = TaskList()
                taskList.name = newValue
                StorageManager.shared.save(taskList: taskList)
                let rowIndex = IndexPath(row: self.taskLists.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
    
}
