//
//  URLType.swift
//  Dayeng
//
//  Created by 배남석 on 2023/02/12.
//

import Foundation

enum PageType {
    case openSource
    case about
    
    var url: String {
        switch self {
        case .openSource:
            return "https://spotted-shame-775.notion.site/468b3309812142e9a23bf09fc7fb16bf"
        case .about:
            return "https://spotted-shame-775.notion.site/1fe08602e25145e2af81fdf0e0a16ee3"
        }
    }
}
