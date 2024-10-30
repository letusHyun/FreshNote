//
//  OnboardingViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/21/24.
//

import Foundation
import Combine

struct OnboardingViewModelActions {
  let showDateTimeSetting: () -> Void
}

protocol OnboardingViewModel: OnboardingViewModelInput, OnboardingViewModelOutput { }

protocol OnboardingViewModelInput {
  func viewDidLoad()
  func numberOfItemsInSection(sectionIndex: Int) -> Int
  func dataSourceCount() -> Int
  func cellForItemAt(indexPath: IndexPath) -> OnboardingCellInfo
  func didTapLoginButton()
}

protocol OnboardingViewModelOutput {
}

final class DefaultOnboardingViewModel {
  // MARK: - Properties
  private let dataSource: [OnboardingCellInfo] = {
    return [
      OnboardingCellInfo(
        description: "내가 입력한 유통 & 소비기한으로\n원하는 디데이 알림을 받아보세요.",
        lottieName: "firstOnboardingLottie"
      ),
      OnboardingCellInfo(
        description: "식품을  더 맛있게, 그리고 안전하게\n보관하기 위한  첫걸음",
        lottieName: "secondOnboardingLottie"
      )
    ]
  }()
  
  private let actions: OnboardingViewModelActions
  
  // MARK: - LifeCycle
  init(actions: OnboardingViewModelActions) {
    self.actions = actions
  }
}

extension DefaultOnboardingViewModel: OnboardingViewModel {
  // MARK: - Input
  func cellForItemAt(indexPath: IndexPath) -> OnboardingCellInfo {
    return dataSource[indexPath.item]
  }
  
  func viewDidLoad() {
    
  }
  
  func numberOfItemsInSection(sectionIndex: Int) -> Int {
    return dataSource.count
  }
  
  func dataSourceCount() -> Int {
    return dataSource.count
  }
  
  // MARK: - Output
  func didTapLoginButton() {
    actions.showDateTimeSetting()
  }
}
