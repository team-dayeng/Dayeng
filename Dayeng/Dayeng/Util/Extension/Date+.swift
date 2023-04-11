//
//  File.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import Foundation

extension Date {
    func convertToString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: self)
    }
}
