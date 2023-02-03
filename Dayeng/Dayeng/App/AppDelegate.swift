//
//  AppDelegate.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit
import FirebaseCore
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        // 앱 실행시 로그인 상태 확인 (Apple)
        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        appleIDProvider.getCredentialState(forUserID: /* 로그인 할 userID*/) { (credentialState, error) in
//            switch credentialState {
//            case .authorized:
//                // apple ID credential 유효
//                print("ID 연동 O")
//            case .revoked:
//                // 해당 userID 값이 앱과 연결 취소되어 있으므로 로그인 UI를 표시
//                print("ID 연동 X")
//            case .notFound:
//                // userID가 앱과 연결되어 있지 않으므로 로그인 UI를 표시
//                print("ID 찾을 수 없음")
//            default:
//                break
//            }
//        }
        
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

