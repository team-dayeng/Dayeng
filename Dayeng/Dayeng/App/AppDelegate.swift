//
//  AppDelegate.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit
import FirebaseCore
import RxKakaoSDKCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        RxKakaoSDK.initSDK(appKey: "983c5ee200890b63e1e68e303ffd0114")
        
        DefaultUserNotificationService().requestAuthorization()
            .subscribe(onError: { _ in
                print("권한 없음")
                UserDefaults.isAlarmOn = false
            }).dispose()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
