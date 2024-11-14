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
  
  
  // MARK: - Domain Layer
  func makeAlarmSaveUseCase() -> any AlarmSaveUseCase {
    return DefaultAlarmSaveUseCase(dateTimeRepository: self.makeDateTimeRepository())
  }
  
  // MARK: - Data Layer
  func makeFirestoreService() -> any FirestoreService {
    return DefaultFirestoreService()
  }
  
  func makeDateTimeRepository() -> any DateTimeRepository {
    return DefaultDateTimeRepository(service: self.makeFirestoreService())
  }
  
  // MARK: - Presentation Layer
  func makeOnboardingViewModel(
    actions: OnboardingViewModelActions
  ) -> OnboardingViewModel {
    return DefaultOnboardingViewModel(actions: actions)
  }
  
  func makeDateTimeSettingViewModel(
    actions: DateTimeSettingViewModelActions
  ) -> DateTimeSettingViewModel {
    // TODO: - DefaultRepository 분리해야함
    return DefaultDateTimeSettingViewModel(actions: actions, alarmSaveUseCase: self.makeAlarmSaveUseCase())
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
