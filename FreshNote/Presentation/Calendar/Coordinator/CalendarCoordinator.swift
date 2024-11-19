//
//  CalendarCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import UIKit

protocol CalendarCoordinatorDependencies: AnyObject {
  func makeCalendarViewController(actions: CalendarViewModelActions) -> CalendarViewController
}

class CalendarCoordinator: BaseCoordinator {
  // MARK: - Properties
  private let dependencies: any CalendarCoordinatorDependencies
  
  // MARK: - LifeCycle
  init(navigationController: UINavigationController?, dependencies: any CalendarCoordinatorDependencies) {
    self.dependencies = dependencies
    super.init(navigationController: navigationController)
  }
  
  
  func start() {
    let actions = CalendarViewModelActions()
    let viewController = self.dependencies.makeCalendarViewController(actions: actions)
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}
