//
//  TaskPriorityTableViewController.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/13/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit
import os.log

//MARK: Properties
var tasksPriority = [Task]()

class TaskPriorityTableViewController: UITableViewController {

    @IBOutlet var myTableView: UITableView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        myTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = hexStringToUIColor(hex: "ffa5c9")

        // Load any saved tasks.
        if let savedTasks = loadTasks() {
            tasksPriority += savedTasks
        }
    }

    // MARK: - Table view data source

    // Return the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Return the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksPriority.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TaskSortPriorityTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskSortPriorityTableViewCell else {
            fatalError("The dequeued cell is not an instance of TaskSortPriorityTableViewCell.")
        }
        
        // Fetches the appropriate task for the data source layout.
        let task = tasksPriority[indexPath.row]

        // Fills in task information in table cell.
        cell.nameLabel.text = task.name
        cell.dateLabel.text = "\(task.dueDate.getDayMonthYear().month)/\(task.dueDate.getDayMonthYear().day)/\(task.dueDate.getDayMonthYear().year)"
        cell.priorityControl.priority = task.priority
        cell.myDoneButton.tag = indexPath.row
        cell.myDoneButton.addTarget(self, action: "checkDone:", for: .touchUpInside)

        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tasksPriority.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tasks = tasksPriority.sorted(by: { $0.dueDate < $1.dueDate })
            saveTasks()
        } else if editingStyle == .insert {
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new task.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let taskDetailViewController = segue.destination as? TaskViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTaskCell = sender as? TaskSortPriorityTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTaskCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTask = tasksPriority[indexPath.row]
            taskDetailViewController.task = selectedTask
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
        }
    }
    

    //MARK: Actions

    @IBAction func unwindToTaskList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TaskViewController, let task = sourceViewController.task {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing task.
                tasksPriority[selectedIndexPath.row] = task
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new task.
                tasksPriority.append(task)
                tasksPriority.sort(by: { $0.priority > $1.priority })
                let index = tasksPriority.index{$0 === task}
                let newIndexPath = IndexPath(row: index ?? tasks.count - 1, section: 0)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            tasks = tasksPriority.sorted(by: { $0.dueDate < $1.dueDate })
            
            // Save the tasks
            saveTasks()
        }
    }
    
    // Mark the task as done.
    @IBAction func checkDone(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? TaskSortPriorityTableViewCell else {
            return
        }
        let selectedIndexPath = tableView.indexPath(for: cell)
        let doneTask = tasksPriority[selectedIndexPath!.row]
        doneTask.done = !doneTask.done
        doneList.append(doneTask)
        tasksPriority.remove(at: selectedIndexPath!.row)
        let myIndexPath = IndexPath(row: selectedIndexPath!.row, section: 0)
        tableView.deleteRows(at: [myIndexPath], with: .fade)
        tasks = tasksPriority.sorted(by: { $0.dueDate < $1.dueDate })
        saveTasks()
    }
    
    //MARK: Private Methods
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    private func saveTasks() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tasks, toFile: Task.ArchiveURL.path)
        NSKeyedArchiver.archiveRootObject(tasksPriority, toFile: Task.ArchiveURLPriority.path)
        NSKeyedArchiver.archiveRootObject(doneList, toFile: Task.ArchiveURLDone.path)
        if isSuccessfulSave {
            os_log("Tasks successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save tasks...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadTasks() -> [Task]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Task.ArchiveURLPriority.path) as? [Task]
    }
    
}
