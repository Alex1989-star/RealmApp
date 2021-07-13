

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        let currentTasks = taskList.tasks.filter("isComplete = false")
        let completedTasks = taskList.tasks.filter("isComplete = true")
        
        textLabel?.text = taskList.name
        
        if !currentTasks.isEmpty {
            detailTextLabel?.text = "\(currentTasks.count)"
//            accessoryType = .none
            
            detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            detailTextLabel?.textColor = .gray
        } else if !completedTasks.isEmpty {
//            detailTextLabel?.text = nil
//            accessoryType = .checkmark
            
            detailTextLabel?.text = "✓"
            detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            detailTextLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            
        } else {
//            accessoryType = .none
            detailTextLabel?.text = "0"
            
            detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
            detailTextLabel?.textColor = .gray
        }
    }
}
