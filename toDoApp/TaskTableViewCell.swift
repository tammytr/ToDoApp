//
//  TaskTableViewCell.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/12/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priorityControl: PriorityControl!
    @IBOutlet weak var cellDoneButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
