//
//  ProductCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 11/14/24.
//

import UIKit

protocol ProductCoordinatorDependencies: AnyObject {
  func makeProductViewController(
    actions: ProductViewModelActions,
    mode: ProductViewModelMode
  ) -> ProductViewController
  
  // 카메라 화면 전환하기
}

final class ProductCoordinator: BaseCoordinator {
  private let dependencies: any ProductCoordinatorDependencies
  private let mode: ProductViewModelMode
  
  // MARK: - LifeCycle
  init(
    dependencies: any ProductCoordinatorDependencies,
    navigationController: UINavigationController?,
    mode: ProductViewModelMode
  ) {
    self.dependencies = dependencies
    self.mode = mode
    
    super.init(navigationController: navigationController)
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - Start
  func start() {
    let actions = ProductViewModelActions(pop: { [weak self] in
      self?.pop()
    })
    
    let viewController = self.dependencies.makeProductViewController(actions: actions, mode: mode)
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

// MARK: - Private Helpers
extension ProductCoordinator {
  private func pop() {
    self.navigationController?.popViewController(animated: true)
    self.finish()
  }
}
