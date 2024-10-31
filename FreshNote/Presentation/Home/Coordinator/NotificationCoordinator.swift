//
//  NotificationCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/31/24.
//

import UIKit

protocol NotificationCoordinatorDependencies: AnyObject {
  func makeNotificationViewController() -> NotificationViewController
}

final class NotificationCoordinator: BaseCoordinator {
  // MARK: - Properties
  private let dependencies: any NotificationCoordinatorDependencies
  
  
  // MARK: - LifeCycle
  init(
    dependencies: any NotificationCoordinatorDependencies,
    navigationController: UINavigationController?
  ) {
    self.dependencies = dependencies
    super.init(navigationController: navigationController)
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
}

extension NotificationCoordinator {
  func start() {
    let viewController = dependencies.makeNotificationViewController()
    navigationController?.pushViewController(viewController, animated: true)
  }
}
