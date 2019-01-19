//
//  DateExtension.swift
//  toDoApp
//
//  Created by Tammy Truong on 1/12/19.
//  Copyright © 2019 Tammy Truong. All rights reserved.
//

import Foundation
import UIKit
extension Date {
    static func calculateDate(day: Int, month: Int, year: Int, hour: Int, minute: Int) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let calculatedDate = formatter.date(from: "\(month)/\(day)/\(year)")
        return calculatedDate!
    }
    
    func getDayMonthYear() -> (month: Int, day: Int, year: Int, hour: Int, minute: Int) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        return (month, day, year, hour, minute)
    }
}
