//
//  SceneDelegate.swift
//  Dayeng
//
//  Created by 조승기 on 2023/01/30.
//

import UIKit
import AuthenticationServices
import FirebaseDynamicLinks
import KakaoSDKAuth
import RxKakaoSDKAuth
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?
    var acceptFriendCode: String?
    var acceptFriendName: String?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: scene)
        let navigationController = UINavigationController()
        self.coordinator = AppCoordinator(navigationController: navigationController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        self.coordinator?.start()
        
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
        
        if let urlContext = connectionOptions.urlContexts.first {
            let urlContexts: Set = [urlContext]
            self.scene(scene, openURLContexts: urlContexts)
        }
        
        // 앱 실행 중 'Apple ID 사용 중단' 할 경우
        NotificationCenter.default.addObserver(
            forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil,
            queue: nil,
            using: { [weak self] (Notification) in
                print("Apple ID 사용중단")
                
                // firebase auth logout
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error)
                    return
                }
                
                // view translation
                guard let self, let window = self.window else { return }
                DispatchQueue.main.async {
                    guard let viewController = (window.rootViewController as? UINavigationController)?.viewControllers.last ?? window.rootViewController else {
                        return
                    }
                    viewController.showAlert(
                        title: "Apple ID가 사용 중단되어 로그아웃 되었습니다.",
                        message: "로그인 화면으로 이동합니다.",
                        type: .oneButton,
                        rightActionHandler: { [weak self] in
                            guard let self,
                                  let coordinator = self.coordinator else { return }
                            DispatchQueue.main.async {
                                coordinator.showLoginViewController()
                            }
                    })
                }
            })
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.rx.handleOpenUrl(url: url)
        }
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems
        
        guard let acceptFriendCode = queryItems?.filter({ $0.name == "code" }).first?.value,
              let acceptFriendName = queryItems?.filter({ $0.name == "name" }).first?.value,
              let navigationController = self.window?.rootViewController as? UINavigationController else { return }

        if navigationController.topViewController is SplashViewController ||
            navigationController.topViewController is LoginViewController {
            self.acceptFriendCode = acceptFriendCode
            self.acceptFriendName = acceptFriendName
        } else {
            self.coordinator?.showAcceptFriendViewController(acceptFriendCode: acceptFriendCode,
                                                             acceptFriendName: acceptFriendName)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        NetworkMonitor.shared.stopMonitoring()
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
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let scene = (scene as? UIWindowScene) else { return }
        scene.userActivity = userActivity
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLinks, error in
                guard let dynamiclink = dynamicLinks, let deepLink = dynamiclink.url else { return }
                let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
                
                guard let acceptFriendCode = queryItems?.filter({ $0.name == "code" }).first?.value,
                      let acceptFriendName = queryItems?.filter({ $0.name == "name" }).first?.value,
                      let navigationController = self.window?.rootViewController as? UINavigationController else { return }
        
                if navigationController.topViewController is SplashViewController ||
                    navigationController.topViewController is LoginViewController {
                    self.acceptFriendCode = acceptFriendCode
                    self.acceptFriendName = acceptFriendName
                } else {
                    self.coordinator?.showAcceptFriendViewController(acceptFriendCode: acceptFriendCode,
                                                                     acceptFriendName: acceptFriendName)
                }
            }
        } else {
            print("incomingURL is nil")
        }
    }

    func changeRootViewController(_ navigationController: UINavigationController,
                                  _ viewController: UIViewController,
                                  _ transitionOption: UIView.AnimationOptions? = nil) {
        guard let window = self.window else { return }
        window.rootViewController = navigationController
        
        navigationController.viewControllers = [viewController]
        UIView.transition(with: window,
                          duration: 1.0,
                          options: transitionOption ?? UIView.AnimationOptions(),
                          animations: nil) { _ in
            if viewController is MainViewController,
               let acceptFriendCode = self.acceptFriendCode,
               let acceptFriendName = self.acceptFriendName {
                   self.coordinator?.showAcceptFriendViewController(acceptFriendCode: acceptFriendCode,
                                                                    acceptFriendName: acceptFriendName)
            }
        }
    }
    
    func transitionViewController(_ viewController: UIViewController, option: UIView.AnimationOptions) {
        guard let window = self.window,
              let navigationController = window.rootViewController as? UINavigationController else { return }
        UIView.transition(with: window,
                          duration: 1.0,
                          options: option) {
            navigationController.viewControllers.append(viewController)
        }
    }
    
    func setNetworkMonitor() {
        NetworkMonitor.shared.startMonitoring { [weak self] connectionStatus in
            guard let self else { return }
            switch connectionStatus {
            case .satisfied:
                self.dismissNetwrokDisConnectView()
            case .unsatisfied:
                self.showNetworkDisconnectView()
            default:
                break
            }
        }
    }
    
    private func showNetworkDisconnectView() {
        let viewController = NetworkDisconnectViewController()
        viewController.modalPresentationStyle = .fullScreen
        
        if let navigationContorller = self.window?.rootViewController as? UINavigationController {
            navigationContorller.viewControllers.first?.present(viewController, animated: false)
        }
    }
    
    private func dismissNetwrokDisConnectView() {
        if let navigationContorller = self.window?.rootViewController as? UINavigationController {
            navigationContorller.viewControllers.first?.dismiss(animated: false)
        }
    }
}

