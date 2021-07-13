

import UIKit
import RealmSwift

class TasksViewController: UITableViewController {
    
    var currentList: TaskList!
    
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    private var isEditingMode = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentList.name
        currentTasks = currentList.tasks.filter("isComplete = false")
        completedTasks = currentList.tasks.filter("isComplete = true")
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        isEditingMode.toggle()
        tableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        showAlert()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let currentTask = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.shared.delete(task: currentTask)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, isDone) in
            self.showAlert(with: currentTask) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { (_, _, isDone) in
            StorageManager.shared.done(task: currentTask)
            let indexPathForCopmpletedTask = IndexPath(row: self.completedTasks.count - 1, section: 1)
            let indexPathForCurrentTask = IndexPath(row: self.currentTasks.count - 1, section: 0)
            let sourceIndexRow = IndexPath(row: indexPath.row, section: indexPath.section)
            let destinationIndexRow = indexPath.section == 0 ? indexPathForCopmpletedTask : indexPathForCurrentTask
            self.tableView.moveRow(at: sourceIndexRow, to: destinationIndexRow)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [editAction, doneAction, deleteAction])
    }
}

// MARK: - Private methods
extension TasksViewController {
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        
        let alert = AlertController(title: "New Task", message: "What do you want to do?", preferredStyle: .alert)
        
        alert.actionWithTask(for: task) { newValue, note in
            
            if let task = task, let completion = completion {
                StorageManager.shared.edit(task: task, with: newValue, and: note)
                completion()
            } else {
                let task = Task()
                task.name = newValue
                task.note = note
                StorageManager.shared.save(task: task, taskList: self.currentList)
                let rowIndex = IndexPath(row: self.currentTasks.count - 1, section: 0)
                self.tableView.insertRows(at: [rowIndex], with: .automatic)
            }
        }
        
        present(alert, animated: true)
    }
}
