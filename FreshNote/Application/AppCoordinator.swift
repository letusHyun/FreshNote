//
//  AppCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import UIKit
import FirebaseAuth
import AuthenticationServices

protocol AppCoordinatorDelegate: AnyObject {
  func setRootViewController(_ viewController: UIViewController)
}

protocol AppCoordinatorDependencies: AnyObject {
  func makeOnboardingCoordinator(navigationController: UINavigationController) -> OnboardingCoordinator
  func makeMainCoordinator(tabBarController: UITabBarController) -> MainCoordinator
}

final class AppCoordinator {
  // MARK: - Properties
  private let dependencies: any AppCoordinatorDependencies
  var childCoordinator: BaseCoordinator?
  weak var delegate: AppCoordinatorDelegate?
  
  // MARK: - LifeCycle
  init(dependencies: any AppCoordinatorDependencies) {
    self.dependencies = dependencies
  }
  
  func start() {
    Task { @MainActor in
      let isLoggedIn = await self.isLoggedIn()
      isLoggedIn ? startMainFlow() : startOnboardingFlow()
    }
  }
}

// MARK: - Private Helpers
private extension AppCoordinator {
  func isLoggedIn() async -> Bool {
    // Firebase 로그인 확인
    guard let currentUser = Auth.auth().currentUser else { return false }
    
    // Firebase 토큰 검증
    do {
      let _ = try await currentUser.getIDToken()
    } catch {
      print("파이어베이스 토큰 검증 실패: \(error)")
      try? Auth.auth().signOut()
      return false
    }
    
    // Apple Credential 검증
    guard let appleCredential = currentUser.providerData.first(where: { $0.providerID == "apple.com" }) else {
      return false
    }
    
    do {
      return try await validateAppleCredential(userID: appleCredential.uid)
    }
    catch {
      return false
    }
  }
  
  func validateAppleCredential(userID: String) async throws -> Bool {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let credentialState = try await appleIDProvider.credentialState(forUserID: userID)
    
    return credentialState == .authorized
  }
  
  func startOnboardingFlow() {
    let navigatonController = UINavigationController(barStyle: .default)
    
    delegate?.setRootViewController(navigatonController)
    let childCoordinator = dependencies.makeOnboardingCoordinator(navigationController: navigatonController)
    childCoordinator.finishDelegate = self
    self.childCoordinator = childCoordinator
    childCoordinator.start()
  }
  
  func startMainFlow() {
    let tabBarController = UITabBarController()
    
    delegate?.setRootViewController(tabBarController)
    let childCoordinator = dependencies.makeMainCoordinator(tabBarController: tabBarController)
    childCoordinator.finishDelegate = self
    self.childCoordinator = childCoordinator
    childCoordinator.start()
  }
}

// MARK: - CoordinatorFinishDelegate
extension AppCoordinator: CoordinatorFinishDelegate {
  func coordinatorDidFinish(_ childCoordinator: BaseCoordinator) {
    if childCoordinator is OnboardingCoordinator {
      startMainFlow()
    } else if childCoordinator is MainCoordinator {
      startOnboardingFlow()
    }
  }
}
