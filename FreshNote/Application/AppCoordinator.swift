//
//  AppCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import UIKit

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
    isLoggedIn() ? startMainFlow() : startOnboardingFlow()
  }
}

// MARK: - Private Helpers
private extension AppCoordinator {
  func isLoggedIn() -> Bool {
    // TODO: - userDefaults에 저장한 것을 꺼내와서 사용
//    return false
    return true
  }
  
  func startOnboardingFlow() {
    let navigatonController = UINavigationController()
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
