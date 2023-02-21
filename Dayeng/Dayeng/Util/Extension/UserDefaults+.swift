//
//  UserDefaults.swift
//  Dayeng
//
//  Created by 조승기 on 2023/02/12.
//

import Foundation

extension UserDefaults {
    private enum DayengKeys {
        static let selectedAlarmDays = "selectedAlarmDays"
        static let alarmDate = "alarmDate"
        static let isAlarmOn = "isAlarmOn"
    }
    
    class var selectedAlarmDays: [Bool] {
        get { (standard.array(forKey: DayengKeys.selectedAlarmDays) as? [Bool]) ?? Array(repeating: false, count: 7) }
        set { standard.set(newValue, forKey: DayengKeys.selectedAlarmDays) }
    }
    
    class var alarmDate: Date {
        get { (standard.object(forKey: DayengKeys.alarmDate) as? Date) ?? Date() }
        set { standard.set(newValue, forKey: DayengKeys.alarmDate)}
    }
    
    /// If the specified key doesn‘t exist, this method returns false.
    class var isAlarmOn: Bool {
        get { standard.bool(forKey: DayengKeys.isAlarmOn) }
        set { standard.set(newValue, forKey: DayengKeys.isAlarmOn)}
    }
}
