//
//  HomeCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import UIKit

protocol HomeCoordinatorDependencies: AnyObject {
  func makeHomeViewController(actions: HomeViewModelActions) -> HomeViewController
}

final class HomeCoordinator: BaseCoordinator {
  private let dependencies: any HomeCoordinatorDependencies
  
  // MARK: - LifeCycle
  init(navigationController: UINavigationController?, dependencies: any HomeCoordinatorDependencies) {
    self.dependencies = dependencies
    super.init(navigationController: navigationController)
  }
  
  func start() {
    let actions = HomeViewModelActions()
    let homeViewController = dependencies.makeHomeViewController(actions: actions)
    navigationController?.pushViewController(homeViewController, animated: true)
  }
}
