//
//  TaskViewController.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/11/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit
import os.log

class TaskViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UILabel!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var priorityControl: PriorityControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `TaskTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var task: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Task.
        if let task = task {
            navigationItem.title = task.name
            nameTextField.text   = task.name
            dueDatePicker.date = task.dueDate
            priorityControl.priority = task.priority
        }
        
        // Handle date picker user input.
        dueDatePicker?.datePickerMode = .date
        
        // Enable the Save button only if the text field has a valid Task name.
        updateSaveButtonState()
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddTaskMode = presentingViewController is UITabBarController
        if isPresentingInAddTaskMode {
            dismiss(animated: true, completion: nil)
            return
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
        return
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let name = nameTextField.text ?? ""
        let date = dueDatePicker.date
        let priority = priorityControl.priority
        
        // Set the task to be passed to TaskTableViewController after the unwind segue.
        task = Task(name: name, dueDate: date, priority: priority, done: false)
    }
    
    //MARK: Actions
    
    @IBAction func valueChanged(_ sender: UIDatePicker, forEvent event: UIEvent) {
        dueDateTextField?.text = "due date:   \(sender.date.getDayMonthYear().month)/\(sender.date.getDayMonthYear().day)/\(sender.date.getDayMonthYear().year)"
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: Private Methods
    func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

