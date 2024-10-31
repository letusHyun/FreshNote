//
//  OnboardingSceneDIContainer.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import UIKit

final class OnboardingSceneDIContainer {
  struct Dependencies {
//    let apiDataTransferService: DataTransferService
  }
  
  // MARK: - Properties
  private let dependencies: Dependencies
  
  // MARK: - LifeCycle
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  // MARK: - Presentations
  func makeOnboardingViewModel(
    actions: OnboardingViewModelActions
  ) -> OnboardingViewModel {
    return DefaultOnboardingViewModel(actions: actions)
  }
  
  func makeDateTimeSettingViewModel(
    actions: DateTimeSettingViewModelActions
  ) -> DateTimeSettingViewModel {
    // TODO: - DefaultRepository 분리해야함
    return DefaultDateTimeSettingViewModel(actions: actions, dateTimeRepository: DefaultDateTimeRepository())
  }
}

// MARK: - OnboardingCoordinatorDependencies
extension OnboardingSceneDIContainer: OnboardingCoordinatorDependencies {
  func makeDateTimeSettingCoordinator(navigationController: UINavigationController?) -> DateTimeSettingCoordinator {
    return DateTimeSettingCoordinator(
      dependencies: self,
      navigationController: navigationController
    )
  }
  
  func makeOnboardingViewController(
    actions: OnboardingViewModelActions
  ) -> OnboardingViewController {
    let viewModel = makeOnboardingViewModel(actions: actions)
    return OnboardingViewController(viewModel: viewModel)
  }
}

// MARK: - DateTimeSettingCoordinatorDependencies
extension OnboardingSceneDIContainer: DateTimeSettingCoordinatorDependencies {
  func makeDateTimeSettingViewController(
    actions: DateTimeSettingViewModelActions
  ) -> DateTimeSettingViewController {
    let viewModel = self.makeDateTimeSettingViewModel(actions: actions)
    return DateTimeSettingViewController(viewModel: viewModel)
  }
}
