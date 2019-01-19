//
//  Task.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/12/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit
import os.log

class Task: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var dueDate: Date
    var priority: Int
    var done: Bool
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks")
    static let ArchiveURLPriority = DocumentsDirectory.appendingPathComponent("priority")
    static let ArchiveURLDone = DocumentsDirectory.appendingPathComponent("done")


    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let dueDate = "dueDate"
        static let priority = "priority"
        static let done = "done"
    }
    
    //MARK: Initialization
    
    init?(name: String, dueDate: Date, priority: Int, done: Bool) {
        
        // Initialization should fail if there is no name
        guard !name.isEmpty else {
            return nil
        }
        
        // The rating must be between 0 and 5 inclusively
        guard (priority >= 0) && (priority <= 5) else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.dueDate = dueDate
        self.priority = priority
        self.done = done
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(dueDate, forKey: PropertyKey.dueDate)
        aCoder.encode(priority, forKey: PropertyKey.priority)
        aCoder.encode(done, forKey: PropertyKey.done)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Task object.", log: OSLog.default, type: .debug)
            return nil
        }
        let dueDate = aDecoder.decodeObject(forKey: PropertyKey.dueDate) as? Date
        let priority = aDecoder.decodeInteger(forKey: PropertyKey.priority)
        let done = aDecoder.decodeBool(forKey: PropertyKey.done)
        
        // Must call designated initializer.
        self.init(name: name, dueDate: dueDate!, priority: priority, done: done)
    }
    
}
