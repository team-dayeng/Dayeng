//
//  SceneDelegate.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coodinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: scene)
        
        // 앱 실행 중 'Apple ID 사용 중단' 할 경우
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil,
            using: { (Notification) in
                print("Apple ID 사용 중단")
                // 로그인 페이지로 이동
                DispatchQueue.main.async {
                    self.window?.rootViewController = LoginViewController()
                    self.window?.makeKeyAndVisible()
                }
            })
        
        // 앱 실행시 로그인 상태 확인 (Apple)
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        // TODO: UserDefaults?로부터 userID 얻어 forUserID에 입력
        appleIDProvider.getCredentialState(forUserID: ""/* 로그인 할 userID */) { (credentialState, error) in
            switch credentialState {
            case .authorized:
                // apple ID credential 유효
                print("ID 연동 O")
                DispatchQueue.main.async {
                    self.window?.rootViewController = ViewController()
                    self.window?.makeKeyAndVisible()
                }
            case .revoked, .notFound:
                // 해당 userID 값이 앱과 연결 취소되어 있거나 연결되어 있지 않으므로 로그인 UI를 표시
                print("ID가 연동되어 있지 않거나 ID를 찾을 수 없음")
                DispatchQueue.main.async {
                    let navigationController = UINavigationController()
                    self.coodinator = AppCoordinator(navigationController: navigationController)
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                    self.coodinator?.start()
                }
            default:
                break
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

