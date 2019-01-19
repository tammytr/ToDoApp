//
//  PriorityControl.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/12/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import UIKit

@IBDesignable class PriorityControl: UIStackView {
    
    //MARK: Properties
    private var priorityButtons = [UIButton]()
    
    var priority = 0 {
        didSet {
            updateButtonSelectionStates()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setUpButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setUpButtons()
        }
    }
    
    //MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setUpButtons()
    }

    //MARK: Button Action
    @objc func priorityButtonTapped(button: UIButton) {
        guard let index = priorityButtons.index(of: button) else {
            fatalError("The button, \(button), is not in the priorityButtons array: \(priorityButtons)")
        }
        
        // Calculate the priority of the selected button
        let selectedPriority = index + 1
        if selectedPriority == priority {
            // If the selected button represents the current priority, reset the priority to 0.
            priority = 0
        } else {
            // Otherwise set the priority to the selected priority
            priority = selectedPriority
        }
    }
    
    //MARK: Private Methods
    
    private func setUpButtons() {
        
        // Clear any existing buttons
        for button in priorityButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        priorityButtons.removeAll()
        
        // Load Button Images
        let bundle = Bundle(for: type(of: self))
        let filledPriority = UIImage(named: "filledPriority", in: bundle, compatibleWith: self.traitCollection)
        let emptyPriority = UIImage(named: "emptyPriority", in: bundle, compatibleWith: self.traitCollection)
        let highlightedPriority = UIImage(named: "highlightedPriority", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<starCount {
            // Create the button
            let button = UIButton()

            // Set the button images
            button.setImage(emptyPriority, for: .normal)
            button.setImage(filledPriority, for: .selected)
            button.setImage(highlightedPriority, for: .highlighted)
            button.setImage(highlightedPriority, for: [.highlighted, .selected])
            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            // Set the accessibility label
            button.accessibilityLabel = "Set \(index + 1) priority rating"
            
            // Setup the button action
            button.addTarget(self, action: #selector(PriorityControl.priorityButtonTapped(button:)), for: .touchUpInside)
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            // Add the new button to the rating button array
            priorityButtons.append(button)
            
            updateButtonSelectionStates()
        }
    }
    
    private func updateButtonSelectionStates() {
        for (index, button) in priorityButtons.enumerated() {
            
            // If the index of a button is less than the priority, that button should be selected.
            button.isSelected = index < priority
            
            // Set the hint string for the currently selected star
            let hintString: String?
            if priority == index + 1 {
                hintString = "Tap to reset the priority to zero."
            } else {
                hintString = nil
            }
            
            // Calculate the value string
            let valueString: String
            switch (priority) {
            case 0:
                valueString = "No priority set."
            case 1:
                valueString = "1 priority set."
            default:
                valueString = "\(priority) priority set."
            }
            
            // Assign the hint string and value string
            button.accessibilityHint = hintString
            button.accessibilityValue = valueString
        }
    }
    
}
