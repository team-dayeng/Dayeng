//
//  Data+.swift
//  Dayeng
//
//  Created by  sangyeon on 2023/02/12.
//

import Foundation

extension Data {
    func toString() -> String? {
        try? JSONDecoder().decode(String.self, from: self)
    }
    
    func toInt() -> Int? {
        Int(String(data: self, encoding: .utf8) ?? "")
    }
}
