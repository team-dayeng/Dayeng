//
//  UserDefaults.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/12.
//

import Foundation

extension UserDefaults {
    private enum DayengKeys {
        static let selectedDays = "selectedDays"
    }
    
    class var selectedDays: [Bool] {
        get { (standard.array(forKey: DayengKeys.selectedDays) as? [Bool]) ?? Array(repeating: false, count: 7) }
        set { standard.set(newValue, forKey: DayengKeys.selectedDays) }
    }
}
