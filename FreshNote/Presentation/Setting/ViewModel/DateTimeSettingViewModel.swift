//
//  DateTimeSettingViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import Combine
import Foundation

struct DateTimeSettingViewModelActions {
  let showHome: () -> Void
}

protocol DateTimeSettingViewModelInput {
  func viewDidLoad()
  func didTapStartButton(dateInt: Int, hourMinuteDate: Date)
}

protocol DateTimeSettingViewModelOutput {
  
}

protocol DateTimeSettingViewModel: DateTimeSettingViewModelInput, DateTimeSettingViewModelOutput {
  
}

final class DefaultDateTimeSettingViewModel: DateTimeSettingViewModel {
  // MARK: - Properties
  private let actions : DateTimeSettingViewModelActions
  private var subscriptions = Set<AnyCancellable>()
  @Published private var error: (any Error)?
  private let alarmSaveUseCase: any AlarmSaveUseCase
  
  // MARK: - Output
  
  // MARK: - LifeCycle
  init(actions: DateTimeSettingViewModelActions, alarmSaveUseCase: any AlarmSaveUseCase) {
    self.actions = actions
    self.alarmSaveUseCase = alarmSaveUseCase
  }
  
  // MARK: - Input
  func viewDidLoad() {
    
  }
  
  func didTapStartButton(dateInt: Int, hourMinuteDate: Date) {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    let selectedTime = hourMinuteDate
    let hourMinute = dateFormatter.string(from: selectedTime).components(separatedBy: ":").map { Int($0) ?? 0 }
    let hour = hourMinute.first ?? 0, minute = hourMinute.last ?? 0
    
    alarmSaveUseCase.saveAlarm(date: dateInt, hour: hour, minute: minute)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else { return }
        self?.error = error
        
      } receiveValue: { [weak self] _ in
        self?.actions.showHome()
      }
      .store(in: &subscriptions)
  }
}
