//
//  DoneTableViewController.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/13/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit
import os.log

//MARK: Properties
var doneList = [Task]()

class DoneTableViewController: UITableViewController {
    
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
            doneList += savedTasks
        }

    }

    // MARK: - Table view data source

    // Return the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Return the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doneList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "DoneTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DoneTableViewCell else {
            fatalError("The dequeued cell is not an instance of DoneTableViewCell.")
        }
        
        // Fetches the appropriate task for the data source layout.
        let task = doneList[indexPath.row]
        
        // Doesn't allow selection of task
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        // Fills in task information in table cell.
        cell.nameLabel.text = task.name
        cell.dateLabel.text = "\(task.dueDate.getDayMonthYear().month)/\(task.dueDate.getDayMonthYear().day)/\(task.dueDate.getDayMonthYear().year)"
        cell.priorityControl.priority = task.priority
        cell.myDoneButton.tag = indexPath.row
        cell.myDoneButton.addTarget(self, action: "checkUndone:", for: .touchUpInside)
        
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
            doneList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveTasks()
        } else if editingStyle == .insert {
        }
    }

    
    //MARK: Actions
    
    // Clear all of the tasks that are done
    @IBAction func clearAll(_ sender: UIBarButtonItem) {
        doneList.removeAll()
        saveTasks()
        tableView.reloadData()
    }
    
    // Unmark the task as done.
    @IBAction func checkUndone(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? DoneTableViewCell else {
            return
        }
        let selectedIndexPath = tableView.indexPath(for: cell)
        let undoneTask = doneList[selectedIndexPath!.row]
        undoneTask.done = !undoneTask.done
        tasks.append(undoneTask)
        tasksPriority.append(undoneTask)
        doneList.remove(at: selectedIndexPath!.row)
        let myIndexPath = IndexPath(row: selectedIndexPath!.row, section: 0)
        tableView.deleteRows(at: [myIndexPath], with: .fade)
        tasks.sort(by: { $0.dueDate < $1.dueDate })
        tasksPriority.sort(by: { $0.priority > $1.priority })
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
        return NSKeyedUnarchiver.unarchiveObject(withFile: Task.ArchiveURLDone.path) as? [Task]
    }
    

}
