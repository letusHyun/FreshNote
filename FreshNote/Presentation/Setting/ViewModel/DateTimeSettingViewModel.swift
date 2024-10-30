//
//  DateTimeSettingViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import Foundation
import Combine

struct DateTimeSettingViewModelActions {
  let showHome: () -> Void
}

protocol DateTimeSettingViewModelInput {
  func viewDidLoad()
  func didTapStartButton(dDay: Int, time: String)
}

protocol DateTimeSettingViewModelOutput {
  
}

protocol DateTimeSettingViewModel: DateTimeSettingViewModelInput, DateTimeSettingViewModelOutput {
  
}

final class DefaultDateTimeSettingViewModel: DateTimeSettingViewModel {
  // MARK: - Properties
  private let actions : DateTimeSettingViewModelActions
  private let dateTimeRepository: any DateTimeRepository
  
  // MARK: - Output
  
  
  // MARK: - LifeCycle
  init(actions: DateTimeSettingViewModelActions, dateTimeRepository: any DateTimeRepository) {
    self.actions = actions
    self.dateTimeRepository = dateTimeRepository
  }
  
  // MARK: - Input
  func viewDidLoad() {
    
  }
  
  func didTapStartButton(dDay: Int, time: String) {
    // TODO: - 파이어베이스에 파라미터 저장 성공 후, 화면 전환
    
    // 뷰컨에적용해야함!
//    let cancellable = dateTimeRepository.saveDateTime(userID: "123", dDay: dDay, time: time)
//      .sink { completion in
//        
//        switch completion {
//        case .finished:
//          break
//        case .failure(let error):
//          print("error: \(error)")
//        }
//      } receiveValue: { _ in
//        print("성공적으로 파이어베이스에 저장됨.")
//      }

    actions.showHome()
  }
}
