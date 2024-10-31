//
//  HomeCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import UIKit

protocol HomeCoordinatorDependencies: AnyObject {
  func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController
  func makeNotificationCoordinator(navigationController: UINavigationController?) -> NotificationCoordinator
}

final class HomeCoordinator: BaseCoordinator {
  // MARK: - Properties
  private let dependencies: any HomeCoordinatorDependencies
  
  
  // MARK: - LifeCycle
  init(navigationController: UINavigationController?, dependencies: any HomeCoordinatorDependencies) {
    self.dependencies = dependencies
    super.init(navigationController: navigationController)
  }
}

// MARK: - Start
extension HomeCoordinator {
  func start() {
    let actions = HomeViewModelActions { [weak self] in
      self?.showNotificationPage()
    }
    let homeViewController = dependencies.makeHomeViewController(actions: actions)
    navigationController?.pushViewController(homeViewController, animated: true)
  }
}

// MARK: - Private Helpers
extension HomeCoordinator {
  private func showNotificationPage() {
    let childCoordinator = dependencies.makeNotificationCoordinator(navigationController: navigationController)
    childCoordinator.finishDelegate = self
    childCoordinators[childCoordinator.identifier] = childCoordinator
    childCoordinator.start()
  }
}

// MARK: - CoordinatorFinishDelegate
extension HomeCoordinator: CoordinatorFinishDelegate {
  func coordinatorDidFinish(_ childCoordinator: BaseCoordinator) {
    childCoordinator.childCoordinators.removeValue(forKey: childCoordinator.identifier)
  }
}
