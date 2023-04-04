//
//  NetworkMonitor.swift
//  Dayeng
//
//  Created by 배남석 on 2023/03/31.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor: NWPathMonitor
    var isConnected: Bool = false
    
    init() {
        self.monitor = NWPathMonitor()
    }
    
    func startMonitoring(statusHandler: @escaping (NWPath.Status) -> Void) {
        self.monitor.start(queue: DispatchQueue.global())
        self.monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied ? true : false
                statusHandler(path.status)
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
