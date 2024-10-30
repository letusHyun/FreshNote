//
//  OnboardingCoordinator.swift
//  FreshNote
//
//  Created by SeokHyun on 10/27/24.
//

import UIKit

protocol OnboardingCoordinatorDependencies {
  func makeOnboardingViewController(actions: OnboardingViewModelActions) -> OnboardingViewController
  func makeDateTimeSettingCoordinator(navigationController: UINavigationController?) -> DateTimeSettingCoordinator
}

final class OnboardingCoordinator: BaseCoordinator {
  // MARK: - Properties
  private let dependencies: any OnboardingCoordinatorDependencies
  
  // MARK: - LifeCycle
  init(dependencies: any OnboardingCoordinatorDependencies, navigationController: UINavigationController?) {
    self.dependencies = dependencies
    super.init(navigationController: navigationController)
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - Start
  func start() {
    let actions = OnboardingViewModelActions { [weak self] in
      self?.showDateTimeSetting()
    }
    let viewController = dependencies.makeOnboardingViewController(actions: actions)
    
    // Case 1. 처음 로그인한 경우, 알람설정을 하지 않았기 때문에 settingVC까지 고려해야합니다.
      // navigationController 필요함
    // Case 2. 재로그인의 경우, setting을 설정했기 때문에 바로 Main화면으로 보여줍니다.
      // navigationController 필요하지 않음
    
    // 재로그인 판별 방법: 파이어베이스의 dday가 -1이라면 처음 로그인, -1이 아니라면 재로그인
      // 파이어베이스에서 dday fetch를 통해 알아오기
    navigationController?.viewControllers = [viewController]
  }
}

// MARK: - CoordinatorFinishDelegate
extension OnboardingCoordinator: CoordinatorFinishDelegate {
  func coordinatorDidFinish(_ childCoordinator: BaseCoordinator) {
    childCoordinators.removeValue(forKey: childCoordinator.identifier)
    finish()
  }
}

// MARK: - Private Helpers
extension OnboardingCoordinator {
  private func showDateTimeSetting() {
    let childCoordinator = dependencies.makeDateTimeSettingCoordinator(navigationController: navigationController)
    childCoordinator.finishDelegate = self
    childCoordinators[childCoordinator.identifier] = childCoordinator
    childCoordinator.start()
  }
}
