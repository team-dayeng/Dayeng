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
        static let appleID = "appleID"
        static let userID = "userID"
        static let userName = "userName"
        static let lastAnsweredDate = "lastAnsweredDate"
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
    
    class var appleID: String? {
        get { standard.string(forKey: DayengKeys.appleID) }
        set {
            if let newValue {
                standard.set(newValue, forKey: DayengKeys.appleID)
            } else {
                standard.removeObject(forKey: DayengKeys.appleID)
            }
        }
    }
    
    class var userID: String? {
        get { standard.string(forKey: DayengKeys.userID) }
        set {
            if let newValue {
                standard.set(newValue, forKey: DayengKeys.userID)
            } else {
                standard.removeObject(forKey: DayengKeys.userID)
            }
        }
    }
    
    class var userName: String? {
        get { standard.string(forKey: DayengKeys.userName) }
        set {
            if let newValue {
                standard.set(newValue, forKey: DayengKeys.userName)
            } else {
                standard.removeObject(forKey: DayengKeys.userName)
            }
        }
    }
    
    class var lastAnsweredDate: Date {
        get { (standard.object(forKey: DayengKeys.lastAnsweredDate) as? Date) ?? Date(timeIntervalSince1970: 0) }
        set { standard.set(newValue, forKey: DayengKeys.alarmDate)}
    }
}
