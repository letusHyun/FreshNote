//
//  AppDIContainer.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import UIKit

final class AppDIContainer {
  // MARK: - Network
  // 프로퍼티
  
//  // MARK: - DIContainers of Scene
  private func makeMainSceneDIContainer() -> MainSceneDIContainer {
    return MainSceneDIContainer(dependencies: MainSceneDIContainer.Dependencies())
  }
  
  private func makeOnboardingSceneDIContainer() -> OnboardingSceneDIContainer {
    return OnboardingSceneDIContainer(dependencies: OnboardingSceneDIContainer.Dependencies())
  }
}

// MARK: - AppCoordinatorDependencies
extension AppDIContainer: AppCoordinatorDependencies {
  func makeOnboardingCoordinator(navigationController: UINavigationController) -> OnboardingCoordinator {
    return OnboardingCoordinator(
      dependencies: makeOnboardingSceneDIContainer(),
      navigationController: navigationController
    )
  }
  
  func makeMainCoordinator(tabBarController: UITabBarController) -> MainCoordinator {
    return MainCoordinator(
      dependencies: makeMainSceneDIContainer(),
      tabBarController: tabBarController
    )
  }
}
