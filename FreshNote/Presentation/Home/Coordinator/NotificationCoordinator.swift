//
//  NotificationCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/31/24.
//

import UIKit

protocol NotificationCoordinatorDependencies: AnyObject {
  func makeNotificationViewController(actions: NotificationViewModelActions) -> NotificationViewController
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

// MARK: - Start
extension NotificationCoordinator {
  func start() {
    let actions = NotificationViewModelActions(pop: { [weak self] in
      self?.pop()
    })
    let viewController = dependencies.makeNotificationViewController(actions: actions)
    navigationController?.pushViewController(viewController, animated: true)
  }
}

extension NotificationCoordinator {
  func pop() {
    finish()
    navigationController?.popViewController(animated: true)
  }
}
