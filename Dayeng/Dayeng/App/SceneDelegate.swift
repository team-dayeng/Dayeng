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
        
        let navigationController = UINavigationController()
        self.coodinator = AppCoordinator(navigationController: navigationController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        // 앱 실행 중 'Apple ID 사용 중단' 할 경우
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil,
            using: { (Notification) in
                // TODO: alert 같은거 띄워주기
                print("Apple ID 사용 중단")
                DispatchQueue.main.async {
                    self.coodinator?.showLoginViewController()
                }
            })
        
        self.coodinator?.start()
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

    func changeRootViewController(_ viewController: UIViewController) {
        guard let window = self.window else { return }
        window.rootViewController = viewController
        
        UIView.transition(with: window, duration: 1.0, options: [.transitionCurlUp], animations: nil, completion: nil)
    }
    
    func transitionViewController(_ viewController: UIViewController, option: UIView.AnimationOptions) {
        guard let window = self.window else { return }
        guard let navigationController = window.rootViewController as? UINavigationController else { return }
        UIView.transition(with: window, duration: 1.0, options: option) {
            navigationController.viewControllers.append(viewController)
        }
    }
}

